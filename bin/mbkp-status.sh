#!/bin/sh
CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
. "$CMD_BASE/functions"

module="$1"; shift

init
init_module

echo "verify:" && dupl verify -v8 $file_selection "$@" "$mbkp_full_target" "$mbkp_src"
