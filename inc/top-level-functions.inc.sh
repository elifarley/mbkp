EXP_backup_modules() {
  (($#)) || EXP_backup_modules_usage

  local args=()
  local options=()
  while (($#)); do
    [[ $1 == -* ]] && options+=("$1") || args+=("$1")
    shift
  done

  local failed_modules=()
  for module in "${args[@]}"; do
    backup_single_module "$module" "${options[@]}"
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
  assert_has_dry_run || exit 1
  dupl -v5 --dry-run $extra "${_file_selection[@]}" "$@" "$mbkp_src" "$mbkp_full_target"
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
  init_module "$1"; shift
  local _restore_target="$mbkp_src"

  local params=()
  while (($#)); do
    case "$1" in
      --restore-target)
        _restore_target="$2"; shift
        ;;
      *)
        params+=("$1")
      ;;
    esac
    shift
  done

  dupl restore -v5 "$mbkp_full_target" "$_restore_target" "${params[@]}"
}

EXP_log() {
  module="$1"; shift
  if [[ -z "$module" ]]; then
    init_config
    du -hs $MBKP_ARCHIVE/* | awk -F/ '{ print $NF,$1 }'
  else
    init_module "$module"
    dupl collection-status "$@" "$mbkp_full_target"
  fi

}

EXP_call() {
  (($# == 2)) || EXP_call_usage
  init_module "$1"; shift
  hook_type="$1"; shift

  case "$hook_type" in
    pre)
      pre_module_backup
      ;;
    post)
      post_module_backup
      ;;
    *)
      echo "mbkp: unknown hook type '$hook_type'"
      EXP_call_usage
      ;;
  esac

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
  init_config
  local archive_file="${1:-$MBKP_LOCAL_BACKUPS_BASE/mbkp-config.tbz}"; shift
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
