dupl() {
  local _function_params=("$@")
  local _first_param="${_function_params[@]:0:1}"
  local _other_params=("${_function_params[@]:1}")
  local _params=(${_has_name:+--name "$module"} --archive-dir="$(get_duplicity_cache_dir)" --ssh-askpass $SSH_OPTS)
  _params=($_first_param "${_params[@]}" "${_other_params[@]}")

  if ((_dry_run)); then
    echo "--dry-run option ACTIVE. Nothing will be saved to backup archive!"
    echo 'Command that would have been executed:'
    echo PASSPHRASE="<hidden>" FTP_PASSWORD="<hidden>" duplicity "${_params[@]}"
    echo
  else
    PASSPHRASE="$PASSPHRASE" FTP_PASSWORD="$FTP_PASSWORD" duplicity "${_params[@]}"
  fi
}

backup_single_module() {

  local module="$1"; shift
  local _lock="mbkp-backup.$USER.$module"
  local _lock_ok=0

  acquire_lock "$_lock" && {
    _lock_ok=1
    echo
    echo "-------------------------------------------------"
    echo "STARTED backup: '$module'"
    echo "-------------------------------------------------"
    echo

    init_module "$module"
    pre_module_backup
    do_backup "$mbkp_src" "$mbkp_full_target" "$@"
    post_module_backup

  release_lock "$_lock"; }

  ((_lock_ok)) || FAILED="$module:RUNNING"

  [ -z "$FAILED" ] || {
    echo "##################################################"
    echo "############################# FAILED '$FAILED' !"
    echo "##################################################"
  }
  ((_lock_ok)) && echo "ENDED backup: '$module'" || echo "SKIPPED backup: '$module'"
  echo "======================================================================"
  echo

} # backup_single_module

do_backup() {
  # do_backup src target

  local backup_src="$1"; shift
  local backup_target="$1"; shift

  dupl remove-all-but-n-full "$keep_last_n_backups" --force "$backup_target"
  dupl cleanup --force "$backup_target" # --extra-clean

  dupl --volsize="$volsize" --full-if-older-than $full_if_older_than \
  --gpg-options "--compress-algo=bzip2 --bzip2-compress-level=9" \
  ${_has_asynchronous_upload:+--asynchronous-upload} \
   $extra "$@" "${_file_selection[@]}" \
  "$backup_src" "$backup_target" || FAILED="$module"
} # do_backup
