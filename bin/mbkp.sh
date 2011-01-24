#!/bin/sh
echo Testing count
echo Count is "$#"
[ "$#" -lt 1 ] && {
  echo "Usage:"
  echo "$0 <module-name-1> [<module-name-2>] ..."
  exit 1
}

BASEDIR="$(dirname $(readlink $0))"

. "$BASEDIR/../mbackup-config.sh"
echo "mbackup-config.sh called."

mbkp_priv_hook="$BASEDIR/../priv/_mbackup.priv"
[ -f "$mbkp_priv_hook" ] && {
  . "$mbkp_priv_hook"
  echo "$mbkp_priv_hook called."
} || {
  echo "Install $mbkp_priv_hook"
  exit 1
}

module="$1"; shift

priv_hook="$BASEDIR/../priv/$module.priv"
[ -f "$priv_hook" ] && {
  . "$priv_hook"
  echo "$priv_hook called."
}

DUPLICITY="duplicity"

[ -d "$SYNC_ROOT" ] || {
  mkdir -p "$SYNC_ROOT" || exit $?
}

[ -d "$HOME/.mbackup/data" ] || {
  mkdir -p "$HOME/.mbackup/data" || exit $?
}

# set -x
#

echo "=================================================="
echo "Backup STARTED for module $module"
echo "=================================================="

FAILED=''

_module_cache="$SYNC_ROOT/$module"
mbkp_target="$module"
VOLSIZE="50"

[ -e "$_module_cache" ] || {
  mkdir "$_module_cache" || exit $?
}

pre_hook="$BASEDIR/../modules/$module.pre"
[ -x "$pre_hook" ] && {
  time $pre_hook "$_module_cache" || exit $?
  echo "$pre_hook called."
}

echo "Module cache at $_module_cache"
echo "Volume size: $VOLSIZE MB"

. "$BASEDIR/../modules/$module.sh" "$_module_cache"
echo "$module.sh called."

includes="$BASEDIR/../modules/$module.includes"
[ -s "$includes" ] && {
  includes="--include-globbing-filelist $includes"
} || includes=''

excludes="$BASEDIR/../modules/$module.excludes"
[ -s "$excludes" ] && {
  excludes="--exclude-globbing-filelist $excludes"
} || excludes=''


PASSPHRASE=$PASSPHRASE $DUPLICITY -v4 \
--name "$module" --volsize="$VOLSIZE" \
--archive-dir=$HOME/.mbackup/cache/duplicity-archive \
--exclude-other-filesystems \
$SSH_OPTS \
--full-if-older-than $full_if_older_than \
$includes $excludes \
$extra "$mbkp_src/" "$MBKP_BASE_TARGET/$mbkp_target" || FAILED="$module"

post_hook="$BASEDIR/../modules/$module.post"
[ -x "$post_hook" ] && {
  $post_hook "$_module_cache" || FAILED="$post_hook"
  echo "$post_hook called."
}

[ -z "$FAILED" ] || {
  echo "##################################################"
  echo "############################# FAILED '$FAILED' !"
  echo "##################################################"
  exit 1
}

exit 0
