# frozen_string_literal: true

# Parrent class for ClickHouse providers
class Puppet::Provider::Clickhouse < Puppet::Provider
  desc 'This provides basic clickhouse-client to execute server side commands

To use custom clickhouse-client settings create /root/.clickhouse-client/config.xml'

  initvars

  ENV['PATH'] += ':/bin:/usr/bin:/usr/local/bin'

  commands clickhouse_client: 'clickhouse-client'

  def self.execute_sql(sql)
    # To use custom client settings create /root/.clickhouse-client/config.xml
    clickhouse_client(['-q', sql].flatten.compact)
  end
end
