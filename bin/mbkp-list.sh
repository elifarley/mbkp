#!/bin/sh

module="${1:---all}"; shift

CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
. "$CMD_BASE/functions"

init
init_module

[ "$module" == "--all" ] && {

  du -hs $(dirname $mbkp_full_target | cut -c 8-)/* | awk -F/ '{ print $NF,$1 }'

} || {

  echo "list-current-files:" && dupl list-current-files -v8 "$@" "$mbkp_full_target"

}
