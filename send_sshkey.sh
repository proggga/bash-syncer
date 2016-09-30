#!/usr/bin/env bash
echo "yolo"
key=/tmp/ssh-key-for-sync
echo $key
if [ ! -f "$key" ] ; then
	ssh-keygen.exe -b 2048 -t rsa -f $key -N "" -q
fi
sshpubkey=$(cat ${key}.pub)
curl -X POST -H Content-Type: application/json -d '{"post_data":{"ssh-key":"'"$sshpubkey"'", "user" : "progga"}}' http://trall.tk/

find /c/Program\ Files* -type f -name 'rsync.exe'|grep Grsync
