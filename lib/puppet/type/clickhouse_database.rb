# frozen_string_literal: true

Puppet::Type.newtype(:clickhouse_database) do
  @doc = '@summary Manages databases on ClickHouse server'

  ensurable do
    desc 'CREATE or DROP DATABASE'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.delete
    end

    defaultto :present
  end

  autorequire(:class) { ['clickhouse::server', 'clickhouse::client'] }

  newparam(:name, namevar: true) do
    desc 'Name of the database'

    validate do |value|
      if value.match(%r{\A[0-9a-zA-Z_]+\Z}).nil?
        raise Puppet::ResourceError, 'parameter name must match /\A[0-9a-zA-Z_]+\Z/'
      end
    end
  end

  newproperty(:engine) do
    desc 'Engine of the database'

    newvalue(:Lazy)
    newvalue(:MySQL)
    newvalue(:Ordinary)

    defaultto :Ordinary
  end

  newparam(:engine_settings) do
    desc "This parameter depends on the `engine` parameter:
Lazy: must be Integer[1]
MySQL: must be Array[String, 4, 4]
Ordinary: must be undefined

See: https://clickhouse.tech/docs/en/engines/database_engines/"

    validate do |v|
      # It can't invoke local methods, so I have to repeat them
      unless (v.is_a?(Integer) && v.positive?) || (v.is_a?(Array) && v.length == 4 && v.all? { |i| i.is_a? String }) || v.nil?
        raise Puppet::ResourceError, 'parameter engine_settings not Optional[Integer[1], Array[String, 4, 4]]'
      end
    end
  end

  newparam(:force, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "DROP database even if it contains tables

If ENGINE=MySQL for an existing database, it will be dropped anyway since it's just a connector"

    defaultto false
  end

  def parameter_lazy?
    p = value(:engine_settings)
    p.is_a?(Integer) && p.positive?
  end

  def parameter_mysql?
    p = value(:engine_settings)
    p.is_a?(Array) && p.length == 4 && p.all? { |v| v.is_a? String }
  end

  def parameter_ordinary?
    value(:engine_settings).nil?
  end

  validate do
    if value(:engine) == :Lazy && !parameter_lazy?
      raise Puppet::ResourceError, "Attribute `engine_settings` must be Integer[1] with engine => 'Lazy'"
    end
    if value(:engine) == :MySQL && !parameter_mysql?
      raise Puppet::ResourceError, "Attribute `engine_settings` must be Array[String, 4, 4] with engine => 'MySQL'"
    end
    if value(:engine) == :Ordinary && !parameter_ordinary?
      raise Puppet::ResourceError, "Attribute `engine_settings` must be undef with engine => 'Ordinary'"
    end
  end
end
