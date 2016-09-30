#!/usr/bin/env bash
rsync_comm=rsync
ssh_comm=rsync
name=$(uname)
if [ "$uname" != "Linux" ] && [ "$uname" != "FreeBSD" ] ; then
	rsync_comm=$(find /c/Program\ Files* -name rsync.exe -type f|head -1 |sed 's/rsync.exe$//g')
	ln -s "$rsync_comm" ../bin
	rsync_comm=../bin/rsync.exe
	ssh_comm=../bin/ssh.exe
fi;
echo $rsync_comm;
last_changed="";
last_md5sum="";
$ssh_comm -nNf -p12222 -o ControlMaster=yes -o ControlPath="\"$HOME/.ssh/ctl/%L-%r@%h:%p\"" progga@trall.tk
STRHOME=$(echo $HOME)

echo "aaa"
function mysync {
    if [ "$1" ] ; then
        echo "$1" | while read line ; do
            echo "$rsync_comm" $line;
            time "$rsync_comm -v -e '$ssh_comm -p12222 -o 'ControlPath="$HOME"/.ssh/ctl/%L-%r@%h:%p' $line progga@trall.tk:~/tmp/$line";
        done;
    else
         echo "$rsync_comm" -arpvzP --delete -e "\"$ssh_comm -p12222 -o 'ControlPath="$STRHOME"/.ssh/ctl/%L-%r@%h:%p'\"" . progga@trall.tk:~/tmp/$line;
         "$rsync_comm" -arpvzP --delete -e ''$ssh_comm' -p12222 -o "ControlPath=\"'$STRHOME'/.ssh/ctl/%L-%r@%h:%p\""' . progga@trall.tk:~/tmp/$line;
    fi;
}
while :;
do
    rm /tmp/newerthan;
    touch -d '-0.2 seconds' /tmp/newerthan;
    changed=""
    filelist=$(find . -type f ! -path . -newer /tmp/newerthan 2>/dev/null);
    if [ "$filelist" ] && [ "$filelist" != "$last_changed" ]; then
        echo "changed";
        echo "$filelist";
        last_changed=$filelist;
        changed="true"
        mysync "$filelist";
        last_md5sum=$(find . |md5sum)
    else
        last_changed="";
    fi;
    md5=$(find . |md5sum)
    if [ "$md5" != "$last_md5sum" ] ; then
        echo "deleted";
        mysync;
        last_md5sum=$md5
    fi;
    sleep 0.1;
done;

$ssh_comm -O exit remote
