#!/bin/sh

module="$1"; shift

BASEDIR="$(readlink $0)" || BASEDIR="$0"
BASEDIR="$(dirname $BASEDIR)"

. "$BASEDIR/functions"

init
init_module

dupl collection-status -v8 "$@" "$mbkp_full_target"
dupl verify -v8 $includes $excludes "$@" "$mbkp_full_target" "$mbkp_src"
