#!/bin/sh
CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
. "$CMD_BASE/functions"

module="$1"; shift

init
init_module

echo "status:" && dupl -v8 --dry-run "${file_selection[@]}" "$@" "$mbkp_src" "$mbkp_full_target"
