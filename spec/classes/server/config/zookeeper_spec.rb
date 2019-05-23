# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server::config::zookeeper' do
  let(:params) { { nodes: { server1: 1 } } }

  it { is_expected.to compile }
  it { is_expected.to contain_clickhouse__server__config('zookeeper') }
  it do
    is_expected.to contain_file('/etc/clickhouse-server/config.d/zookeeper.xml')
      .with(
        owner: 'clickhouse',
        group: 'clickhouse',
        content: <<~CONTENT,
          <yandex>
            <zookeeper>
              <node index="1">
                <host>server1</host>
                <port>2181</port>
              </node>
              <session_timeout_ms>30000</session_timeout_ms>
              <operation_timeout_ms>10000</operation_timeout_ms>
            </zookeeper>
          </yandex>
          CONTENT
      )
  end
end
