#!/bin/bash
[ "$#" -lt 1 ] && {
  echo "Usage:"
  echo "$0 <module-name-1> [<module-name-2>] ..."
  exit 1
}

CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
. "$CMD_BASE/functions"

VERBOSE=0

EXP_backup_modules "$@"

exit 0
