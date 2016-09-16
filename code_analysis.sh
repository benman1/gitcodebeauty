#!/bin/bash
TMPDIR="/tmp/gitbeauty"
FLAKE8OPTS="--import-order-style=google --application-import-names=flake8_strings"
LASTN=100

code_check() {
    { flake8 $FLAKE8OPTS "$@"; pylint -E "$@"; }
}

gnudate() {
    if hash gdate 2>/dev/null; then
        gdate "$@"
    else
        date "$@"
    fi
}

responsible() {
    sum=$(wc -l < "$file")
    git blame -w --line-porcelain "$1" | grep -a "^author " | sort -f | uniq -c | sort -n | awk -v sum="$sum" '{ print $1/sum,$3 }'
}

users=$(git shortlog HEAD -ns --since="$(gnudate -d '7 days ago' '+%Y-%m-%d')" | awk '{print $2}' | sort -u)
mkdir -p ${TMPDIR}
rm -f ${TMPDIR}/*
for user in ${users}
do
    filename="${TMPDIR}/${user}.stats"
    rm -f "${filename}"
    commits=$(git log --since="$(gnudate -d '7 days ago' '+%Y-%m-%d')" --author="${user}" --format='%H' | head -n "$LASTN")
    files=$(for commit in ${commits}
    do
        git diff-tree --no-commit-id --name-only -r "$commit" | grep 'py$' | cat
    done | sort -u)
    for file in $files
    do
        if [ -f "$file" ]
        then
            ext="${file##*.}"
            if [[ "$ext" = "py" ]]
            then
                error_contrib=$(responsible "$file" | grep "$user" | tail -n 1 | awk '{ print $1 }' )
               if [ -n "$error_contrib" ]
               then
                    lines=$(wc -l < "$file")
                    errors=$(code_check "$file" 2> /dev/null | wc -l)
                    ugly=$(echo "$errors * $error_contrib" | bc -l)
                    echo "$ugly,$lines,$file"
                fi
            fi
        fi
    done >> "$filename"
done

# output
{ echo "user,prettiness,lines python";
for file in ${TMPDIR}/*
do
   if [ -s "$file" ]
       then
           ugliness=$(awk -F, '{ ugly+=$1;lines+=$2} END {print 1-ugly/lines","lines}' "$file")
           user=$(basename ${file%.*})
           echo "${user},${ugliness}"
       fi
done; } | csvlook
