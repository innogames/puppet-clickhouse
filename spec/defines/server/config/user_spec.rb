# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server::config::user' do
  let(:title) { 'namevar' }
  let(:params) { {} }

  context 'Without parameters' do
    it { is_expected.to compile.and_raise_error(%r{expects a value for parameter 'networks' \(}m) }
  end

  context 'Test with parameters' do
    let(:params) do
      {
        networks: { 'ip' => ['0.0.0.0/0'] },
        profile: 'some_profile',
      }
    end

    it { is_expected.to compile }
    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d/user-namevar.xml')
        .with_content(
          <<~CONTENT
            <yandex>
              <users>
                <namevar>
                  <password_sha256_hex>e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855</password_sha256_hex>
                  <networks>
                    <ip>0.0.0.0/0</ip>
                  </networks>
                  <profile>some_profile</profile>
                  <quota>default</quota>
                </namevar>
              </users>
            </yandex>
          CONTENT
        )
    end
    it do
      is_expected.to contain_clickhouse__server__config('user-namevar')
    end
  end

  context 'With empty $networks' do
    let(:params) do
      {
        networks: {},
      }
    end

    it { is_expected.to compile }

    it do
      is_expected.to contain_clickhouse__error('User data for namevar is invalid. $networks should contain at least one element')
    end

    it do
      is_expected.to contain_exec('User data for namevar is invalid. $networks should contain at least one element')
        .with_command('/$')
    end
  end

  context 'With wrong password_sha256' do
    let(:params) do
      {
        password_sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b85',
      }
    end

    it do
      is_expected.to compile.and_raise_error(
        %r{parameter 'password_sha256' expects an undef value or a match for Pattern.*, got 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b85'}m,
      )
    end
  end

  context 'With password_sha256' do
    let(:params) do
      {
        password_sha256: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        networks: { 'ip' => ['0.0.0.0/0'] },
      }
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d/user-namevar.xml')
        .with_content(
          <<~CONTENT
            <yandex>
              <users>
                <namevar>
                  <password_sha256_hex>AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</password_sha256_hex>
                  <networks>
                    <ip>0.0.0.0/0</ip>
                  </networks>
                  <profile>default</profile>
                  <quota>default</quota>
                </namevar>
              </users>
            </yandex>
          CONTENT
        )
    end
  end

  context 'With password_sha256' do
    let(:params) do
      {
        password_sha256: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        password: 'password',
        networks: { 'ip' => ['0.0.0.0/0'] },
      }
    end

    it { is_expected.not_to compile }

    it { is_expected.to raise_error(Puppet::ParseError) }
  end

  context 'Tets allow_databases and allow_dictionaties' do
    let(:params) do
      {
        allow_databases: ['database1', 'database2'],
        allow_dictionaries: ['dictionary1', 'dictionary2'],
        networks: { 'ip' => ['0.0.0.0/0'] },
      }
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d/user-namevar.xml')
        .with_content(
          <<~CONTENT
            <yandex>
              <users>
                <namevar>
                  <password_sha256_hex>e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855</password_sha256_hex>
                  <networks>
                    <ip>0.0.0.0/0</ip>
                  </networks>
                  <profile>default</profile>
                  <quota>default</quota>
                  <allow_databases>
                    <database>database1</database>
                    <database>database2</database>
                  </allow_databases>
                  <allow_dictionaries>
                    <dictionary>dictionary1</dictionary>
                    <dictionary>dictionary2</dictionary>
                  </allow_dictionaries>
                </namevar>
              </users>
            </yandex>
          CONTENT
        )
    end
  end
end
