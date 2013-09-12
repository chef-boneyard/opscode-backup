#!/bin/bash
# Managed by Chef

# It's useful to grab time as well as date here
DATE=`date +%Y-%m-%d-%H-%M-%S`

cp -alL $RSYNC_MODULE_PATH/CURRENT $RSYNC_MODULE_PATH/IN-PROGRESS
ln -s $RSYNC_MODULE_PATH/IN-PROGRESS $RSYNC_MODULE_PATH/IN-PROGRESS-$DATE
