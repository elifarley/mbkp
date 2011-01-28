#!/bin/bash
[ "$#" -lt 1 ] && {
  echo "Usage:"
  echo "$0 <module-name-1> [<module-name-2>] ..."
  exit 1
}

VERBOSE=0

BASEDIR="$(readlink $0)" || BASEDIR="$0"
BASEDIR="$(dirname $BASEDIR)"

module="$1"; shift

. "$BASEDIR/functions"

init

echo "=================================================="
echo "Backup STARTED for module $module"
echo "=================================================="

init_module
pre_module_backup
do_backup "$mbkp_src" "$mbkp_full_target"
post_module_backup

[ -z "$FAILED" ] || {
  echo "##################################################"
  echo "############################# FAILED '$FAILED' !"
  echo "##################################################"
  exit 1
}

exit 0
