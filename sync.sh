#!/usr/bin/env bash
# settings
login=progga;
server=trall.tk;

# connection
last_changed="";
last_md5sum="";
ssh -nNf -p12222 -o ControlMaster=yes -o ControlPath="\"$HOME/.ssh/ctl/%L-%r@%h_%p\"" $login@$server
STRHOME=$(echo $HOME)

function syncing_cycle {
    if [ "$1" ] ; then
        echo "$1" | while read line ; do
            time rsync -arpvzP --delete -e 'ssh -p12222 -o ControlPath="'$STRHOME'/.ssh/ctl/%L-%r@%h_%p"' $line progga@trall.tk:~/tmp/;
        done;
    else
         rsync -arpvzP --delete -e 'ssh -p12222 -o ControlPath="'$STRHOME'/.ssh/ctl/%L-%r@%h_%p"' . progga@trall.tk:~/tmp/;
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

ssh -p12222 -O stop -S /home/progga/.ssh/ctl/%L-%r@%h_%p progga@trall.tk
