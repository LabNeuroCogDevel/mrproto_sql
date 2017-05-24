#!/usr/bin/env bash

source $(dirname $0)/config.bash

[ ! -d dicominfo ] && mkdir dicominfo

for study in ${STUDIES[@]}; do
  echo "starting $study $(date )"
  for d in ${!study}; do
       ./dicom_from_dir.bash $d $study || continue
       echo $d >&2
  done > dicominfo/$study.txt
  echo "finished $study $(date )"
done
cat dicominfo/*txt > dicominfo.txt

