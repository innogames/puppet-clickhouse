# The class installs ClickHouse server and manages service
#
# @summary ClickHouse server class
#
# @param package_name
#   Server package to be installed.
# @param package_ensure
#   Server package ensure. See `ensure` attribute for `package` resource.
# @param service_name
#   Name of the managed service for clickhouse-server.
# @param service_ensure
#   Desired state for `$service_name`, see `ensure` for `service` resource.
# @param service_enable
#   If `$service_name` should be enabled, see `enable` for `service` resource.
# @param config_service_notify
#   If true, every config managed by this module and requires for server restart will trigger service refresh.
# @param conf_dir
#   Deprecated, use config_dir
# @param config_dir
#   Directory with clickhouse-server configuration.
# @param conf_d_dir
#   Deprecated, use config_d_dir
# @param config_d_dir
#   Directory with clickhouse-server included configuration. Unmanaged configs will be removed from the directory during puppet run.
# @param users_d_dir
#   Directory with clickhouse-server users configuration. Unmanaged configs will be removed from the directory during puppet run.
#
# @example Simple use
#   include clickhouse::server
#
# @example Use with params
#   class { 'clickhouse::server':
#     package_name   => 'clickhouse-server-custom',
#     package_ensure => 'latest',
#     service_name   => 'clickhouse-server',
#     service_ensure => false,
#     service_enable => false,
#   }
#
# @author InnoGames GmbH
#
class clickhouse::server (
    String[1]                  $package_name          = 'clickhouse-server',
    String[1]                  $package_ensure        = 'installed',
    String[1]                  $service_name          = $package_name,
    Variant[Boolean, Enum[
        'running',
        'stopped'
    ]]                         $service_ensure        = 'running',
    Variant[Boolean, Enum[
        'manual',
        'mask'
    ]]                         $service_enable        = true,
    Boolean                    $config_service_notify = true,
    Optional[Stdlib::Unixpath] $conf_dir              = undef,
    Stdlib::Unixpath           $config_dir            = $conf_dir ? {
        undef   => '/etc/clickhouse-server',
        default => $conf_d_dir,
    },
    Optional[Stdlib::Unixpath] $conf_d_dir            = undef,
    Stdlib::Unixpath           $config_d_dir          = $conf_d_dir ? {
        undef   => "${config_dir}/config.d",
        default => $conf_d_dir,
    },
    Stdlib::Unixpath           $users_d_dir           = "${config_dir}/users.d",
) inherits clickhouse {

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
            recurse => true,
            purge   => true,
            force   => true,
            owner   => $clickhouse::user,
            group   => $clickhouse::group,
            require => Package[$package_name],
        }
    } else {
        file { "${config_dir}/conf.d":
            ensure => 'absent',
        }

        file { $config_d_dir:
            ensure  => 'directory',
            recurse => true,
            purge   => true,
            force   => true,
            owner   => $clickhouse::user,
            group   => $clickhouse::group,
            require => Package[$package_name],
        }
    }

    package { $package_name:
        ensure => $package_ensure,
    }

    file { $users_d_dir:
        ensure  => 'directory',
        recurse => true,
        purge   => true,
        force   => true,
        owner   => $clickhouse::user,
        group   => $clickhouse::group,
        require => Package[$package_name],
    }

    service { $service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        subscribe => Package[$package_name],
    }
}
