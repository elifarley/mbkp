#!/bin/sh

mbkp_src="$SITE_ROOT/forum"
full_if_older_than="6M"
extra="--exclude $mbkp_src/cache --exclude $mbkp_src/uploads"
