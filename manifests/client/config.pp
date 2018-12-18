# This type creates custom configuration files for clickhouse-client.
#
# @summary generates xml config from hash via ruby xml-simple
#
# @param data
#   This hash will be converted into xml config placed in `$clickhouse::client::conf_d_dir`.
#
#   Root will be `<config>` by default.
# @param ensure
#   Subset of attribute `ensure` for `file` resource.
# @param mode
#   Desired permissions mode for the config file, see `mode` attribute for `file` resource.
#
# @example Usage
#   clickhouse::client::config { 'prompt':
#     data => {'prompt_by_server_display_name' => [{
#         'experimental' => ['{display_name} \x01\e[1;35m\x02:)\x01\e[0m\x02 '],
#     }]},
#   }
#   #
#   # Will create file `/etc/clickhouse-client/conf.d/prompt.xml`:
#   # <config>
#   #   <prompt_by_server_display_name>
#   #     <experimental>{display_name} \x01\e[1;35m\x02:)\x01\e[0m\x02 </experimental>
#   #   </prompt_by_server_display_name>
#   # </config>
#
# @author InnoGames GmbH
#
define clickhouse::client::config (
    Hash      $data,
    Enum[
        'present',
        'file',
        'absent'
    ]         $ensure = 'present',
    String[1] $mode   = '0644',
) {

    include clickhouse::client

    file { "${clickhouse::client::conf_d_dir}/${title}.xml":
        ensure  => $ensure,
        content => hash_to_xml($data, {'RootName' => 'config'}),
        mode    => $mode,
        owner   => $clickhouse::user,
        group   => $clickhouse::group,
        require => Package[$clickhouse::client::package_name],
    }
}
