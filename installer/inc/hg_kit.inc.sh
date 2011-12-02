#
# Copyright 2010-2011 Elifarley Cruz <elifarley@gmail.com>
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

: <<EOF
Parses information from '.hg_archival.txt' files.
Example:

repo: c6d1eadf696ab13069e7c416d79f9004c670fc86
node: 57aeddaa793cc576390641db242ff4495f92898d
branch: default

tag: 0.1.0
# or
latesttag: WC
latesttagdistance: 9

EOF
parse_hg_version() {

  local hg_info_file="$1/.hg_archival.txt"
  local version
  [[ -f $hg_info_file ]] || {
    echo '#WORKING-COPY#'
    return 1
  }

  unset -v HG_{tag,latesttag,latesttagdistance}
  parse_properties "$hg_info_file" 'HG_' ':'

  [[ -z $HG_tag && -z $HG_latesttag ]] && local version='!INVALID-HG-INFO!' || \
    local version="${HG_tag:-$HG_latesttag+$HG_latesttagdistance}"
  echo $version
}

parse_properties() {
  local _file="$1"; shift
  local _prefix="$1"; shift
  local _separator="$1"

  while read -r line; do
    [[ -z $line || $line == \#* ]] && continue
    local key="$(cut -d$_separator -f1 <<<$line)"
    local val="$(cut -d$_separator -f2 <<<$line)"
    eval "$_prefix$(echo $key)='$(echo $val)'"
  done < "$_file"

}