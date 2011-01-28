#!/bin/bash
[ "$#" -lt 1 ] && {
  echo "Usage:"
  echo "$0 <module-name-1> [<module-name-2>] ..."
  exit 1
}

VERBOSE=0

db_dump () {
  # db_dump dump_name
  local dump_name="$1"; shift
  mysqldump "$@" -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASSWORD" "$DB_NAME" > "$_module_cache/$dump_name.sql" || exit $?
}

dupl() {
  PASSPHRASE=$PASSPHRASE duplicity -v4 \
  --archive-dir="$MBACKUP_ARCHIVE" \
  --name "$module" "$@"
}

do_backup() {
  # do_backup src target

  dupl cleanup "$2"
  dupl remove-older-than 6M "$2"

  # FTP_PASSWORD=$FTP_PASSWORD
  dupl ${VOLSIZE:+--volsize="$VOLSIZE"} \
  --ssh-askpass --exclude-other-filesystems \
  $SSH_OPTS \
  --full-if-older-than $full_if_older_than \
  $includes $excludes \
  $extra "$1/" "$2" || FAILED="$module"
}

BASEDIR="$(readlink $0)" || BASEDIR="$0"
BASEDIR="$(dirname $BASEDIR)"

module="$1"; shift

. "$BASEDIR/../mbackup-config.sh" || exit 1
((VERBOSE)) && echo "mbackup-config.sh called."

mbkp_priv_hook="$BASEDIR/../priv/_mbackup.priv"
if [ -f "$mbkp_priv_hook" ]; then
  . "$mbkp_priv_hook" || exit 1
  ((VERBOSE)) && echo "$mbkp_priv_hook called."
else
  echo "Please install $mbkp_priv_hook"
  exit 1
fi

[ -d "$MBKP_MODULE_CACHE" ] || {
  mkdir -p "$MBKP_MODULE_CACHE" || exit $?
}

[ -d "$MBKP_LOCAL_DATA" ] || {
  mkdir -p "$MBKP_LOCAL_DATA" || exit $?
}

# set -x
#

echo "=================================================="
echo "Backup STARTED for module $module"
echo "=================================================="

FAILED=''

# Variables that can be overriden on module config files
_module_cache="$MBKP_MODULE_CACHE/$module"
mbkp_src="$_module_cache"
mbkp_target="$MBKP_BASE_TARGET"
VOLSIZE="50"
full_if_older_than="6M"
extra=''

priv_hook="$BASEDIR/../priv/$module.priv"
[ -f "$priv_hook" ] && {
  . "$priv_hook"
  ((VERBOSE)) && echo "$priv_hook called."
}

[ -e "$_module_cache" ] || {
  mkdir "$_module_cache" || exit $?
}

pre_hook="$BASEDIR/../modules/$module.pre"
if [ -s "$pre_hook" ]; then
  time . $pre_hook "$_module_cache" || exit $?
  ((VERBOSE)) && echo "$pre_hook called."
else
  echo "### $pre_hook NOT CALLED."
fi

mbkp_full_target="$mbkp_target/$module"

resolved_src="$(readlink $mbkp_src)" && mbkp_src="$resolved_src"

echo "Volume size: $VOLSIZE MB"
echo "Module source at $mbkp_src"
echo "Module target at $mbkp_full_target"
echo "full_if_older_than: $full_if_older_than"
echo "extra: $extra"

includes="$BASEDIR/../modules/$module.files"
[ -s "$includes" ] && {
  includes="--include-globbing-filelist $includes"
} || includes=''

excludes="$BASEDIR/../modules/$module.excludes"
[ -s "$excludes" ] && {
  excludes="--exclude-globbing-filelist $excludes"
} || excludes=''

do_backup "$mbkp_src" "$mbkp_full_target"

post_hook="$BASEDIR/../modules/$module.post"
if [ -s "$post_hook" ]; then
 . $post_hook "$_module_cache" || FAILED="$post_hook"
  ((VERBOSE)) && echo "$post_hook called."
else
  echo "### $post_hook NOT CALLED."
fi

[ -z "$FAILED" ] || {
  echo "##################################################"
  echo "############################# FAILED '$FAILED' !"
  echo "##################################################"
  exit 1
}

exit 0
