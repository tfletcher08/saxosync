#!/bin/bash

LOCALPATH=$1
REMOTEPATH=$2
SITEURL=$3

if [ -z $LOCALPATH ] || [ -z $REMOTEPATH ] || [ -z $SITEURL ]; then
    echo "Usage: saxosync <Local path> <Remote path> <Base Site url>"
    echo "Example: saxosync /static/web/static/content/sites/NJ/asburypark/app/ /376025/web/static/content/NJ/asburypark/app/ http://content-static.app.com/"
    echo "Note: Local path and base site url must end in '/'"
    exit 1
fi

REMOTEUSER="sshacs"
REMOTEHOST="uscpcontent.upload.akamai.com"
IDENTITYFILE="/home/jenkins/.ssh/id_rsa"
CCUCONFIGFILE="/home/jenkins/purge_config.cfg"
SSHOPTS="-i $IDENTITYFILE -o StrictHostKeyChecking=no"
RSYNCOPS=(-rzl --size-only --out-format='%i:%n' --delete -e "ssh ${SSHOPTS[@]}")

DELETEDFILES=()
MODIFIEDFILES=()

echo "Running sync.."
echo "Local path: $LOCALPATH"
echo "Remote path: $REMOTEPATH"

rm rsynclog.txt
rm purgeoutput.txt

rsync "${RSYNCOPS[@]}" $LOCALPATH $REMOTEUSER@$REMOTEHOST:$REMOTEPATH |tee rsynclog.txt

if [ -s rsynclog.txt ]; then
    echo "Log exists, continuing."
else
    echo "No log file. Either no changes exist or there was an error, check job output."
    exit 1
fi

DELETEDFILES=($(grep "*deleting" rsynclog.txt|cut -d ':' -f 2))
MODIFIEDFILES=($(grep -E "<[fdLDS][.c][.s][.tT][.p][.o][.g][.u][.a][.x]|cL[.c][.s][.tT][.p][.o][.g][.u][.a][.x]" rsynclog.txt|cut -d ':' -f 2))


if [ ${#DELETEDFILES[@]} -eq 0 ] && [ ${#MODIFIEDFILES[@]} -eq 0 ]; then
    echo "No files to purge, exiting"
    exit 0
fi

echo "I will purge ${#DELETEDFILES[@]} deleted files and ${#MODIFIEDFILES[@]} modified files"

URLLIST=""

for i in ${DELETEDFILES[@]} ${MODIFIEDFILES[@]}; do
    if [ -z $URLLIST ]; then
        URLLIST="\"$SITEURL$i\""
    else
        URLLIST="$URLLIST,\"$SITEURL$i\""
    fi
done

URLLIST="{\"objects\":[$URLLIST]}"

echo "Payload being sent to Akamai: $URLLIST"

python ../edgegrid-curl/egcurl --eg-config $CCUCONFIGFILE -sSik -H "Content-Type: application/json" -X POST -d "$URLLIST" https://akab-uttkurwznqtmpbw5-3gz2fnxrham6cu5k.purge.akamaiapis.net/ccu/v2/queues/default | tee purgeoutput.txt

RESPONSE=$(cat purgeoutput.txt|head -1|awk '{print $2}')

if [ "$RESPONSE" -ne "201" ]; then
    echo "ERROR: Got response $RESPONSE from Akamai, expecting 201."
    exit 1
fi

