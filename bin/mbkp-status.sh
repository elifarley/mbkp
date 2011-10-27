#!/bin/sh

module="$1"; shift

CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
. "$CMD_BASE/functions"

init
init_module

echo "collection-status:" && dupl collection-status -v8 "$@" "$mbkp_full_target"
echo "verify:" && dupl verify -v8 $includes $excludes "$@" "$mbkp_full_target" "$mbkp_src"
