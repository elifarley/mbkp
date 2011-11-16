dupl() {
  PASSPHRASE="$PASSPHRASE" FTP_PASSWORD="$FTP_PASSWORD" duplicity \
  --archive-dir="$MBKP_ARCHIVE" --name "$module" --ssh-askpass $SSH_OPTS \
  "$@"
}

backup_single_module() {

  local module="$1"; shift

  echo "--------------------------------------------------"
  echo "Backup STARTED for module $module"
  echo "--------------------------------------------------"

  init_module "$module"
  pre_module_backup
  do_backup "$mbkp_src" "$mbkp_full_target"
  post_module_backup

  [ -z "$FAILED" ] || {
    echo "##################################################"
    echo "############################# FAILED '$FAILED' !"
    echo "##################################################"
  }
  echo "--------------------------------------------------"
  echo "Backup  ENDED  for module $module"
  echo "======================================================================"

} # backup_single_module

do_backup() {
  # do_backup src target

  local backup_src="$1"; shift
  local backup_target="$1"; shift

  dupl remove-all-but-n-full "$keep_last_n_backups" --force "$backup_target"
  dupl cleanup --force "$backup_target" # --extra-clean

  dupl --gpg-options "--compress-algo=bzip2 --bzip2-compress-level=9" \
  --asynchronous-upload ${volsize:+--volsize="$volsize"} \
  --full-if-older-than $full_if_older_than $extra "${_file_selection[@]}" \
  "$backup_src" "$backup_target" || FAILED="$module"
} # do_backup
