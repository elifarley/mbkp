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
