init_config_dir() {
  MBKP_FIRST_RUN=1
  local priv_dir="$MBKP_CONFIG_BASE/priv"
  echo "init_config_dir: $priv_dir"
  mkdir -p "$priv_dir" || exit $?
  cp -av --no-clobber $CMD_BASE/priv.template/* "$priv_dir" || exit $?
  chmod -R go= "$priv_dir" || exit $?

  local modules_dir="$MBKP_CONFIG_BASE/modules"
  echo "init_config_dir: $modules_dir"
  mkdir -p "$modules_dir" || exit $?
  cp -av --no-clobber $CMD_BASE/modules.template/* "$modules_dir"/ || exit $?
}

init_config() {

  local mbkp_conf_file="$MBKP_CONF_FILE"
  ((VERBOSE)) && echo "Calling $mbkp_conf_file"
  . "$mbkp_conf_file" || exit 1

  mbkp_conf_file="$MBKP_CONFIG_BASE/mbkp.conf"
  if [ -f "$mbkp_conf_file" ]; then
    ((VERBOSE)) && echo "Calling $mbkp_conf_file"
    . "$mbkp_conf_file" || exit 1
  else
    init_config_dir "$mbkp_conf_file"
  fi

  ((MBKP_FIRST_RUN)) && {
    echo "Please edit the file '$mbkp_conf_file' and try again."
    exit 1
  }

  local mbkp_priv_hook="$MBKP_CONFIG_BASE/priv/mbkp.conf"
  [ -f "$mbkp_priv_hook" ] && {
    ((VERBOSE)) && echo "Calling $mbkp_priv_hook"
    . "$mbkp_priv_hook" || exit 1
  }

  [ -d "$MBKP_MODULE_CACHE_BASE" ] || {
    mkdir -p "$MBKP_MODULE_CACHE_BASE" || {
      echo "Unable to create module cache base dir at '$MBKP_MODULE_CACHE_BASE'."
      exit 2
    }
  }

  [ -d "$MBKP_LOCAL_BACKUPS_BASE" ] || {
    mkdir -p "$MBKP_LOCAL_BACKUPS_BASE" || {
      echo "Unable to create local backups dir at '$MBKP_LOCAL_BACKUPS_BASE'."
      exit 3
    }
  }

} # init_config

init_module() {

  FAILED=''

  init_config

  local module_hook="$MBKP_CONFIG_BASE/priv/$module.conf"
  [ -f "$module_hook" ] && {
    echo "Calling: $module_hook"
    . "$module_hook"
  }

  module_hook="$MBKP_CONFIG_BASE/modules/$module.conf"
  [ -f "$module_hook" ] && {
    echo "Calling: $module_hook"
    . "$module_hook"
  }

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
  _file_selection=(--exclude-if-present CACHEDIR.TAG ${file_list[@]})
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
