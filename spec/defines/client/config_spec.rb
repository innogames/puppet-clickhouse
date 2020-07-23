# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::client::config' do
  let(:title) { 'custom' }
  let(:params) { { data: { parameter: [{ subparameter: ['value'] }] } } }

  it do
    is_expected.to contain_class('clickhouse::client')
      .with_config_d_dir('/etc/clickhouse-client/config.d')
      .with_conf_d_dir(nil)
  end

  it { is_expected.to contain_package('clickhouse-client') }

  it do
    is_expected.to contain_file('/etc/clickhouse-client/config.d')
      .with_ensure('directory')
  end

  it do
    is_expected.to contain_file('/etc/clickhouse-client/config.d/custom.xml')
      .with_content(
        <<~CONTENT
          <config>
            <parameter>
              <subparameter>value</subparameter>
            </parameter>
          </config>
        CONTENT
      )
  end
end
