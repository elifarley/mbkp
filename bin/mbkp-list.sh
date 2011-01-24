#!/bin/sh

[ "$#" -lt 1 ] && {
  module="--all"
} || module="$1"

BASEDIR="$(dirname $(readlink $0))"

. "$BASEDIR/../priv/priv-config.sh"
. "$BASEDIR/../mbackup-config.sh"

DUPLICITY="duplicity"

_module_cache="$SYNC_ROOT/$module"
mbkp_target="$module"

[ "$module" == "--all" ] && {

  du -hs $HOME/.mbackup/data/*

} || {

  PASSPHRASE=$PASSPHRASE $DUPLICITY list-current-files -v8 \
--name "$module" \
--archive-dir=$HOME/.mbackup/cache/duplicity-archive \
"$MBKP_BASE_TARGET/$mbkp_target"

}
