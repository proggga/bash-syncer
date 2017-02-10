# loading config variables
source settings.conf
source src/system.sh

syncho:sshconnect() {
    $SSH_COMMAND -p$port $login@$server
}

syncho:sync_catalog_to_remote() {
     $RSYNC_COMMAND -arpvzP --delete -e "$SSH_COMMAND -p$port" . $login@$server:"$remotedir" 2>&1 >/dev/null;
}

# convert Windows path to Cygwin linux path
syncho:convert_dir_windows_to_linux() {
    :; #NOP
}

# promt which get dir, and check it existance
syncho:get_directory_from_terminal() {
    localdir=$1
    if [ -z "$localdir" ] ; then
        read -e -p "Please input directory of project: " localdir;
        localdir=$(echo $localdir | sed "s|~|$HOME|g")
    fi;
    if [ ! -d "$localdir" ] ; then
      system:raise_error "Directory '$localdir' does not exists";
    fi;
}

# stop syncing cycle
syncho:stop_syncing() {
    touch $STOP_FILE_PATH;
}

syncho:syncprocess() {
    localdir=$1
    currentdir=$2
    cd $localdir;
    syncho:syncing_cycle;
    cd $currentdir;
}

syncho:clear_files() {
    rm $STOP_FILE_PATH 2>/dev/null;
    rm $FILE_FOR_TIME_DIFF 2>/dev/null;
    rm $FILE_FOR_CYCLE_UPLOAD 2>/dev/null;
}

# main cycle which can sync everything
syncho:syncing_cycle() {
    syncho:is_cycle_working
    if [ "$SYNC_STATUS" ] ; then return; fi;

    touch $FILE_FOR_CYCLE_UPLOAD;
    last_changed="";
    last_md5sum="";
    while [ ! -f $STOP_FILE_PATH ];
    do
        touch -d '-0.2 seconds' $FILE_FOR_TIME_DIFF;
        changed="";
        filelist=$(find -name "*[^.]*" -type f -newer $FILE_FOR_TIME_DIFF 2>/dev/null);
        if [ "$filelist" ] && [ "$filelist" != "$last_changed" ]; then
            last_changed="$filelist";
            changed="true";
            last_md5sum=$(find . | $MD5_COMMAND);
        else
            last_changed="";
        fi;
        md5=$(find . | $MD5_COMMAND);
        if [ "$md5" != "$last_md5sum" ] ; then
            #echo "deleted";
            changed="true";
            last_md5sum=$md5
        fi;
        #echo "waiting"
        if [ "$changed" ] ; then
            changed="";
            syncho:sync_catalog_to_remote;
            touch $FILE_FOR_CYCLE_UPLOAD;
        else
            touch -d '-2 seconds' $FILE_FOR_TIME_DIFF;
            more_than_2seconds=$(find $FILE_FOR_CYCLE_UPLOAD ! -newer $FILE_FOR_TIME_DIFF)
            if [ "$more_than_2seconds" ] ; then touch $FILE_FOR_CYCLE_UPLOAD; fi;
        fi;
        sleep 0.1;
    done;
}

syncho:is_cycle_working() {
    SYNC_STATUS=""
    if [ -f "$FILE_FOR_TIME_DIFF" ] ; then
        SYNC_STATUS="WORKING";
        # ls -la $FILE_FOR_TIME_DIFF;
    fi;
}
