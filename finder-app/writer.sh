#!/usr/bin/bash

writefile="$1"
writestr="$2"

if [[ -z $writefile || -z $writestr ]]; then
    echo "Missing argument. 2 arguments are required."
    exit 1
fi

mkdir -p "$(dirname $writefile)" && touch $writefile

if [[ $? -ne 0 ]]; then
    echo "Error when creating the file $writefile with content $writestr."
    exit 1
else 
     echo "Create successfully $writefile."
fi

echo $writestr > $writefile
if [[ $? -ne 0 ]]; then
    echo "Error when writing $writestr in $writefile."
else
    echo "Wrote successfully $writestr in $writefile."
fi