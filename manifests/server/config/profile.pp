# @summary Define ClickHouse profile
#
# This type defines the ClickHouse profile with specified options
#
# @param profile
#   User profile
#
# @param settings
#   Profile settings
#
# @see https://clickhouse.tech/docs/en/operations/settings/settings
#
# @example
#   clickhouse::server::config::profile { 'profile_name':
#       databases => {
#           'db_name' => {
#               'table_name'         => ['filter'],
#               'another_table_name' => ['another filter'],
#           },
#       },
#   }
#
# @author InnoGames GmbH
#
define clickhouse::server::config::profile (
    Hash      $settings,
    String[1] $profile   = $title,
) {

    with({
        'profiles' => { $profile => $settings }
    }) |$data| {
        clickhouse::server::config { "profile-${$profile}":
            section => 'users',
            data    => $data,
        }
    }

    # All profiles must be applied before any users to not cause Zalgo
    Clickhouse::Server::Config::Profile <| |> -> Clickhouse::Server::Config::User <| |>
}
