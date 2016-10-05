#!/usr/bin/env bash
cd $(dirname "$0");

# IMPORT main functions from methods.sh
. methods.sh

# settings
. settings.conf


# working directory
currentdir=$(pwd);

is_cycle_working
if [ -z "$SYNC_STATE" ] ; then
    get_directory_from_terminal $1;
    cd $localdir;

    syncing_cycle &
    cd $currentdir;

    sshconnect;

    press_any_key;

    stop_syncing;
else
    sshconnect;

    press_any_key;
fi;
