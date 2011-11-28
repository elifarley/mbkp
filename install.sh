#!/usr/bin/env bash

CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"

set -e

# Usage: $0 [<PREFIX>]
PREFIX="${1:-/usr}"

echo "Installation prefix: $PREFIX"

BIN_DIR="$PREFIX/bin"
MAN_DIR="$PREFIX/share/man/man1"
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

#install -d "$MAN_DIR"
#install -m644 man/mbkp.1 "$MAN_DIR"

#install -d $DOC_DIR
#install -m644 README $DOC_DIR/

#install -d $DOC_DIR/examples
#install -m644 examples/* $DOC_DIR/examples/

echo "Done."

exit 0
