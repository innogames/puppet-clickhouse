# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server::config::memory' do
  context "with total memory #{1 << 30}" do
    let(:facts) { { 'memory' => { 'system' => { 'total_bytes' => 1 << 30 } } } }
    let(:params) { { mark_cache_size: 0 } }

    it { is_expected.to compile }

    it do
      is_expected.to contain_clickhouse__server__config('default-memory')
        .with_section('users')
        .with_data(
          'profiles' => {
            'default' => {
              'use_uncompressed_cache' => [true],
              'max_memory_usage' => [0],
              'max_memory_usage_for_all_queries' => [0],
              'max_bytes_before_external_group_by' => [0],
              'max_bytes_before_external_sort' => [0],
            },
          },
        )
    end

    it do
      is_expected.to contain_clickhouse__server__config('memory')
        .with_section('config')
        .with_data(
          'uncompressed_cache_size' => [8 << 30],
          'mark_cache_size' => [0],
        )
    end

    it { is_expected.to contain_clickhouse__error('This host doesn\'t have sufficient amount of RAM, OOMs are possible') }
    it { is_expected.to contain_exec('This host doesn\'t have sufficient amount of RAM, OOMs are possible') }
    it { is_expected.to contain_notify('memory:mark_cache_size').with_message('$mark_cach_size is lower than recommended 5GiB.') }

    it do
      is_expected.to contain_file('/etc/clickhouse-server/config.d/memory.xml')
        .with_content(
          <<~CONTENT
            <yandex>
              <uncompressed_cache_size>8589934592</uncompressed_cache_size>
              <mark_cache_size>0</mark_cache_size>
            </yandex>
          CONTENT
        )
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d/default-memory.xml')
        .with_content(
          <<~CONTENT
            <yandex>
              <profiles>
                <default>
                  <use_uncompressed_cache>true</use_uncompressed_cache>
                  <max_memory_usage>0</max_memory_usage>
                  <max_memory_usage_for_all_queries>0</max_memory_usage_for_all_queries>
                  <max_bytes_before_external_group_by>0</max_bytes_before_external_group_by>
                  <max_bytes_before_external_sort>0</max_bytes_before_external_sort>
                </default>
              </profiles>
            </yandex>
        CONTENT
        )
    end
  end

  context "with total memory #{5 << 30}" do
    let(:facts) { { 'memory' => { 'system' => { 'total_bytes' => 5 << 30 } } } }
    let(:params) { { mark_cache_size: 1 << 30, reserved_memory: 1 << 30 } }

    it { is_expected.to compile }

    it do
      is_expected.to contain_clickhouse__server__config('default-memory')
        .with_section('users')
        .with_data(
          'profiles' => {
            'default' => {
              'use_uncompressed_cache' => [true],
              'max_memory_usage' => [2_684_354_560],
              'max_memory_usage_for_all_queries' => [2_684_354_560],
              'max_bytes_before_external_group_by' => [1_342_177_280],
              'max_bytes_before_external_sort' => [1_342_177_280],
            },
          },
        )
    end

    it do
      is_expected.to contain_clickhouse__server__config('memory')
        .with_section('config')
        .with_data(
          'uncompressed_cache_size' => [536_870_912],
          'mark_cache_size' => [1_073_741_824],
        )
    end

    it { is_expected.to contain_file('/etc/clickhouse-server/config.d/memory.xml') }

    it { is_expected.to contain_file('/etc/clickhouse-server/users.d/default-memory.xml') }
  end

  context "with total memory #{15 << 30}" do
    let(:facts) { { 'memory' => { 'system' => { 'total_bytes' => 15 << 30 } } } }
    let(:params) do
      {
        mark_cache_size: 7 << 30,
        reserved_memory: 3 << 30,
        uncompressed_cache_size: 2 << 30,
        external_sort: false,
      }
    end

    it { is_expected.to compile }

    it do
      is_expected.to contain_clickhouse__server__config('default-memory')
        .with_section('users')
        .with_data(
          'profiles' => {
            'default' => {
              'use_uncompressed_cache' => [true],
              'max_memory_usage' => [3 << 30],
              'max_memory_usage_for_all_queries' => [3 << 30],
              'max_bytes_before_external_group_by' => [1_610_612_736],
              'max_bytes_before_external_sort' => [0],
            },
          },
        )
    end

    it do
      is_expected.to contain_clickhouse__server__config('memory')
        .with_section('config')
        .with_data(
          'uncompressed_cache_size' => [2 << 30],
          'mark_cache_size' => [7 << 30],
        )
    end

    it { is_expected.to contain_file('/etc/clickhouse-server/config.d/memory.xml') }

    it { is_expected.to contain_file('/etc/clickhouse-server/users.d/default-memory.xml') }

    context 'with additional max_mem_usage should be inefficient' do
      let(:params) do
        super().merge(
          max_memory_usage_for_all_queries: 7 << 30,
        )
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_clickhouse__server__config('default-memory')
          .with_section('users')
          .with_data(
            'profiles' => {
              'default' => {
                'use_uncompressed_cache' => [true],
                'max_memory_usage' => [7 << 30],
                'max_memory_usage_for_all_queries' => [7 << 30],
                'max_bytes_before_external_group_by' => [3_758_096_384],
                'max_bytes_before_external_sort' => [0],
              },
            },
          )
      end

      it do
        is_expected.to contain_clickhouse__server__config('memory')
          .with_section('config')
          .with_data(
            'uncompressed_cache_size' => [2 << 30],
            'mark_cache_size' => [7 << 30],
          )
      end

      it { is_expected.to contain_file('/etc/clickhouse-server/config.d/memory.xml') }
      it { is_expected.to contain_file('/etc/clickhouse-server/users.d/default-memory.xml') }

      it do
        is_expected.to contain_notify('ClickHouse memory config')
          .with_message('The memory configuration for ClickHouse is inefficient. Avaliable: 5368709120; used: 9663676416')
      end
    end
  end
end
