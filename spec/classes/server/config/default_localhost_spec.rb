# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server::config::default_localhost' do
  it { is_expected.to compile }
  it do
    is_expected.to contain_clickhouse__server__config('default-localhost')
      .with_section('users')
      .with_data(
        'users' => {
          'default' => {
            'networks' => {
              'replace' => 'replace',
              'host' => ['localhost'],
            },
          },
        },
      )
  end

  it do
    is_expected.to contain_file('/etc/clickhouse-server/users.d/default-localhost.xml')
      .with(
        owner: 'clickhouse',
        group: 'clickhouse',
        content: <<~CONTENT,
          <yandex>
            <users>
              <default>
                <networks replace="replace">
                  <host>localhost</host>
                </networks>
              </default>
            </users>
          </yandex>
          CONTENT
      )
  end
end
