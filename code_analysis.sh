#!/bin/bash
#!/bin/bash
TMPDIR="/tmp/gitbeauty"
users=$(git shortlog -ns --since="$(date -d '7 days ago' '+%Y-%m-%d')" | awk '{print $2}' | sort -u)

function responsible {
    sum=$(wc -l < "$file")
    git blame -w --line-porcelain "$1" | grep -a "^author " | sort -f | uniq -c | sort -n | awk -v sum="$sum" '{ print $1/sum,$3 }'
}

mkdir -p ${TMPDIR}
rm -f ${TMPDIR}/*
for user in ${users}
do
    filename="${TMPDIR}/${user}.stats"
    rm -f "${filename}"
    commits=$(git log --since="$(date -d '7 days ago' '+%Y-%m-%d')" --author="${user}" --format='%H' | head -n 10)
    for commit in ${commits}
    do
        files=$(git diff-tree --no-commit-id --name-only -r "$commit" | grep 'py$' | cat)
        for file in $files
        do
            if [ -f "$file" ]
            then
                    ext="${file##*.}"
                    if [[ "$ext" = "py" ]]
                    then
                        error_contrib=$(responsible "$file" | grep "$user" | tail -n 1 | awk '{ print $1 }' )
                        lines=$(wc -l < "$file")
                        errors=$(flake8 "$file" | wc -l)
                        ugly=$(echo "$errors * $error_contrib" | bc -l)
                        echo "$ugly,$lines"
                    fi
            fi
        done >> "$filename"
    done
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