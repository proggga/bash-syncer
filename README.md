# Bash-syncer

This program can be used for syncing files from your local storage to remote.
Main difference from rsync/scp this script provide forever loop, which allow editing code and deploy in realtime.

It can work from Windows too.

Main script run, and ask for dir in cygwin format (like /cygdrive/c/Users/MyCurrentUsername/Projects/MainProject)
And it will connect to server which defined in settings.conf (you can take settings.conf.example)
and this script will sync to remote dir
