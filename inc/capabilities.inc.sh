# See http://bazaar.launchpad.net/~duplicity-team/duplicity/0.6-series/view/head:/CHANGELOG

# --name: v0.6.01
# --asynchronous-upload: 0.6.01
# --exclude-if-present: 0.5.14 

dotted_version_to_integer() {
  local _dotted_version="$1"; shift
  local _int_version="$(echo $_dotted_version | cut -d ' ' -f 2)"
  local _dvmajor="$(echo $_int_version|cut -d '.' -f 1)"
  local _dvminor="$(echo $_int_version|cut -d '.' -f 2- | tr -d .)"
  # Convert dotted version to integer
  # 2.6.15 -> 2615
  _int_version=$(( _dvmajor * 10 ** ${#_dvminor} + _dvminor))
  echo $_int_version
}

_dversion=$(dotted_version_to_integer "$(duplicity --version)")

((_dversion >= 601)) && _has_name=1 || _has_name=''
((_dversion >= 601)) && _has_asynchronous_upload=1 || _has_asynchronous_upload=''
((_dversion >= 514)) && _has_exclude_if_present=1 || _has_exclude_if_present=''
