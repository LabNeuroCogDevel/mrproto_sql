#!/usr/bin/env bash

source $(dirname $0)/config.bash

[ ! -d dicominfo ] && mkdir dicominfo

# these dont change, so only do them if we dont have 'em
for study in ${STUDIES_OLD[@]}; do
 [ ! -r dicominfo/$study.txt ] && 
   ./getstudy.bash "$study" "${!study}" &
done

#for study in ${STUDIES[@]}; do
# ./getstudy.bash "$study" "${!study}" &
#done

wait
cat dicominfo/*txt > dicominfo.txt

