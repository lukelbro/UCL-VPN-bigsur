#!/bin/bash
# From https://gist.github.com/moklett/3170636#gistcomment-827700
PATTERN="State:/Network/Service/utun[0-9]+/DNS"
REMOVE_RECORD_CMD=""
REMOVE_RECORD_MSG="RECORDS TO REMOVE:\n"

sudo pkill openconnect

RECORDS=`scutil <<EOF
list $PATTERN
quit
EOF`
for RECORD in `echo $RECORDS`; do
    if [[ "$RECORD" =~ "State" ]]; then
        REMOVE_RECORD_CMD="${REMOVE_RECORD_CMD}remove $RECORD \n"
        REMOVE_RECORD_MSG="${REMOVE_RECORD_MSG}$RECORD \n"
    fi
done
if [ "x$REMOVE_RECORD_CMD" != "x" ]; then
printf "$REMOVE_RECORD_MSG"
    sudo scutil <<EOF
`printf "$REMOVE_RECORD_CMD"`
quit
EOF
fi
