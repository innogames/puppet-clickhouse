# clickhouse::server::config::memory
# This class provide basic memory adjustment for keep ClickHouse server in reasonable limits
#
# @param reserved_memory
#   Memory to leave for system usage and CH overheads like merges and mutations
#
# @param mark_cache_size
#   See CH documentation
#
# @param uncompressed_cache_size
#   See CH documentation
#
# @param max_memory_usage_for_all_queries
#   See CH documentation
#
# @param max_memory_usage
#   See CH documentation
#
# @param use_uncompressed_cache
#   See CH documentation
#
# @param external_group_by
#   See CH documentation
#
# @param external_sort
#   See CH documentation
#
# @param memory_check
#   Check if class has proper parameters and raise errors otherwise
#
# @param service_notify
#   If ClickHouse server should be restarted on the config update
#
# @summary Configure memory consumption
#
# @see https://clickhouse.tech/docs/en/operations/settings/settings/
#
# @see https://clickhouse.tech/docs/en/operations/server_settings/settings/
#
# @example Simple use
#   include clickhouse::server::config::memory
#
# @author InnoGames GmbH
#
class clickhouse::server::config::memory (
    Integer[0]           $reserved_memory                  = 4294967296, # 4 GiB for system apps, cache and CH overheads
    Integer[0]           $mark_cache_size                  = 5368709120, # Must be ≥ 5GiB, direct config parameter
    Optional[Integer[0]] $uncompressed_cache_size          = undef,
    Optional[Integer[0]] $max_memory_usage_for_all_queries = undef,
    Optional[Integer[0]] $max_memory_usage                 = undef,
    Boolean              $use_uncompressed_cache           = true,
    Boolean              $external_group_by                = true,
    Boolean              $external_sort                    = true,
    Boolean              $memory_check                     = true,
    Boolean              $service_notify                   = $clickhouse::server::config_service_notify,
) inherits clickhouse::server {

    # Memory calculation
    if $mark_cache_size < 5 << 30 and $memory_check {
        notify { 'memory:mark_cache_size':
            message  => '$mark_cach_size is lower than recommended 5GiB.',
        }
    }

    $efficient_memory = $facts['memory']['system']['total_bytes'] - ($reserved_memory + $mark_cache_size)
    if ($efficient_memory <= 0) {
        clickhouse::error { 'This host doesn\'t have sufficient amount of RAM, OOMs are possible':
        }

        $max_memory_usage_for_all_queries_auto = 0
        $max_memory_usage_auto = 0
        $uncompressed_cache_size_auto = 8 << 30 # Default value from CH config
        $max_bytes_before_external_group_by = 0
        $max_bytes_before_external_sort = 0
    } else {
        # This block is trying setup memory consumption automatically if *_b parameters are unset
        $max_memory_usage_for_all_queries_auto = (!!$max_memory_usage_for_all_queries) ? {
            true    => $max_memory_usage_for_all_queries,
            default => (!!$uncompressed_cache_size) ? {
                true    => $efficient_memory - $uncompressed_cache_size,
                default => $efficient_memory * 5 / 6,
            }
        }

        $max_memory_usage_auto = (!!$max_memory_usage) ? {
            true    => $max_memory_usage,
            default => $max_memory_usage_for_all_queries_auto,
        }

        $uncompressed_cache_size_auto = (!!$uncompressed_cache_size) ? {
            true    => $uncompressed_cache_size,
            default => $efficient_memory - $max_memory_usage_for_all_queries_auto,
        }

        $max_bytes_before_external_group_by = $external_group_by ? {
            true    => $max_memory_usage_auto / 2,
            default => 0,
        }

        $max_bytes_before_external_sort = $external_sort ? {
            true    => $max_memory_usage_auto / 2,
            default => 0,
        }

        with($max_memory_usage_for_all_queries_auto + $uncompressed_cache_size_auto) |$used| {
            if $used != $efficient_memory and $memory_check {
                notify { 'ClickHouse memory config':
                    message  => "The memory configuration for ClickHouse is inefficient. Avaliable: ${efficient_memory}; used: ${used}",
                    loglevel => 'warning',
                }
            }
        }
    }

    $default_memory = {
        'profiles' => {
            'default' => {
                'use_uncompressed_cache'                   => [$use_uncompressed_cache],
                'max_memory_usage'                         => [$max_memory_usage_auto],
                'max_memory_usage_for_all_queries'         => [$max_memory_usage_for_all_queries_auto],
                'max_bytes_before_external_group_by'       => [$max_bytes_before_external_group_by],
                'max_bytes_before_external_sort'           => [$max_bytes_before_external_sort],
            },
        },
    }

    $memory_settings = {
        'uncompressed_cache_size' => [$uncompressed_cache_size_auto], # cache for short queries
        'mark_cache_size'         => [$mark_cache_size], # cache of "index"
    }

    clickhouse::server::config { 'default-memory':
        section        => 'users',
        data           => $default_memory,
        service_notify => $service_notify,
    }

    clickhouse::server::config { 'memory':
        section        => 'config',
        data           => $memory_settings,
        service_notify => $service_notify,
    }
}
