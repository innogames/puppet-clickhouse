# The class installs clickhouse-client.
#
# @summary ClickHouse client class
#
# @param package_name [String[1]]
#   Package to be installed.
# @param package_ensure [String[1]]
#   Client package `ensure`. See `ensure` attribute for `package` resource.
# @param conf_d_dir [Stdlib::Unixpath]
#   Directory for custom configs.
#
# @example Simple use
#   include clickhouse::client
#
# @example Use with params
#   class { 'clickhouse::client':
#     package_name   => 'clickhouse-client-custom',
#     package_ensure => 'hold',
#     user           => 'custom-user',
#     conf_d_dir     => '/some/path',
#   }
#
# @author InnoGames GmbH
#
class clickhouse::client(
    String[1]        $package_name   = 'clickhouse-client',
    String[1]        $package_ensure = 'installed',
    Stdlib::Unixpath $conf_d_dir     = '/etc/clickhouse-client/conf.d',
) inherits clickhouse {

    package { $package_name:
        ensure => $package_ensure,
    }

    file { $conf_d_dir:
        ensure  => 'directory',
        owner   => $clickhouse::user,
        group   => $clickhouse::group,
        require => Package[$package_name],
    }
}
