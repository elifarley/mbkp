#!/bin/sh

export RSYNC_RSH="$(which rsync) --protocol=29"
# SSH_OPTS='--ssh-options="-oIdentityFile=/home/USER/.ssh/id_dsa-nopw"'
SITE_ROOT="$HOME/my.site.org"

MBKP_CONFIG="$HOME/.config/mbackup"
MBKP_DATA="$HOME/.local/share/mbackup"

MBKP_LOCAL_DATA="$MBKP_DATA/data"
MBKP_ARCHIVE="$MBKP_DATA/cache/duplicity-archive"
MBKP_MODULE_CACHE="$MBKP_DATA/cache/modules"

MBKP_BASE_TARGET="rsync://user@backup.host.com"
MBKP_BASE_TARGET="sftp://user@backup.host.com/mbackup-modules"
MBKP_BASE_TARGET="file://$MBKP_LOCAL_DATA"