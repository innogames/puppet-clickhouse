# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::client' do
  context 'with defaults' do
    it { is_expected.to contain_package('clickhouse-client').with_ensure('installed') }
    it do
      is_expected.to contain_file('/etc/clickhouse-client/conf.d').with(
        ensure: 'directory',
        owner: 'clickhouse',
        group: 'clickhouse',
      ).that_requires('Package[clickhouse-client]')
    end
  end

  context 'with custom package' do
    let(:params) { { package_name: 'some_name', package_ensure: 'hold' } }

    it { is_expected.to contain_package('some_name').with_ensure('hold') }
  end
end
