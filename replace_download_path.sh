#!/usr/bin/bash

###############################################################################
# Usage:
#   bash replace_download_path.sh <path/file> <seach_string> <replace_string>
#
###############################################################################

SEARCH_PATH=$1
DOWNLOAD_PATH=$2
REPLACE_PATH=$3

CURRENT_FILE=""
OLD_PATH_CONTENT=""
NEW_PATH_CONTENT=""
OFFSET_SIZE=0
DEBUG_LOG=""

# sleep time to make update file look interesting, set to 0 if we don't care output log :)
SLEEP_TIME=0.1
VERBOSE_MODE=1

# dump log
function DUMP_LOG {
   if [[ "${VERBOSE_MODE}" == "1" ]] ; then
      echo -ne "${DEBUG_LOG}\033[0K\r"
      sleep $SLEEP_TIME
   fi
}

# get offset size of replaced path
function GET_OFFSET_SIZE {
   old_path_size=${#DOWNLOAD_PATH}
   new_path_size=${#REPLACE_PATH}
   OFFSET_SIZE=$((${new_path_size} - ${old_path_size}))
}

# replace new path
function GET_NEW_LINE {
   OLD_PATH_CONTENT=`grep -oh "directory[^:]*:[^:]*" $CURRENT_FILE`
   current_size=`echo $OLD_PATH_CONTENT| sed s/directory// | sed s/:.*//`
   new_size=$(($current_size + ${OFFSET_SIZE}))
   NEW_PATH_CONTENT=`echo ${OLD_PATH_CONTENT/directory${current_size}:/directory${new_size}:}`
   NEW_PATH_CONTENT=`echo ${NEW_PATH_CONTENT/${DOWNLOAD_PATH}/${REPLACE_PATH}}`
}

# replace the content of .torrent.rtorrent file
function REPLACE_FILE {
   DEBUG_LOG="Replacing file $CURRENT_FILE ..." ; DUMP_LOG
   while read line; do
      echo ${line/${OLD_PATH_CONTENT}/${NEW_PATH_CONTENT}}
   done < $CURRENT_FILE > ./temp.txt
   mv ./temp.txt $CURRENT_FILE
}

# main
GET_OFFSET_SIZE
if [[ -d $SEARCH_PATH ]] ; then
   echo "Searching directory ${SEARCH_PATH} ..."
   for rtorrent_file in "$SEARCH_PATH"/*.torrent.rtorrent
   do
      CURRENT_FILE=${rtorrent_file}
      GET_NEW_LINE
      REPLACE_FILE
   done
elif  [[ -f $SEARCH_PATH ]] ; then
   CURRENT_FILE=${SEARCH_PATH}
   GET_NEW_LINE
   REPLACE_FILE
else
   echo "Directory or file not found !!!"
   exit
fi

echo ""
echo "DONE"
