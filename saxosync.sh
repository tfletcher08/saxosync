#!/bin/bash

LOCALPATH="$1"
REMOTEPATH="$2"
SITEURL="$3"


REMOTEUSER="sshacs"
REMOTEHOST="uscpcontent.upload.akamai.com"
IDENTITYFILE="/home/jenkins/.ssh/id_rsa"
SSHOPTS="-i $IDENTITYFILE -o StrictHostKeyChecking=no"
RSYNCOPS=(-rnzl --size-only --out-format='%i:%n' --delete -e "ssh ${SSHOPTS[@]}")

DELETEDFILES=()
MODIFIEDFILES=()

echo "Running sync.."
echo "Local path: $LOCALPATH"
echo "Remote path: $REMOTEPATH"

rsync "${RSYNCOPS[@]}" $LOCALPATH $REMOTEUSER@$REMOTEHOST:$REMOTEPATH |tee rsynclog.txt

if [ -s rsynclog.txt ]; then
    echo "Log exists!"
else
    echo "No log file?"
    exit 1
fi

DELETEDFILES=($(grep "*deleting" rsynclog.txt|cut -d ':' -f 2))
MODIFIEDFILES=($(grep -E "<[fdLDS][.c][.s][.tT][.p][.o][.g][.u][.a][.x]|cL[.c][.s][.tT][.p][.o][.g][.u][.a][.x]" rsynclog.txt|cut -d ':' -f 2))

echo "I will purge ${#DELETEDFILES[@]} deleted files and ${#MODIFIEDFILES[@]} modified files" 

for i in ${DELETEDFILES[@]}; do
    echo "Insert curl for purging $SITEURL$i here"
done


for i in ${MODIFIEDFILES[@]}; do
    echo "Insert curl for purging $SITEURL$i here"
done
