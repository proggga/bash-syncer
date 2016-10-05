#!/usr/bin/env bash

# main constants with service filenames
STOPFILE=/tmp/stop_it_pls
NEWER=/tmp/newerthan
CYCLE=/tmp/timing_cycle

# press any key method, can put where you want (always replace $press_any_key_variable variable)
press_any_key() {
    if [ "$(uname)" != "Linux" ] ; then
        read -n1 -r -p "Press space to continue..." press_any_key_variable
    fi;
}

# error message with exit
raise_error() {
    echo $1;
    press_any_key;
    exit 2;
}

# check if cyclw working right now
is_cycle_working() {
    SYNC_STATE=""
    if [ -f "$NEWER" ] ; then
        SYNC_STATE="WORKING";
        ls -la $NEWER;
    fi;
}

# connect to server
sshconnect() {
    ssh -p$port $login@$server
}

# method which sync dir to remote dir
sync_to_remote() {
     rsync -arpvzP --delete -e "ssh -p$port" . $login@$server:"$remotedir" 2>&1 >/dev/null;
}

# conver Windows path to Cygwin linux path
convert_dir_windows_to_linux() {
    :; #NOP
}

# promt which get dir, and check it existance
get_directory_from_terminal() {
    localdir=$1
    if [ -z "$1" ] ; then
        read -e -p "Please input directory of project: " localdir;
        localdir=$(echo $localdir | sed "s|~|$HOME|g")
    fi;
    if [ -z "$localdir" ] ; then
        raise_error "You should define directory to work";
    fi;
    if [ ! -d "$localdir" ] ; then raise_error "Directory does not exists"; fi;
}

# stop syncing cycle
stop_syncing() {
    touch $STOPFILE;
}

# main cycle which can sync everything
syncing_cycle() {
    is_cycle_working
    if [ "$SYNC_STATE" ] ; then return; fi;

    touch $CYCLE;
    last_changed="";
    last_md5sum="";
    while [ ! -f $STOPFILE ];
    do
        touch -d '-0.2 seconds' $NEWER;
        changed="";
        filelist=$(find -name "*[^.]*" -type f -newer $NEWER 2>/dev/null);
        if [ "$filelist" ] && [ "$filelist" != "$last_changed" ]; then
            #echo "changed";
            #echo "$filelist";
            last_changed="$filelist";
            changed="true";
            last_md5sum=$(find . | md5sum);
        else
            last_changed="";
        fi;
        md5=$(find . | md5sum);
        if [ "$md5" != "$last_md5sum" ] ; then
            #echo "deleted";
            changed="true";
            last_md5sum=$md5
        fi;
        #echo "waiting"
        if [ "$changed" ] ; then
            changed="";
            sync_to_remote;
            touch $CYCLE;
        else
            touch -d '-2 seconds' $NEWER;
            more_than_2seconds=$(find $CYCLE ! -newer $NEWER)
            if [ "$more_than_2seconds" ] ; then touch $CYCLE; fi;
        fi;
        sleep 0.1;
    done;
    rm $STOPFILE;
    rm $NEWER;
    rm $CYCLE;
}
