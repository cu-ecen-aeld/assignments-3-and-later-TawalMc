#!/usr/bin/bash

filesdir="$1"
searchstr="$2"

echo "$searchstr in $filesdir"

if [[ -z $filesdir || -z $searchstr ]]; then
    echo "Missing argument. 2 arguments are required."
    exit 1
fi

if [[ ! -d $filesdir ]]; then
    echo "${filesdir} is not a valid directory."
    exit 1
fi

nb_files=$(find "$filesdir" -type f | wc -l)
matching_files=$(grep -rh "$searchstr" "$filesdir" | wc -l)

echo "finder.sh: The number of files are $nb_files and the number of matching lines are $matching_files."