# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse' do
  context 'with defaults' do
    it { is_expected.to contain_class('clickhouse::client') }
    it { is_expected.not_to contain_class('clickhouse::server') }
    it { is_expected.not_to contain_class('clickhouse::repo') }
  end

  context 'with server' do
    let(:params) { { server: true } }

    it { is_expected.to contain_class('clickhouse::client') }
    it { is_expected.to contain_class('clickhouse::server') }
    it { is_expected.not_to contain_class('clickhouse::repo') }
  end

  context 'without client' do
    let(:params) { { server: true, client: false } }

    it { is_expected.not_to contain_class('clickhouse::client') }
    it { is_expected.to contain_class('clickhouse::server') }
    it { is_expected.not_to contain_class('clickhouse::repo') }
  end

  context 'manage everything' do
    let(:params) { { server: true, client: true, manage_repo: true } }
    let(:facts) { { os: { family: 'RedHat', release: { major: 7 } }, osfamily: 'RedHat' } }

    it { is_expected.to contain_class('clickhouse::client') }
    it { is_expected.to contain_class('clickhouse::server') }
    it { is_expected.to contain_class('clickhouse::repo') }
  end
end
