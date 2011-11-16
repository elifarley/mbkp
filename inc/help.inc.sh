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

EXP_help() {
  (($# >= 1)) || EXP_help_usage
  echo "Help on command '$1': To be implemented"
}

EXP_help_usage() {
  echo "Usage:"
  echo "$0 help <topic>"
  exit 1
}

EXP_backup_modules_usage() {
  echo "Usage:"
  echo "$0 backup <module-1> [<module-2> ...]"
  exit 1
}

EXP_status_usage() {
  echo "Usage:"
  echo "$0 status <module> [<param> ...]"
  exit 1
}

EXP_list_usage() {
  echo "Usage:"
  echo "$0 list [<module>] [<param> ...]"
  exit 1
}

EXP_verify_usage() {
  echo "Usage:"
  echo "$0 verify <module> [<param> ...]"
  exit 1
}

EXP_restore_usage() {
  echo "Usage:"
  echo "$0 restore <module> [<param> ...]"
  exit 1
}

EXP_call_usage() {
  echo "Usage:"
  echo "$0 call <module> <hook-type>"
  echo "<hook-type> can be 'pre' or 'post'"
  exit 1
}

module_not_found() {
  echo "Module not found: $module"
  echo "Please create the file '$MBKP_CONFIG_BASE/$module.conf' or '$MBKP_CONFIG_BASE/priv/$module.conf'"
  exit 1
}