EXP_backup_modules() {
  (($#)) || EXP_backup_modules_usage

  local args=()
  local opts=()
  while (($#)); do
    [[ $1 == -* ]] && opts+=("$1") || args+=("$1")
    shift
  done

  local failed_modules=()
  for module in "${args[@]}"; do
    backup_single_module "$module" "${opts[@]}"
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
  (($#)) || EXP_status_usage
  init_module "$1"; shift
  if ((_has_dry_run)); then
    dupl -v5 --dry-run $extra "${_file_selection[@]}" "$@" "$mbkp_src" "$mbkp_full_target"
  else
    echo "'--dry-run' not available. Will have to download all backup archives from the repository"
    dupl verify -v4 "${_file_selection[@]}" "$@" "$mbkp_full_target" "$mbkp_src"
  fi
}

EXP_list() {
  (($#)) || EXP_list_usage
  init_module "$1"; shift
  dupl list-current-files "$@" "$mbkp_full_target"
}

EXP_verify() {
  (($#)) || EXP_verify_usage
  init_module "$1"; shift
  dupl verify -v4 "${_file_selection[@]}" "$@" "$mbkp_full_target" "$mbkp_src"
}

EXP_restore() {
  (($#)) || EXP_restore_usage
  local _restore_target=''

  local args=()
  local opts=()
  while (($#)); do
    case "$1" in
      --restore-target)
        (($# > 1)) || { echo "--restore-target: missing arg"; exit 1; }
        _restore_target="$2"; shift
        ;;
      *)
        [[ $1 == -* ]] && opts+=("$1") || args+=("$1")
      ;;
    esac
    shift
  done

  ((${#args[@]} == 1)) || {
    echo "Exactly one module name must be given";
    echo "Modules given: ${args[@]}"
    exit 1
  }

  init_module "${args[0]}"
  [[ -n $_restore_target ]] || _restore_target="$mbkp_src"

  pre_module_restore
  dupl restore -v5 "${opts[@]}" "$mbkp_full_target" "$_restore_target"
  post_module_restore
}

EXP_log() {
  (($#)) || EXP_log_usage
  init_module "$1"; shift
  init_module "$module"
  dupl collection-status "$@" "$mbkp_full_target"
}

EXP_call() {
  (($# == 2)) || EXP_call_usage
  init_module "$1"; shift
  hook_type="$1"; shift

  case "$hook_type" in
    pre-backup)
      pre_module_backup
      ;;
    post-backup)
      post_module_backup
      ;;
    pre-restore)
      pre_module_restore
      ;;
    post-restore)
      post_module_restore
      ;;
    *)
      echo "mbkp: unknown hook type '$hook_type'"
      EXP_call_usage
      ;;
  esac

}

EXP_cache_size() {
  init_config
  module="$1"; shift
  if [[ -z "$module" ]]; then
    echo
    echo "Duplicity caches:"
    du -hs $MBKP_ARCHIVE/* | awk -F/ '{ print $NF,$1 }'
    echo '-----------------'
    echo
    echo "Module caches:"
    du -hs $MBKP_MODULE_CACHE_BASE/* | awk -F/ '{ print $NF,$1 }'
  else
    local _cache
    _cache="$MBKP_ARCHIVE/$module"
    [[ -d $_cache ]] && echo -n "Duplicity cache: " && \
    du -hs "$_cache" | awk -F/ '{ print $NF,$1 }' || {
      echo "no cache found at $_cache"
    }

    _cache="$MBKP_MODULE_CACHE_BASE/$module"
    [[ -d $_cache ]] && echo -n "Module cache   : " && \
    du -hs "$_cache" | awk -F/ '{ print $NF,$1 }' || {
      echo "no cache found at $_cache"
    }
  fi
}

EXP_cache_zap() {
  (($# == 1)) || EXP_cache_zap_usage
  module="$1"; shift
  init_config

  echo -n "Duplicity cache: "
  du -hs "$MBKP_ARCHIVE/$module" | awk -F/ '{ print $NF,$1 }'
  echo -n "Module cache   : "
  du -hs "$MBKP_MODULE_CACHE_BASE/$module" | awk -F/ '{ print $NF,$1 }'

  local _cache
  _cache="$MBKP_ARCHIVE/$module"
  [[ -d $_cache ]] && rm -rf "$_cache" && echo "cache deleted: $_cache"

  _cache="$MBKP_MODULE_CACHE_BASE/$module"
  [[ -d $_cache ]] && rm -rf "$_cache" && echo "cache deleted: $_cache"
}

EXP_config_new() {
  (($#)) || EXP_config_new_usage
  init_config
  module="$1"; shift
  new_module "$module"
}

EXP_config_export() {
  init_config
  local archive_file="${1:-$MBKP_LOCAL_BACKUPS_BASE/mbkp-config.tbz}"; shift
  tar -jcvf "$archive_file" -C "$(dirname $MBKP_CONFIG_BASE)" mbkp || exit $?
  echo "mbkp configuration files exported to '$archive_file'"
}

EXP_config_import() {
  init_config 1
  local archive_file="${1:-$MBKP_LOCAL_BACKUPS_BASE/mbkp-config.tbz}"; shift
  [[ -f $archive_file ]] || {
    echo "File not found: '$archive_file'"
    echo "Please specify a configuration archive to import. Usage:"
    echo
    EXP_config_import_usage
  }
  tar -jxvf "$archive_file" -C "$(dirname $MBKP_CONFIG_BASE)" || exit $?
  echo "mbkp configuration files imported to '$(dirname $MBKP_CONFIG_BASE)'"
}

EXP_config_edit() {
  local file=''
  if (($#)); then
    init_module "$1"; shift
    file="modules/$module.conf"
  else
    init_config 1
    file="mbkp.conf"
  fi

  ${EDITOR:-vim} "$MBKP_CONFIG_BASE/$file"
}
