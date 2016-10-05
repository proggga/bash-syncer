#!/usr/bin/env bash

STOPFILE=/tmp/stop_it_pls

press_any_key() {
    read -n1 -r -p "Press space to continue..." key
}

raise_error() {
    echo $1;
    press_any_key;
    exit 2;
}

# main cycle which perform syncing
# argument is file for syncing
sync_to_remote() {
    # for ssh Tunnel
    #time rsync -arpvzP --delete -e 'ssh -p12222 -o ControlPath="'$HOME'/.ssh/ctl/%L-%r@%h_%p"' $line $login@$server:~/tmp/;
     #echo rsync -arpvzP --delete -e "ssh -p$port" . $login@$server:"$remotedir";
     #echo; echo "rsync";
     rsync -arpvzP --delete -e "ssh -p$port" . $login@$server:"$remotedir" 2>&1 >/dev/null;
}

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

stop_syncing() {
    touch $STOPFILE;
}
# main cycle which can sync everything
syncing_cycle() {
    touch /tmp/timing_cycle;
    last_changed="";
    last_md5sum="";
    while [ ! -f $STOPFILE ];
    do
        rm /tmp/newerthan;
        touch -d '-0.2 seconds' /tmp/newerthan;
        changed="";
        filelist=$(find -name "*[^.]*" -type f -newer /tmp/newerthan 2>/dev/null);
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
            touch /tmp/timing_cycle;
        else
            touch -d '-2 seconds' /tmp/newerthan;
            more_than_2seconds=$(find /tmp/timing_cycle ! -newer /tmp/newerthan)
            if [ "$more_than_2seconds" ] ; then touch /tmp/timing_cycle; fi;
        fi;
        sleep 0.1;
    done;
    rm $STOPFILE;
}
