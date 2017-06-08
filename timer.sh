#!/bin/bash
startTime=$( date +'%s' )
currentTime=$( date +'%s' )
diff=$(($currentTime-$startTime))
while [ $(($currentTime-$startTime)) -lt $1 ]; do
    let currentTime=$( date +'%s' )
    let diff=$(($currentTime-$startTime))
    echo -ne $diff
    echo -ne '\r '
done