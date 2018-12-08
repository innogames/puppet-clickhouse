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
# @param conf_dir
#   Directory with clickhouse-server configuration.
# @param conf_d_dir
#   Directory with clickhouse-server included configuration.
# @param users_d_dir
#   Directory with clickhouse-server users configuration.
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
    String[1]        $package_name   = 'clickhouse-server',
    String[1]        $package_ensure = 'installed',
    String[1]        $service_name   = $package_name,
    Variant[Boolean, Enum[
        'running',
        'stopped'
    ]]               $service_ensure = 'running',
    Variant[Boolean, Enum[
        'manual',
        'mask'
    ]]               $service_enable = true,
    Stdlib::Unixpath $conf_dir       = '/etc/clickhouse-server',
    Stdlib::Unixpath $conf_d_dir     = "${conf_dir}/conf.d",
    Stdlib::Unixpath $users_d_dir    = "${conf_dir}/users.d",
) inherits clickhouse {

    package { $package_name:
        ensure => $package_ensure,
    }

    file { [$conf_d_dir, $users_d_dir]:
        ensure  => 'directory',
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
