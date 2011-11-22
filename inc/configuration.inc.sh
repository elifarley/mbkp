init_config_dir() {
  MBKP_FIRST_RUN=1
  local modules_dir="$MBKP_CONFIG_BASE/modules"
  echo "init_config_dir: $modules_dir"
  mkdir -p "$modules_dir" || exit $?

  local priv_dir="$MBKP_CONFIG_BASE/priv"
  echo "init_config_dir: $priv_dir"
  mkdir -p "$priv_dir" || exit $?
  chmod -R go= "$priv_dir" || exit $?

  cp -av -ui $CMD_BASE/.mbkp.conf.user.template "$MBKP_CONFIG_BASE"/mbkp.conf || exit $?

}

new_module() {
  module="$1"; shift
  local module_path="$MBKP_CONFIG_BASE/modules/$module.conf"
  [[ -e "$module_path" ]] && {
    echo "Module '$module' already exists at $module_path"
    exit 1
  }
  cp -a -ui $CMD_BASE/.mbkp-module.conf.template "$module_path" || exit $?
  echo "Module '$module' created at $module_path"
}

init_config() {

  local _suppress_first_run_check="${1:-0}"; shift

  local mbkp_conf_file="$MBKP_CONF_FILE"
  ((VERBOSE)) && echo "Calling $mbkp_conf_file"
  . "$mbkp_conf_file" || exit $?

  mbkp_conf_file="$MBKP_CONFIG_BASE/mbkp.conf"
  if [[ -f "$mbkp_conf_file" ]]; then
    ((VERBOSE)) && echo "Calling $mbkp_conf_file"
    . "$mbkp_conf_file" || exit $?
  else
    ((_suppress_first_run_check)) || config_not_found
    init_config_dir
  fi

  (( _suppress_first_run_check == 0 && MBKP_FIRST_RUN == 1 )) && \
    config_not_found 1

  local mbkp_priv_hook="$MBKP_CONFIG_BASE/priv/mbkp.conf"
  [ -f "$mbkp_priv_hook" ] && {
    ((VERBOSE)) && echo "Calling $mbkp_priv_hook"
    . "$mbkp_priv_hook" || exit $?
  }

  # Create directories if absent
  mkdir -p "$MBKP_ARCHIVE"
  mkdir -p "$MBKP_MODULE_CACHE_BASE"
  mkdir -p "$MBKP_LOCAL_BACKUPS_BASE"

} # init_config

init_module() {

  module="$1"; shift
  FAILED=''

  init_config

  local mbkp_module_exists=0

  local module_hook="$MBKP_CONFIG_BASE/priv/$module.conf"
  [ -f "$module_hook" ] && {
    echo "Calling: $module_hook"
    . "$module_hook" || exit $?
    mbkp_module_exists=1
  }

  module_hook="$MBKP_CONFIG_BASE/modules/$module.conf"
  [ -f "$module_hook" ] && {
    ((VERBOSE)) && echo "Calling: $module_hook"
    . "$module_hook" || exit $?
    mbkp_module_exists=1
  }

  ((mbkp_module_exists)) || module_not_found

  ((canonicalize_source)) && mbkp_src="$(readlink --canonicalize-missing $mbkp_src)"
  # Append '/' if needed
  [[ $mbkp_src == */ ]] || mbkp_src="$mbkp_src/"

  mbkp_full_target="$mbkp_target/$module"

  [ -e "$module_cache" ] || {
    ((VERBOSE)) && echo "Creating $module_cache"
    mkdir "$module_cache" || exit $?
  }

  add_prefix "#!process_file_list_item" file_list

  add_prefix "$mbkp_src" 1 included_files
  add_prefix "--include" 0 included_files "${included_files[@]}"

  add_prefix "$mbkp_src" 1 excluded_files
  add_prefix "--exclude" 0 excluded_files "${excluded_files[@]}"

  include_gfilelist="$MBKP_CONFIG_BASE/modules/$module.files"
  [ -s "$include_gfilelist" ] && {
    include_gfilelist="--include-globbing-filelist $include_gfilelist"
  } || include_gfilelist=''

  exclude_gfilelist="$MBKP_CONFIG_BASE/modules/$module.excludes"
  [ -s "$exclude_gfilelist" ] && {
    exclude_gfilelist="--exclude-globbing-filelist $exclude_gfilelist"
  } || exclude_gfilelist=''

  set -f
  _file_selection=(${_has_exclude_if_present:+--exclude-if-present CACHEDIR.TAG} ${file_list[@]})
  ((excludes_first)) && _file_selection+=("${excluded_files[@]}" "${included_files[@]}") || _file_selection+=("${included_files[@]}" "${excluded_files[@]}")
  _file_selection+=($include_gfilelist $exclude_gfilelist)

  echo "Module source: $mbkp_src"
  echo "Module target: $mbkp_full_target"
  echo "Volume size  : $volsize MB"
  echo "Full if older: $full_if_older_than"
  echo "Keep last backups: $keep_last_n_backups"
  [ -n "$extra" ] && echo "extra        : $extra"
  ((${#file_list[@]})) && echo "File list    :" && echo ${file_list[@]}
  ((${#included_files[@]})) && echo "Included files:" && echo ${included_files[@]}
  ((${#excluded_files[@]})) && echo "Excluded files:" && echo ${excluded_files[@]}
  [ -n "$include_gfilelist" ] && echo $include_gfilelist
  [ -n "$exclude_gfilelist" ] && echo $exclude_gfilelist
  set +f
  echo '------------------------------------'
  echo

} # init_module

process_file_list_item() {

  local filespec="$1"
  local item_type="${filespec:0:1}"
  local command
  [[ $item_type == '-' ]] && command='--exclude' || command='--include'
  [[ $item_type == '-' || $item_type == '+' ]] && filespec="${filespec:1}"
  set -f
  echo "$command '$mbkp_src$filespec'"
  set +f
}

pre_module_backup() {

  local pre_hook="$MBKP_CONFIG_BASE/modules/$module.pre"
  if [ -s "$pre_hook" ]; then
    echo "Calling: $pre_hook"
    . $pre_hook "$module_cache" || exit $?
  else
    ((VERBOSE)) && echo "### NOT CALLED: $pre_hook"
  fi

  [ -n "$DB_NAME" ] && time mysql_dump

} # pre_module_backup

post_module_backup() {

  local post_hook="$MBKP_CONFIG_BASE/modules/$module.post"
  if [ -s "$post_hook" ]; then
    echo "Calling: $post_hook"
   . $post_hook "$module_cache" || FAILED="$post_hook"
  else
    ((VERBOSE)) && echo "### $post_hook NOT CALLED."
  fi

} # post_module_backup
