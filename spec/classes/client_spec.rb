# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::client' do
  context 'with defaults' do
    it do
      is_expected.to contain_package('clickhouse-client')
        .with_ensure('installed')
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-client/config.d')
        .with_ensure('directory').that_requires('Package[clickhouse-client]')
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-client/conf.d')
        .with_ensure('absent')
    end
  end

  context 'with custom package' do
    let(:params) { { package_name: 'some_name', package_ensure: 'hold' } }

    it { is_expected.to contain_package('some_name').with_ensure('hold') }
  end

  context 'with deprecated conf_dir' do
    let(:params) { { conf_d_dir: '/etc/clickhouse-client/conf.d' } }

    it do
      is_expected.to contain_notify('conf_d deprecation')
    end
  end
end
