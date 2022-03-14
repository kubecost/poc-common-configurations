#!/bin/bash

# pass any argument to script to perform in reverse

passwords=$(awk -F: '{ print $2":"$1 }' keys.txt)
[ $# -eq 0 ] && passwords=$(< keys.txt)

for f in $(find ./ -type f \( -iname \*.json -o -iname \*.yaml \))
do
    printf "$f\n"
    while IFS= read -r key; do
        printf "    $key\n"
        sed -i -e "s:$key:g" "$f"
    done <<< $passwords
done