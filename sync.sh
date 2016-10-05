#!/usr/bin/env bash
cd $(dirname "$0")

# IMPORT main functions from methods.sh
. methods.sh

# settings
. settings.conf


# working directory
currentdir=$(pwd)

get_directory_from_terminal $1
cd $localdir

syncing_cycle &
cd $currentdir
ssh -p$port $login@$server

stop_syncing

press_any_key;
