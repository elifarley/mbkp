#
# Copyright 2010-2011 Elifarley Cruz <elifarley@gmail.com>
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

print_hms() {

  local seconds="${1:-now}"; [[ $seconds == 'now' ]] && seconds="$SECONDS"
  (($# > 1)) && {
    local _end="$2"; [[ $_end == 'now' ]] && _end="$SECONDS"
    seconds=$((_end - seconds))
  }
  printf '%02d:%02d:%02d\n' $((seconds / 3600)) $((seconds % 3600 / 60)) $((seconds % 60))
}

add_prefix() {
  set -f
  local prefix="$1"; shift
  local prefix_is_callable=0; [[ ${prefix:0:2} == '#!' ]] && { prefix_is_callable=1; prefix="${prefix:2}"; }
  local join_prefix_and_item=0; ((prefix_is_callable)) || { join_prefix_and_item="$1"; shift; }
  local result_var="$1"; shift
  # Test if $result_var should be used as a source of values
  (($#)) && local items="$@" || local items="${!result_var}"

  local result=()
  local _prefix=''
  for item in ${items//,/ }; do
    item=$(echo $item) # trim whitespaces
    [ -n "$item" ] && {
      if ((prefix_is_callable)); then
        # If calling $prefix gives an error, skip this item
        _prefix=$($prefix $item) && result+=($_prefix)
      else
        (($join_prefix_and_item)) && result+=("$prefix$item") || result+=("$prefix" "$item")
      fi
    }
  done;
  eval "$result_var=(${result[@]})"
  set +f
}

acquire_lock() {
  _acquire_lock 0 "$@" || _acquire_lock 1 "$@" || return $?
}

# Based on:
# 1) http://wiki.bash-hackers.org/howto/mutex
# 2) http://www.pathname.com/fhs/pub/fhs-2.3.html
# 3) http://docs.freebsd.org/info/uucp/uucp.info.UUCP_Lock_Files.html
_acquire_lock() {

  local _lock_try="$1"; shift
  local _lock="$1"; shift

  ((_lock_try == 0)) && echo "Acquiring lock: $_lock"
  _lock="/var/lock/LK.$_lock"

  # Atomically create lock file
  set -o noclobber && \
  printf '%010d\n' $$ &>/dev/null > "$_lock" && \
  set +o noclobber && delete_on_exit "$_lock" && \
  return 0

  set +o noclobber

  local _other_pid=$(cat $_lock) || {
    echo "Failed to read other PID from '$_lock'" >&2
    exit 2
  }

  kill -0 $_other_pid &>/dev/null && {
    echo "Failed to acquire lock for '$(basename $_lock)': PID ${_other_pid} is still running." >&2
    exit 2
  }

  rm -rf "$_lock" && [[ ! -f $_lock ]] || {
    echo "Unable to remove '$_lock' (PID $_other_pid)" >&2
    exit 2
  }
  echo "Stale lock file removed: '$_lock'" >&2
  return 1

}

release_lock() {
  local _lock="$1"
  rm -rf "/var/lock/LK.$_lock"
  trap - 0
  echo "Lock released: '$_lock'"
}

delete_on_exit() {
  local file_to_remove="$1"
  trap '\
    _ecode=$?;
    echo "Removing '$file_to_remove'. Exit code: $_ecode" >&2
    rm -r "'$file_to_remove'"
  ' 0
  return 0
}

