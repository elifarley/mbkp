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
  echo "call	call a pre- or post-backup hook"
  echo "config-new	create configuration for a new module"
  echo "config-backup	backup all configuration files"
  echo "config-restore	restore all configuration files"
  echo "config-edit	edit a configuration file"
  echo "help	show help on a given command"
  exit 1
}

EXP_help() {
  (($# >= 1)) || EXP_help_usage
  echo "Help on command '$1': To be implemented"
}

EXP_help_usage() {
  echo "$0 help <topic>"
  echo
  echo "show help on a topic"
  echo
  exit 1
}

EXP_backup_modules_usage() {
  echo "$0 backup <module-1> [<module-2> ...]"
  echo
  echo "perform a backup"
  echo
  exit 1
}

EXP_status_usage() {
  echo "$0 status <module> [<param> ...]"
  echo
  echo "list changed files"
  echo
  exit 1
}

EXP_list_usage() {
  echo "$0 list [<module>] [<param> ...]"
  echo
  echo "list files contained in a backup"
  echo
  exit 1
}

EXP_verify_usage() {
  echo "$0 verify <module> [<param> ...]"
  echo
  echo "verify files contained in a backup against those at the source"
  echo
  exit 1
}

EXP_restore_usage() {
  echo "$0 restore <module> [<param> ...]"
  echo
  echo "restore files"
  echo
  exit 1
}

EXP_call_usage() {
  echo "$0 call <module> <hook-type>"
  echo
  echo "call a pre- or post-backup hook"
  echo
  echo "A hook is executed before or after a backup is performed. <hook-type> can be 'pre' or 'post'"
  exit 1
}

EXP_config_new_usage() {
  echo "$0 config-new <module>"
  echo
  echo "create configuration for a new module"
  echo
  exit 1
}

EXP_config_backup_usage() {
  echo "$0 config-backup [<target-dir>]"
  echo
  echo "backup all configuration files to a compressed unencrypted tar archive"
  echo
  exit 1
}

EXP_config_restore_usage() {
  echo "$0 config-restore [<target-file>]"
  echo
  echo "restore all configuration files from a compressed unencrypted tar archive"
  echo
  exit 1
}

EXP_config_edit_usage() {
  echo "$0 config-edit <module>"
  echo
  echo "edit the configuration for a given module"
  echo
  exit 1
}

module_not_found() {
  echo "Module not found: $module"
  echo "Please create the file '$MBKP_CONFIG_BASE/$module.conf' or '$MBKP_CONFIG_BASE/priv/$module.conf'"
  exit 1
}