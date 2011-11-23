usage() {
  echo "MBKP - Modular Backup"
  echo "Usage:"
  echo "$0 <command> [<param1> <param2> ...]"
  echo
  echo "Basic commands:"
  echo
  echo "backup  perform a full or incremental backup"
  echo "status  show changed files in the working directory"
  echo "list    show all files in backup"
  echo "verify  verify the integrity of the repository"
  echo "restore restore a backup"
  echo "call    call a pre- or post-backup hook"
  echo "log     list the chains and sets in the backup repository"
  echo "cache-size    show cache sizes"
  echo "cache-zap     zap cache data"
  echo "config-new    create configuration for a new module"
  echo "config-export export all configuration files"
  echo "config-import import all configuration files"
  echo "config-edit   edit a configuration file"
  echo "help    show help on a given command"
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
  echo "$0 list <module> [<param> ...]"
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
  echo "$0 restore <module> [--restore-target <path>] [--force] [<param> ...]"
  echo
  echo "restore files"
  echo "If '--restore-target' is omitted, files will be restored to <mbk_source> (defined in the module configuration)."
  echo "If the restore target folder isn't empty, nothing will be done unless you use the '--force' switch"
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


EXP_log_usage() {
  echo "$0 log <module>"
  echo
  echo "list the chains and sets in the backup repository, and the number of volumes in each."
  echo
  exit 1
}

EXP_cache_size_usage() {
  echo "$0 cache-size [<module>]"
  echo
  echo "show cache size for a given module. If no module is given, all modules are shown"
  echo
  exit 1
}

EXP_cache_zap_usage() {
  echo "$0 cache-zap <module>"
  echo
  echo "zap cache data for a given module"
  echo
  exit 1
}

EXP_config_new_usage() {
  echo "$0 config-new <module>"
  echo
  echo "create configuration for a new module"
  echo
  exit 1
}

EXP_config_export_usage() {
  echo "$0 config-export [<target-dir>]"
  echo
  echo "export all configuration files to an mbkp configuration archive"
  echo
  exit 1
}

EXP_config_import_usage() {
  echo "$0 config-load [<target-file>]"
  echo
  echo "import all configuration files from an mbkp configuration archive"
  echo
  exit 1
}

EXP_config_edit_usage() {
  echo "$0 config-edit <module>"
  echo
  echo "edit the configuration for a given module or the main one"
  echo
  exit 1
}

config_not_found() {
  local _config_not_enabled="${1:-0}"; shift

  if ((_config_not_enabled)); then
    echo "mbkp configuration NOT ENABLED."
    echo "Please enable it by removing the line that reads 'MBKP_FIRST_RUN'."
    echo "To edit the configuration file, just type the command below:"
  else
    echo "mbkp configuration not found."
    echo "Please create the configuration file by typing the command below:"
  fi
  echo
  echo '-------------------------------------------'
  echo "$0 config-edit"
  echo '-------------------------------------------'
  exit 1
}

module_not_found() {
  echo "Module not found: '$module'"
  echo "Please create this module by typing the command below:"
  echo
  echo '-------------------------------------------'
  echo "$0 config-new $module"
  echo '-------------------------------------------'
  exit 1
}