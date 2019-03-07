# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server' do
  context 'with defaults' do
    it { is_expected.to contain_package('clickhouse-server').with_ensure('installed') }
    it do
      is_expected.to contain_service('clickhouse-server').with(
        ensure: 'running',
        enable: true,
      ).that_subscribes_to('Package[clickhouse-server]')
    end
    it do
      is_expected.to contain_file('/etc/clickhouse-server/conf.d').with(
        ensure: 'directory',
        owner: 'clickhouse',
        group: 'clickhouse',
      ).that_requires('Package[clickhouse-server]')
    end
    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d').with(
        ensure: 'directory',
        owner: 'clickhouse',
        group: 'clickhouse',
      ).that_requires('Package[clickhouse-server]')
    end
  end

  context 'with custom package' do
    let(:params) { { package_name: 'some_name', package_ensure: 'hold' } }

    it { is_expected.to contain_package('some_name').with_ensure('hold') }
    it do
      is_expected.to contain_service('some_name').with(
        ensure: 'running',
        enable: true,
      ).that_subscribes_to('Package[some_name]')
    end
  end

  context 'with disabled service' do
    let(:params) { { service_name: 'service', service_ensure: 'stopped', service_enable: false } }

    it do
      is_expected.to contain_service('service').with(
        ensure: 'stopped',
        enable: false,
      ).that_subscribes_to('Package[clickhouse-server]')
    end
  end
end
