#!/usr/bin/env bash
SCRIPT_COMMAND=$0
DIR_PARAM=$1

cd $(dirname "$SCRIPT_COMMAND");

source src/system.sh
# settings
SETTINGS_FILENAME=settings.conf
if [ ! -f $SETTINGS_FILENAME ] ; then
    system:raise_error "Config file '$SETTINGS_FILENAME' not found, please copy '$SETTINGS_FILENAME.example'"
fi;

source $SETTINGS_FILENAME
source src/synchro.sh

# working directory
currentdir=$(pwd);

syncho:is_cycle_working
if [ -z "$SYNC_STATE" ] ; then
    syncho:get_directory_from_terminal $DIR_PARAM;
    syncho:syncprocess $localdir $currentdir &
    syncho:sshconnect;
    system:press_any_key;
    syncho:stop_syncing;
else
    syncho:sshconnect;
    system:press_any_key;
fi;
syncho:clear_files;
