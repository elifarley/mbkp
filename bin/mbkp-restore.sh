#!/bin/sh

module="$1"; shift

BASEDIR="$(readlink $0)" || BASEDIR="$0"
BASEDIR="$(dirname $BASEDIR)"

. "$BASEDIR/functions"

init
init_module

dupl restore -v8 "$mbkp_full_target" "$@"
