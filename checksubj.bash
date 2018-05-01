#!/usr/bin/env bash
cd $(dirname $0)
source config.bash
id=$1

## find subject
if [ -n "$id" ]; then
   rawsubjdir=""
   for study in ${STUDIES[@]}; do
     path=$(echo "${!study}" | sed "s:/\*/\*/\*::")
     rawsubjdir=$(find $path -maxdepth 2 -mindepth 2 -type d -name "$id" |sed 1q)
     [ -n "$rawsubjdir" ] && break
   done
   ! [ -n "$rawsubjdir" -a -d "$rawsubjdir" ] && exiterr "cannot find $id in ${STUDIES[@]}"
else
  echo "newest $pet"
  searchdir="$(rawrootof "$pet")"
  rawsubjdir=$(\ls -dt $searchdir/*/* |sed 1q)
fi
## Run

tmpfile=$(mktemp .XXXX_$id )
[ -z "$tmpfile" ] && tmpfile=".tmp"
(
 ./dicom_from_dir.bash -rhead |sed 's/ $//'
 for d in $rawsubjdir/*/; do 
    # bad dirs will not have 5 fields (study,id,path, dirroot, count); so check the length of the 7th field
   ./dicom_from_dir.bash "$d" | awk '( length($7) > 0){print}'
 done
) >  $tmpfile


./checkForMistake.R $tmpfile
rm $tmpfile
exit 0
