#!/bin/bash

# by default, this script replaces the placeholder with the secret value
passwords=$(awk -F: '{ print $2":"$1 }' keys.txt)

# pass any argument to script to perform in reverse
[ $# -eq 0 ] && passwords=$(< keys.txt)

for f in $(find ./ -type f \( -iname \*.json -o -iname \*.yaml \))
do
    #      \color%string\newline "what to print"
    printf '\e[33m%s\e[0m%s\n' "File= $f"
    while IFS= read -r key; do
        #printf "    $key\n"
        if [[ "$key" =~ "#" ]]; then
            printf '\e[32m%s\e[0m%s\n' "Group= $key";
        else
          printf "$key\n";
          sed -i -e "s:$key:g" "$f";
        fi
    done <<< $passwords
done
