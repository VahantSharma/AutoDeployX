#!/bin/bash
THRESHOLD=80
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "Disk usage is above $THRESHOLD%. Current usage: $USAGE%"
    echo "Subject: Disk Usage Alert" | sendmail -v vahantofficials12315@gmail.com
fi

