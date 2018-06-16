#!/usr/bin/env bash
CMD_BASE="$(readlink -m "$0")" || CMD_BASE="$0"; CMD_BASE="$(dirname "$CMD_BASE")"
set -e
for item in "$CMD_BASE"/inc/*.inc.sh ; do . "$item"; done

# Usage: $0 [<PREFIX>]
PREFIX="${1:-/usr}"

SRC="$CMD_BASE/.."
readonly MBKP_VERSION="$(parse_hg_version $SRC)"

_m4() {
  m4 -P -Dm4_MBKP_VERSION="$MBKP_VERSION" "$1"
}

_pod2man() {
  _m4 "$1" | pod2man --center="mbkp - Manual" --name="mbkp" --release="mbkp $MBKP_VERSION" --section=1
}

echo "Installation prefix: $PREFIX"

BIN_DIR="$PREFIX/"bin
MAN_DIR="$PREFIX"/share/man
DOC_DIR="$PREFIX"/share/doc/mbkp
DATA_DIR="$PREFIX"/lib/mbkp

install -d "$DATA_DIR"/inc
install -m644 "$SRC"/inc/*.sh "$DATA_DIR"/inc/
_m4 "$SRC"/inc/build.info > "$DATA_DIR"/inc/build.info
chmod 644 "$DATA_DIR"/inc/build.info
install -m644 "$SRC"/{mbkp.conf,.mbkp*} "$DATA_DIR"/
install -m755 "$SRC"/mbkp "$DATA_DIR"/

install -d "$BIN_DIR"
ln -s "$DATA_DIR"/mbkp "$BIN_DIR"/

install -d "$MAN_DIR"/man1
m1="$MAN_DIR"/man1/mbkp.1
_pod2man "$SRC"/man/mbkp.1.pod | gzip -c9 > "$m1".gz
chmod 644 "$m1"*

#install -d $DOC_DIR
#install -m644 README $DOC_DIR/

#install -d $DOC_DIR/examples
#install -m644 examples/* $DOC_DIR/examples/

echo "Done."
