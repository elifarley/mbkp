#!/usr/bin/env bash

CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"

set -e

# Usage: $0 [<PREFIX>]
PREFIX="${1:-/usr}"

echo "Installation prefix: $PREFIX"

BIN_DIR="$PREFIX/bin"
MAN_DIR="$PREFIX/share/man"
DOC_DIR="$PREFIX/share/doc/mbkp"
DATA_DIR="$PREFIX/lib/mbkp"

install -d "$DATA_DIR/inc"
install -m644 "$CMD_BASE"/inc/* "$DATA_DIR/inc"
install -m644 "$CMD_BASE"/{mbkp.conf,.mbkp*} "$DATA_DIR/"
install -m755 "$CMD_BASE"/mbkp $DATA_DIR/

# Install a symlink to the normal binary directory, so that moped
# is also in the system path and can be excuted with `moped`.
install -d $BIN_DIR
ln -s $DATA_DIR/mbkp $BIN_DIR/

install -d "$MAN_DIR/man1"
m1="$MAN_DIR"/man1/mbkp.1.gz
"$CMD_BASE"/man/man.sh | gzip -c9 > "$m1"
chmod 644 "$m1"

#install -d $DOC_DIR
#install -m644 README $DOC_DIR/

#install -d $DOC_DIR/examples
#install -m644 examples/* $DOC_DIR/examples/

echo "Done."

exit 0
