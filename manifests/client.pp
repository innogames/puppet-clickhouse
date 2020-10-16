# The class installs clickhouse-client.
#
# @summary ClickHouse client class
#
# @param package_name
#   Package to be installed.
# @param package_ensure
#   Client package `ensure`. See `ensure` attribute for `package` resource.
# @param conf_d_dir
#   Deprecated, use config_d_dir.
# @param config_d_dir
#   Directory for custom configs. Unmanaged configs will be removed from the dirrectory during puppet running.
#
# @example Simple use
#   include clickhouse::client
#
# @example Use with params
#   class { 'clickhouse::client':
#     package_name   => 'clickhouse-client-custom',
#     package_ensure => 'hold',
#     user           => 'custom-user',
#     config_d_dir   => '/some/path',
#   }
#
# @author InnoGames GmbH
#
class clickhouse::client(
    String[1]                  $package_name   = 'clickhouse-client',
    String[1]                  $package_ensure = 'installed',
    Optional[Stdlib::Unixpath] $conf_d_dir     = undef,
    Stdlib::Unixpath           $config_d_dir   = $conf_d_dir ? {
        undef   => '/etc/clickhouse-client/config.d',
        default => $conf_d_dir,
    },
) inherits clickhouse {

    package { $package_name:
        ensure => $package_ensure,
    }

    # TODO: remove it in 3 releases
    if ($conf_d_dir) {
        notify { 'conf_d deprecation':
            message  => @("END")
                Parameter conf_d_dir is deprecated, use config_d_dir
                Be aware that after remove it the ${conf_d_dir} will be removed as well, you shouldn't use it.
                See https://clickhouse.yandex/docs/en/operations/configuration_files
                | END
            ,
            loglevel => 'warning',
        }

        file { $conf_d_dir:
            ensure  => 'directory',
            require => Package[$package_name],
        }

    } else {
        file { '/etc/clickhouse-client/conf.d':
            ensure => 'absent',
            force  => true,
        }

        file { $config_d_dir:
            ensure  => 'directory',
            recurse => true,
            purge   => true,
            force   => true,
            require => Package[$package_name],
        }
    }
}
