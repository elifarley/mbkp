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
set -x
  local hg_info_file="$1/.hg_archival.txt"
  local version
  [[ -f $hg_info_file ]] || {
    echo '#WORKING-COPY#'
    return 1
  }

  params=()
  while read -r line; do
    eval $(sed '/^#/'d <<<"$line" | awk -v sq="'" 'BEGIN { FS = ":" } ; { gsub(/ */,"",$2); print "HG_" $1 "=" sq $2 sq ";" }' )
  done < "$hg_info_file"
  local version="${HG_tag:-$HG_latesttag+$HG_latesttagdistance}"
  echo $version
}
