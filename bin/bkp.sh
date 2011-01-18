#!/bin/sh

BASEDIR="$(dirname $0)"
set -x
module="$1"; shift

. "$BASEDIR/../bkp-config.sh"
. "$BASEDIR/../modules/$module.sh"
. "$BASEDIR/../priv/passwords.sh"

includes="$BASEDIR/../modules/$module.includes"
excludes="$BASEDIR/../modules/$module.excludes"

PASSPHRASE=$PASSPHRASE duplicity -v5 --name "$module" \
--exclude-other-filesystems \
--full-if-older-than $full_if_older_than \
--include-globbing-filelist "$includes" \
--exclude-globbing-filelist "$excludes" \
$extra "$SRC" "$BKP_BASE/$TARGET" 
