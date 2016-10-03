#!/usr/bin/env bash

function raise_error {
    echo $1;
    exit 2;
}

# main cycle which perform syncing
# argument is file for syncing
function syncing_cycle {
    if [ "$1" ] ; then
        echo "$1" | while read line ; do
            # for ssh Tunnel
            #time rsync -arpvzP --delete -e 'ssh -p12222 -o ControlPath="'$HOME'/.ssh/ctl/%L-%r@%h_%p"' $line $login@$server:~/tmp/;
            time rsync -arpvzP --delete -e "ssh -p$port" "$line" $login@$server:~/tmp/;
        done;
    else
         time rsync -arpvzP --delete -e 'ssh -p12222 -o ControlPath="'$HOME'/.ssh/ctl/%L-%r@%h_%p"' . $login@$server:~/tmp/;
    fi;
}
