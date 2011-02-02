#!/bin/sh

[ "$#" -lt 1 ] && {
  module="--all"
} || module="$1"; shift


BASEDIR="$(readlink $0)" || BASEDIR="$0"
BASEDIR="$(dirname $BASEDIR)"

. "$BASEDIR/functions"

init
init_module

[ "$module" == "--all" ] && {

  du -hs $(dirname $mbkp_full_target | cut -c 8-)/* | awk -F/ '{ print $NF,$1 }'

} || {

  dupl list-current-files -v8 "$@" "$mbkp_full_target"

}
