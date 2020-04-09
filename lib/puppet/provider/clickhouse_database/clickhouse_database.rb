# frozen_string_literal: true

require_relative '../clickhouse'

Puppet::Type.type(:clickhouse_database).provide(
  :clickhouse,
  parent: Puppet::Provider::Clickhouse,
) do
  desc 'Create or delete databases on ClickHouse server'

  commands clickhouse_client: 'clickhouse-client'

  def self.instances
    # Get rows of database, its engine and amount of tables
    rows = execute_sql(
      <<-SQL
SELECT d.name,
  d.engine,
  countIf(t.name != '') AS tables
FROM system.databases AS d
FULL OUTER JOIN system.tables AS t
ON d.name = t.database
GROUP BY d.name, d.engine
      SQL
    ).split("\n")
    rows.map do |row|
      values = row.split("\t")
      new(
        name: values[0],
        ensure: :present,
        engine: values[1],
        tables: values[2].to_i,
      )
    end
  end

  def self.prefetch(resources)
    existing = instances
    resources.keys.each do |db|
      provider = existing.find { |instance| instance.name == db }
      resources[db].provider = provider if provider
    end
  end

  def create
    # Create DB
    self.class.execute_sql("CREATE DATABASE #{@resource[:name]} ENGINE=#{engine_string}")

    @property_hash[:ensure] = :present
    @property_hash[:engine] = @resource[:engine]

    exists?
  end

  def destroy
    # DROP database if any of conditions is true:
    #   * Database doesn't contain tables
    #   * Database ENGINE=MySQL
    #   * 'force' is set

    unless @property_hash[:tables].zero? || @property_hash[:engine] == :MySQL || force?
      raise Puppet::Error, "database with #{@property_hash[:tables]} tables won't be removed; use 'force'"
    end

    self.class.execute_sql("DROP DATABASE #{@resource[:name]}") if exists?
    @property_hash.clear

    exists? ? (return false) : (return true)
  end

  def delete
    destroy
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def force?
    @resource[:force]
  end

  def engine=(_value)
    destroy
    create
  end

  def engine
    @property_hash[:engine]
  end

  def engine_string
    case @resource[:engine]
    when :Lazy
      return "Lazy(#{@resource[:engine_settings]})" if @resource.parameter_lazy?
    when :MySQL
      return 'MySQL(' + @resource[:engine_settings].map { |p| "'#{p}'" }.join(', ') + ')' if @resource.parameter_mysql?
    when :Ordinary
      return 'Ordinary' if @resource.parameter_ordinary?
    end
    raise Puppet::Error, "Wrong attribute engine_settings `#{@resource[:engine_settings]}` for given engine `#{@resource[:engine]}`"
  end
end
