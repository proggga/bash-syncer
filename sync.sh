#!/usr/bin/env bash

# settings
login=progga;
server=trall.tk;

# connection
last_changed="";
last_md5sum="";
ssh -nNf -p12222 -o ControlMaster=yes -o ControlPath="\"$HOME/.ssh/ctl/%L-%r@%h:%p\"" $login@$server
STRHOME=$(echo $HOME)

function syncing_cycle {
    if [ "$1" ] ; then
        echo "$1" | while read line ; do
            time rsync -v -e "ssh -p12222 -o 'ControlPath="$HOME"/.ssh/ctl/%L-%r@%h:%p' $line $login@$server:~/tmp/$line";
        done;
    else
         "$rsync_comm" -arpvzP --delete -e ''$ssh_comm' -p12222 -o "ControlPath=\"'$STRHOME'/.ssh/ctl/%L-%r@%h:%p\""' . progga@trall.tk:~/tmp/$line;
    fi;
}

while :;
do
    rm /tmp/newerthan;
    touch -d '-0.2 seconds' /tmp/newerthan;
    changed="";
    filelist=$(find . -type f ! -path . -newer /tmp/newerthan 2>/dev/null);
    if [ "$filelist" ] && [ "$filelist" != "$last_changed" ]; then
        echo "changed";
        echo "$filelist";
        last_changed=$filelist;
        changed="true";
        mysync "$filelist";
        last_md5sum=$(find . |md5sum);
    else
        last_changed="";
    fi;
    md5=$(find . |md5sum);
    if [ "$md5" != "$last_md5sum" ] ; then
        echo "deleted";
        mysync;
        last_md5sum=$md5
    fi;
    sleep 0.1;
done;

ssh -o ControlMaster=yes -o ControlPath="\"$HOME/.ssh/ctl/%L-%r@%h:%p\"" -O exit remote
