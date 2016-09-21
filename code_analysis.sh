#!/bin/bash
TMPDIR="/tmp/gitbeauty"
LASTN=100
enabled_checkers=py R js sh php cpp

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
checkerstr=$(join_by '$\|' enabled_checkers)
echo "$checkerstr"

check_py() {
    { flake8 "$@"; pylint -E "$@"; frosted "$@"; }
}
check_R() {
    R --silent -e "library('lintr'); lint('$1')"
}
check_js() {
    jslint --terse "$@"
}
check_sh() {
    shellcheck -s bash "$@"
}
check_php() {
    phplint "$@"
}
check_cpp() {
    cppcheck "$@"
}
code_check() {
    ext="${1##*.}"
    case "$ext" in
        c,cpp) check_cpp "$1"
            ;;
        py) check_py "$1"
            ;;
        R) check_R "$1"
            ;;
        js) check_js "$1"
            ;;
        sh) check_sh "$1"
            ;;
        php) check_php "$1"
            ;;
   esac
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
        git diff-tree --no-commit-id --name-only -r "$commit"  | grep "$checkerstr" | cat
    done | sort -u)
    for file in $files
    do
        if [ -f "$file" ]
        then
           ext="${file##*.}"
           error_contrib=$(responsible "$file" | grep "$user" | tail -n 1 | awk '{ print $1 }' )
           if [ -n "$error_contrib" ]
           then
                lines=$(wc -l < "$file")
                errors=$(code_check_py "$file" 2> /dev/null | wc -l)
                if [[ "$ext" = "sh" ]]
                then
                    ugly=$(echo "$errors / 4 * $error_contrib" | bc -l)
                elif [[ "$ext" = "R" ]]
                then
                    ugly=$(echo "$errors / 3 * $error_contrib" | bc -l)
                else
                    ugly=$(echo "$errors * $error_contrib" | bc -l)
                fi
                echo "$ugly,$lines,$file"
           fi
        fi
    done >> "$filename"
done

# output
{ echo "user,prettiness,analysed lines";
for file in ${TMPDIR}/*
do
   if [ -s "$file" ]
       then
           ugliness=$(awk -F, '{ ugly+=$1;lines+=$2} END {print 1-ugly/lines","lines}' "$file")
           user=$(basename "${file%.*}")
           echo "${user},${ugliness}"
       fi
done; } | csvlook
