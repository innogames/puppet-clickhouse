# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::repo' do
  context 'unknown family' do
    let(:facts) { { os: { family: 'FreeBSD' } } }

    it { is_expected.to compile.and_raise_error(%r{Provides repositories only for RedHat and Debian OS families, your family is}) }
  end

  context 'with Debian' do
    let(:facts) do
      {
        os: {
          architecture: 'amd64',
          distro: {
            codename: 'stretch',
            id: 'Debian',
            release: {
              full: '9.6',
              major: '9',
              minor: '6',
            },
          },
          family: 'Debian',
          name: 'Debian',
          release: {
            full: '9.6',
            major: '9',
            minor: '6',
          },
          selinux: {
            enabled: false,
          },
        },
        osfamily: 'Debian',
      }
    end

    it do
      is_expected.to contain_apt__source('clickhouse_yandex').with(
        location: 'http://repo.yandex.ru/clickhouse/deb/stable',
        release: 'main/',
      )
    end
    it do
      is_expected.to contain_apt__key(
        'Add key: 9EBB357BC2B0876A774500C7C8F1E19FE0C56BD4 from Apt::Source clickhouse_yandex',
      ).with(
        id: '9EBB357BC2B0876A774500C7C8F1E19FE0C56BD4',
        server: 'hkp://keyserver.ubuntu.com:80',
      )
    end
  end

  context 'with RedHat' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'CentOS',
          release: {
            full: '7.4.1708',
            major: '7',
            minor: '4',
          },
          selinux: {
            enabled: false,
          },
        },
        osfamily: 'RedHat',
        operatingsystem: 'Centos',
      }
    end

    it do
      is_expected.to contain_yumrepo('altinity_clickhouse').with(
        baseurl: 'https://packagecloud.io/altinity/clickhouse/el/7/$basearch',
        enabled: 1,
        gpgcheck: 0,
        gpgkey: 'https://packagecloud.io/altinity/clickhouse/gpgkey',
        metadata_expire: 300,
        repo_gpgcheck: 1,
        sslverify: 1,
        sslcacert: '/etc/pki/tls/certs/ca-bundle.crt',
      )
    end
  end
end
