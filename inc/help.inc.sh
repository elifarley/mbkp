usage() {
  cat <<USAGE
MBKP - Modular Backup
Usage:
$0 <command> [<param1> <param2> ...]

Basic commands:

backup  perform a full or incremental backup
status  show missing, new and modified files
list    show all files in backup
verify  verify the integrity of the repository
restore restore a backup
call    call a hook
log     list the chains and sets in the backup repository
cache-size    show cache sizes
cache-zap     zap cache data
config-new    create configuration for a new module
config-export export all configuration files
config-import import all configuration files
config-edit   edit a configuration file
db-dump       dump database to file
db-import     import database from file
help    show help on a given command
version output version and copyright information
USAGE
  exit 1
}

EXP_version() {
  cat <<VERSION
mbkp - Modular Backup (version 0.1.1-SNAPSHOT)

Copyright (C) 2010-2011 Elifarley Cruz
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

VERSION
  ((_verbose)) || return 0
  duplicity --version | sed -n '1 p'
  python --version | sed -n '1 p'
  echo "Bash: $BASH_VERSION"
  sed --version | sed -n '1 p'
  cut --version | sed -n '1 p'
  tr --version | sed -n '1 p'
  uname -a
}

EXP_help() {
  (($# >= 1)) || EXP_help_usage
  echo "Help on command '$1': To be implemented"
}

EXP_help_usage() {
  cat <<HELP
$0 help <topic>

show help on a topic

HELP
  exit 1
}

EXP_backup_modules_usage() {
  cat <<BACKUP_MODULES
$0 backup <module-1> [<module-2> ...]

perform a backup

BACKUP_MODULES
  exit 1
}

EXP_status_usage() {
  cat <<STATUS
$0 status <module> [<param> ...]

show missing, new and modified files in the working directory

If a given file exists both in the source dir and in the last backup, compare the modification time from source against the corresponding modification time as recorded in the last backup.
If they are the same, the file is not listed (not even if the file content has changed)
STATUS
  exit 1
}

EXP_list_usage() {
  cat <<LIST
$0 list <module> [<param> ...]

list files contained in a backup

LIST
  exit 1
}

EXP_verify_usage() {
  cat <<VERIFY
$0 verify <module> [<param> ...]

verify the integrity of the repository

All archive files from the backup repository will be downloaded, decrypted and decompressed.
Then, a checksum will be computed over the decompressed contents and verified against the originally recorded checksum
Source files WILL NOT BE read at all.
VERIFY
  exit 1
}

EXP_restore_usage() {
  cat <<RESTORE
$0 restore <module> [--restore-target <path>] [--force] [<param> ...]

restore files
If '--restore-target' is omitted, files will be restored to <mbk_source> (defined in the module configuration).
If the restore target folder isn't empty, nothing will be done unless you use the '--force' switch

RESTORE
  exit 1
}

EXP_call_usage() {
  cat <<CALL
$0 call <module> <hook-type>

call a hook

Hook are executed before and after a backup or a restore is performed.
<hook-type> can be: 'pre-backup', 'post-backup', 'pre-restore' and 'post-restore'

CALL
  exit 1
}


EXP_log_usage() {
  cat <<LOG
$0 log <module>

list the chains and sets in the backup repository, and the number of volumes in each.
LOG
  exit 1
}

EXP_cache_size_usage() {
  cat <<CACHE_SIZE
$0 cache-size [<module>]

show cache size for a given module. If no module is given, all modules are shown

CACHE_SIZE
  exit 1
}

EXP_cache_zap_usage() {
  cat <<CACHE_ZAP
$0 cache-zap <module>

zap cache data for a given module

CACHE_ZAP
  exit 1
}

EXP_config_new_usage() {
  cat <<CONFIG_NEW
$0 config-new <module>

create configuration for a new module

CONFIG_NEW
  exit 1
}

EXP_config_export_usage() {
  cat <<CONFIG_EXPORT
$0 config-export [<target-dir>]

export all configuration files to an mbkp configuration archive

CONFIG_EXPORT
  exit 1
}

EXP_config_import_usage() {
  cat <<CONFIG_IMPORT
$0 config-import [<target-file>]

import all configuration files from an mbkp configuration archive

CONFIG_IMPORT
  exit 1
}

EXP_config_edit_usage() {
  cat <<CONFIG_EDIT
$0 config-edit <module>

edit the configuration for a given module or the main one

CONFIG_EDIT
  exit 1
}

EXP_db_dump_usage() {
  cat <<DB_DUMP
$0 db-dump <module>

dump database to file

DB_DUMP
  exit 1
}

EXP_db_import_usage() {
  cat <<DB_IMPORT
$0 db-import <module>

import database from file

DB_IMPORT
  exit 1
}

config_not_found() {
  local _config_not_enabled="${1:-0}"; shift

  if ((_config_not_enabled)); then
    cat <<CNE
mbkp configuration NOT ENABLED.
Please enable it by removing the line that reads 'MBKP_FIRST_RUN'.
To edit the configuration file, just type the command below:
CNE
  else
    echo "mbkp configuration not found.
Please create the configuration file by typing the command below:"
  fi

  cat <<CNF

-------------------------------------------
$0 config-edit
-------------------------------------------
CNF
  exit 1
}

module_not_found() {
  cat <<MNF
Module not found: '$module'
Please create this module by typing the command below:

-------------------------------------------
$0 config-new $module
-------------------------------------------
MNF
  exit 1
}