#!/bin/bash
TMPDIR="/tmp/gitybeauty"
users=$(git shortlog -ns --since="$(date -d '7 days ago' '+%Y-%m-%d')" | awk '{print $2}' | sort -u)

mkdir -p ${TMPDIR}
rm -f ${TMPDIR}/*
#for user in "${users[@]}"
for user in ${users}
do
    filename="${TMPDIR}/${user}.stats"
    #echo "filename: ${filename}"
    rm -f ${filename}
    commits=$(git log --since="$(date -d '7 days ago' '+%Y-%m-%d')" --author="${user}" --format='%H' | head -n 10)
    for commit in ${commits}
    do
        for file in $(git diff-tree --no-commit-id --name-only -r ${commit} | grep grep '.py$' | cat)
        # 'i*pyn*b*$'
        do
            if [ -f "$file" ]
            then
                    #echo "${file}"
                    ext="${file##*.}"
                    if [[ "$ext" != "ipynb" ]]
                    then
                            #echo "$(jupyter nbconvert ${file} --stdout --to script | flake8 - --ignore=W391 | wc -l),$(cat ${file} | wc -l)"
                            echo $(flake8 ${file} | wc -l),$(cat ${file} | wc -l)
                    fi
            fi
        done >> ${filename}
    done
done

# output
{ echo "User,prettiness,lines python";
for file in $(ls -1 ${TMPDIR}/*)
do
   if [ -s "$file" ]
       then
               ugliness=$(awk -F, '{ ugly+=$1;lines+=$2} END {print 1-ugly/lines","lines}' ${file})
                   user=$(basename ${file%.*})
           echo "${user},${ugliness}"
       fi
done; } | csvlook