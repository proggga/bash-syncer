#!/usr/bin/env bash

# IMPORT main functions from methods.sh
. methods.sh
# list of methods:
# raise_error (string) :: method print message to screen and exit with state 2

# settings
. settings.conf

# working directory
localdir=$1
if [ -z "$1" ] ; then
    read -e -p "Please input directory of project: " localdir;
    localdir=$(echo $localdir | sed "s|~|$HOME|g")
fi;
if [ -z "$localdir" ] ; then
    raise_error "You should define directory to work";
fi;
if [ ! -d "$localdir" ] ; then raise_error "Directory does not exists"; fi;

# connection
last_changed="";
last_md5sum="";

# check catalog existance (for ssh tunnel)
#if [ ! -d "$HOME/.ssh/ctl" ] ; then
#    mkdir -p "$HOME/.ssh/ctl";
#fi;

# Ssh tullel works only at linux)
#ssh -nNf -p12222 -o ControlMaster=yes -o ControlPath="\"$HOME/.ssh/ctl/%L-%r@%h_%p\"" $login@$server


while :;
do
    rm /tmp/newerthan;
    touch -d '-0.2 seconds' /tmp/newerthan;
    changed="";
    filelist=$(find * -type f ! -path . -newer /tmp/newerthan 2>/dev/null);
    if [ "$filelist" ] && [ "$filelist" != "$last_changed" ]; then
        echo "changed";
        echo "$filelist";
        last_changed="$filelist";
        changed="true";
        syncing_cycle "$filelist";
        last_md5sum=$(find . | md5sum);
    else
        last_changed="";
    fi;
    md5=$(find . | md5sum);
    if [ "$md5" != "$last_md5sum" ] ; then
        echo "deleted";
        syncing_cycle;
        last_md5sum=$md5
    fi;
    sleep 0.1;
done;

# Ssh tunnel (Works only at linux)
#ssh -p12222 -O stop -S "$HOME/.ssh/ctl/%L-%r@%h_%p" $login@$server
