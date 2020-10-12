# clickhouse::server::config::zookeeper
# Set proper zookeeper config
#
# @summary Set proper zookeeper config
#
# @param nodes
#   hash of `zk_server`: `id` to define nodes
#
# @param port
#   cilent port of zookeeper cluster
#
# @param session_timeout_ms
#   maximum timeout for client session in milliseconds
#
# @param operation_timeout_ms
#   maximum timeout for operation in milliseconds
#
# @param root
#   ZNode, that is used as root for znodes used by ClickHouse server
#
# @param user
#   user if zookeeper uses authorization
#
# @param password
#   password if zookeeper uses authorization
#
# @param mode
#   zookeeper nodes, ports and optional user and password are confidential data and normally should not be readable
#
# @param service_notify
#   If ClickHouse server should be restarted on the config update
#
# @example Use with params
#   class { 'clickhouse::server::config::zookeeper':
#       nodes    => { 'server1' => 1},
#       user     => 'user',
#       password => 'password',
#   }
#
# @author InnoGames GmbH
#
class clickhouse::server::config::zookeeper (
    Hash[String[1], Integer[1, 255]] $nodes,
    Integer[1, 65536]                $port                 = 2181,
    Integer[1]                       $session_timeout_ms   = 30000,
    Integer[1]                       $operation_timeout_ms = 10000,
    Optional[Stdlib::Unixpath]       $root                 = undef,
    Optional[String[1]]              $user                 = undef,
    Optional[String[1]]              $password             = undef,
    String[1]                        $mode                 = '0440',
    Boolean                          $service_notify       = $clickhouse::server::config_service_notify,
) inherits clickhouse::server {

    $zookeeper_data = {
        'zookeeper' => merge(
            {
                'node'                 => $nodes.map |$node, $id| {{
                    'index' => $id,
                    'host'  => [$node],
                    'port'  => [$port],
                }},
                'session_timeout_ms'   => [$session_timeout_ms],
                'operation_timeout_ms' => [$operation_timeout_ms],
            },
            $root ? {
                undef   => {},
                default => {'root' => [$root]},
            },
            ($user == undef or $password == undef) ? {
                true    => {},
                default => {'identity' => ["${user}:${password}"]},
            },
        )
    }

    clickhouse::server::config { 'zookeeper':
        section        => 'config',
        data           => $zookeeper_data,
        service_notify => $service_notify,
        mode           => $mode,
    }
}
