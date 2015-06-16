#!/bin/bash

#LOCALPATH="/static/web/satatic/content/sites/NJ/asburypark/app/"
LOCALPATH="/static/web/static/content/sites/NJ/asburypark/app/e-edition/"
REMOTEPATH="/376025/web/static/content/NJ/asburypark/app/e-edition"
#REMOTEPATH="/376025/web/static/content/NJ/asburypark/app/"
REMOTEUSER="sshacs"
REMOTEHOST="uscpcontent.upload.akamai.com"
IDENTITYFILE="/root/.ssh/id_rsa"
SSHOPTS="-i $IDENTITYFILE"
RSYNCOPS=(-rnzl --size-only --out-format='%i:%n' --delete -e "ssh ${SSHOPTS[@]}")

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
