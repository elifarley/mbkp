#!/bin/bash
[ "$#" -lt 1 ] && {
  echo "Usage:"
  echo "$0 <module-name-1> [<module-name-2>] ..."
  exit 1
}

VERBOSE=0

module="$1"; shift

CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
. "$CMD_BASE/functions"

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
