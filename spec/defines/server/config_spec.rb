# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server::config' do
  let(:title) { 'custom' }
  let(:params) { { data: { parameter: [{ subparameter: ['value'] }] } } }

  context 'without section parameter' do
    it do
      is_expected.to compile \
        .and_raise_error(%r{expects a value for parameter 'section'})
    end
  end

  context 'with section: invalid_value' do
    let(:params) { super().merge(section: 'invalid_value') }

    it do
      is_expected.to compile \
        .and_raise_error(
          %r{parameter 'section' expects a match for Enum\['config', 'users'\]},
        )
    end
  end

  context 'with section: config' do
    let(:params) { super().merge(section: 'config') }

    it do
      is_expected.to contain_class('clickhouse::server').with(
        conf_d_dir: nil,
        config_d_dir: '/etc/clickhouse-server/config.d',
        users_d_dir: '/etc/clickhouse-server/users.d',
      )
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-server/config.d/custom.xml') \
        .with_content(
          <<~CONTENT
            <yandex>
              <parameter>
                <subparameter>value</subparameter>
              </parameter>
            </yandex>
          CONTENT
        )
    end
  end

  context 'with section: users' do
    let(:params) { super().merge(section: 'users') }

    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d/custom.xml') \
        .with_content(
          <<~CONTENT
            <yandex>
              <parameter>
                <subparameter>value</subparameter>
              </parameter>
            </yandex>
          CONTENT
        )
    end
  end

  context 'custom server config paths' do
    let(:pre_condition) { "class { 'clickhouse::server': config_d_dir => '/some/random/path' }" }
    let(:params) { super().merge(section: 'config') }

    it do
      is_expected.to contain_file('/some/random/path/custom.xml') \
        .with_content(
          <<~CONTENT
            <yandex>
              <parameter>
                <subparameter>value</subparameter>
              </parameter>
            </yandex>
          CONTENT
        )
    end
    it do
      is_expected.to contain_file('/some/random/path').with(
        ensure: 'directory',
        owner: 'clickhouse',
        group: 'clickhouse',
      )
    end
  end

  context 'with notification' do
    let(:params) { super().merge(service_notify: true, section: 'config') }

    it do
      is_expected.to contain_file('/etc/clickhouse-server/config.d/custom.xml') \
        .that_notifies('Service[clickhouse-server]')
    end
  end
end
