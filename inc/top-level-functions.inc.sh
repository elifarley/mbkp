EXP_backup_modules() {
  (($#)) || EXP_backup_modules_usage
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
  (($#)) || EXP_status_usage
  init_module "$1"; shift
  dupl -v8 --dry-run "${_file_selection[@]}" "$@" "$mbkp_src" "$mbkp_full_target"
}

EXP_list() {
  module="$1"; shift
  if [[ -z "$module" ]]; then
    init_config
    du -hs $MBKP_ARCHIVE/* | awk -F/ '{ print $NF,$1 }'
  else
    init_module "$module"
    dupl list-current-files -v8 "$@" "$mbkp_full_target"
  fi

}

EXP_verify() {
  (($#)) || EXP_verify_usage
  init_module "$1"; shift
  dupl verify -v8 "${_file_selection[@]}" "$@" "$mbkp_full_target" "$mbkp_src"
}

EXP_restore() {
  (($#)) || EXP_restore_usage
  init_module "$1"; shift
  dupl restore -v8 "$mbkp_full_target" "$@"
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
