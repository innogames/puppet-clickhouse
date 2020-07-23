# clickhouse::server::config::default_localhost
# By default, ClickHouse listens only localhost and user `default` is able to connect from anywhere.
# This class, if included, restricts network access.
#
# @summary Restricts network access for `default`
#
# @example Simple use
#   include clickhouse::server::config::default_localhost
#
# @author InnoGames GmbH
#
class clickhouse::server::config::default_localhost inherits clickhouse::server {

    $config = {
        'users' => {
            'default' => {
                'networks' => {
                    'replace' => 'replace',
                    'host'    => ['localhost'],
                }
            }
        }
    }

    clickhouse::server::config { 'default-localhost':
        section => 'users',
        data    => $config,
    }
}
