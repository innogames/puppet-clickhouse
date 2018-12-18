# Top level class for ClickHouse DBMS installation and management.
#
# @summary this class allows you to install ClickHouse DB's repo, client and server
#
# @param server [Boolean]
#   Is clickhouse-server should be installed or not. It won't be installed by default, because some time you need the client only.
# @param client [Boolean]
#   Is clickhouse-client should be installed or not.
# @param manage_repo [Boolean]
#   Is apt or yum repository should be managed. Set to `false` by default to not affect your own repositories policy.
# @param user
#   User for configs owning. Strongly recommended staying default.
#
#   It's highly unrecommended to change default user, but feel free to shot in a knee.
#   You have to adjust as well the data directory and the whole configs everywhere.
# @param group
#   Group for configs, see `user` parameter.
#
# @example Simple use
#   include clickhouse
#
# @example Install server and client
#   class { 'clickhouse':
#     server => true,
#   }
#
# @example Install everything and manage repository
#   class { 'clickhouse':
#     server      => true,
#     client      => true,
#     manage_repo => true,
#   }
#
# @author InnoGames GmbH
#
class clickhouse (
    Boolean   $server      = false,
    Boolean   $client      = true,
    Boolean   $manage_repo = false,
    String[1] $user        = 'clickhouse',
    String[1] $group       = $user,
) {

    if $server {
        include clickhouse::server
    }

    if $client {
        include clickhouse::client
    }

    if $manage_repo {
        include clickhouse::repo
    }
}
