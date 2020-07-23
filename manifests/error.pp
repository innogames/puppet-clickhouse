# clickhouse::error
# Implements error which cause 6 exit code with `--detailed-exitcodes` argument for `puppet run`.
# Work around notifying about severe problem
# @see https://tickets.puppetlabs.com/browse/PUP-9208?focusedCommentId=703786#comment-703786
#
# @summary Implements error logging with continue of manifests application
#
# @raise $title error
#
# @example Simple use
#   clickhouse::error { 'Error message':
#   }
#
# @author InnoGames GmbH
#
define clickhouse::error(
) {

    exec { $title:
        command => '/$',
    }
}
