# @summary Define ClickHouse users
#
# This type defines the ClickHouse users with specified parameters
#
# @param networks
#   Defines network nodes where from user could connect
#
# @param profile
#   User profile
#
# @param quota
#   User quota
#
# @param user
#   User name
#
# @param password
#   Plaintext password. Will be hashed into sha256 format in xml file
#
# @param access_management
#   Parameter to grant access to SQL-driven access control and account management
#
# @param password_sha256
#   Optional parameter. If defined, `$password` must not be defined
#
# @param databases
#   Optional hash of allowed DBs, tables and filters to implement ACLs
#
# @param allow_databases
#   Optional parameter to restrict access to specified databases
#
# @param allow_dictionaries
#   Optional parameter to restrict access to specified dictionaries
#
# @see https://clickhouse.tech/docs/en/operations/settings/settings_users/, https://clickhouse.tech/docs/v20.3/en/operations/access_rights/
#
# @example
#   clickhouse::server::config::user { 'username':
#       network            => {
#           'ip'          => [
#               '::',
#               '0.0.0.0',
#           ],
#           'host'        => [
#               'host1.local',
#               'host2.local',
#           ],
#           'host_regexp' => [
#               '[^.]*\.domain\.TLD',
#           ],
#       },
#       profile            => 'profile_name',
#       quota              => 'quota_name',
#       password           => 'password',
#       access_management  => 1,
#       databases          => {
#           'db_name' => {
#               'table_name'         => ['filter'],
#               'another_table_name' => ['another filter'],
#           },
#       },
#   }
#
# @author InnoGames GmbH
#
define clickhouse::server::config::user (
    Struct[{
        Optional[ip]          => Array[String[1], 1],
        Optional[host]        => Array[String[1], 1],
        Optional[host_regexp] => Array[String[1], 1],
    }]                         $networks,
    String[1]                  $profile            = 'default',
    String[1]                  $quota              = 'default',
    String[1]                  $user               = $title,
    String[0]                  $password           = '',
    Integer[0,1]               $access_management  = 0,
    Optional[
        Pattern[/\A[0-9a-fA-F]{64}\Z/]
    ]                          $password_sha256    = undef,
    Optional[Hash]             $databases          = undef,
    Optional[Array[String[1]]] $allow_databases    = undef,
    Optional[Array[String[1]]] $allow_dictionaries = undef,
) {

    if ($password != '' and $password_sha256 != undef) {
        fail('Only one of $password or $password_sha256 must be defined')
    }

    $user_data = {
        'users' => {
            $user                        => {
                'password_sha256_hex' => $password_sha256 ? {
                    undef   => [sha256($password)],
                    default => [$password_sha256],
                },
                'networks'            => $networks,
                'profile'             => [$profile],
                'quota'               => [$quota],
                'access_management'   => [$access_management],
            } + ( $databases ? {
                undef   => {},
                default => {'databases' => $databases},
            }) + ( $allow_databases ? {
                undef   => {},
                default => {
                    'allow_databases' => {
                        'database' => $allow_databases,
                    },
                },
            }) + ( $allow_dictionaries ? {
                undef   => {},
                default => {
                    'allow_dictionaries' => {
                        'dictionary' => $allow_dictionaries,
                    },
                },
            }),
        }
    }

    if empty($networks) {
        clickhouse::error { "User data for ${user} is invalid. \$networks should contain at least one element":
        }
    } else {
        clickhouse::server::config { "user-${user}":
            section => 'users',
            data    => $user_data,
        }
    }
}
