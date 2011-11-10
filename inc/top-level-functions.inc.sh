usage() {
  echo "MBKP - Modular Backup"
  echo "Usage:"
  echo "$0 <command> [<param1> <param2> ...]"
  echo
  echo "Basic commands:"
  echo
  echo "backup	perform a full or incremental backup"
  echo "status	show changed files in the working directory"
  echo "list	show all files in backup"
  echo "verify	verify the integrity of the repository"
  echo "restore	restore a backup"
  echo "help	show help on a given command"
  exit 1
}

EXP_backup_modules() {
  local failed_modules=()
  for module in "$@"; do
    backup_single_module "$module"
    [ -z "$FAILED" ] || failed_modules+=("$FAILED")
  done

  [ -z "$failed_modules" ] || {
    echo "#################################################################"
    echo "############################# FAILED MODULES: '${failed_modules[@]}' !"
    echo "#################################################################"
    exit 1
  }

}

EXP_status() {
  module="$1"; shift
  init_module
  dupl -v8 --dry-run "${file_selection[@]}" "$@" "$mbkp_src" "$mbkp_full_target"
}

EXP_list() {
  module="$1"; shift
  init_module
  dupl list-current-files -v8 "$@" "$mbkp_full_target"
}

EXP_verify() {
  module="$1"; shift
  init_module
  dupl verify -v8 "${file_selection[@]}" "$@" "$mbkp_full_target" "$mbkp_src"
}

EXP_restore() {
  module="$1"; shift
  init_module
  dupl restore -v8 "$mbkp_full_target" "$@"
}
