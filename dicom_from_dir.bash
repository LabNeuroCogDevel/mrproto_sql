#!/usr/bin/env bash
source $(dirname $0)/config.bash

# we can explcilty ask for the column names spit out by this script
# clean up the names bit for use with
# checkForMistake.R
if [ "$1" == "-rhead" ]; then 
 $(dirname $0)/hinfo -v |
  sed 's/^/study lunadate dir seqno ndcm /;
       s/EchoTime/ET/;
       s/RepetitionTime/RT/;
       s/ACQ//g;
       s/AcquisitionMatrix/Matrix/;
       s/ProtocolName/Name/;
       s/IDOperatorsName/Operator/;'
  shift;
  [ -z "$1" ] && exit 0
fi

## input check
d=$1
[ -z "$d" ]    && echo "$0: given no directory!" >&2 && exit 1
[ ! -r "$d" ]  && echo "$0: '$d' DNE"            >&2 && exit 1


## match lunaid
id=""
[[ "$d" =~ 1[0-9][0-9][0-9][0-9][/_][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] && id=${BASH_REMATCH//\//_}
# for CogLong
[ -z "$id" ] && [[ "$d" =~ /([0-9]{12})/[0-9]{3} ]] && id=${BASH_REMATCH[1]}
[ -z "$id" ] && [[ "$d" =~ /[Bb]([0-9]{4}) ]] && id=${BASH_REMATCH[1]}
[ -z "$id" ] && echo "no id in $d!" >&2 && exit 1 

## skip phoenix zip report
[[ "$d" =~ /PhoenixZIPReport ]] && exit 0
[[ "$d" =~ Head_mrac_pet_ute_vb20 ]] && echo "skipping $d" >&2 && exit 0

## study is 2nd argument or determined from folder
## default to 'unkown'
study="unknown"
if [ -n "$2" ]; then
  study="$2"
else
   for teststudy in ${STUDIES[@]}; do
    studypatt=${!teststudy}      # get study path from variable with name of value in teststudy
    studypatt=${studypatt//\**/} # remove */*/* part of study variable
    # if it matches, set the study and end this
    [[ $d =~  "$studypatt" ]] && study=$teststudy && break
   done
fi

## 
dir="$(cd $d;pwd)"
ndcm=$(find $d -maxdepth 1 -type f -not -iname 'need_*' |wc -l|sed 's/ //g')
seqno=$(basename $d | perl -F\\. -slane 'print "$F[$#F]"')
[ -z $seqno ] && seqno=$(basename $d| 'sed s/^0\+//')

## put it out
echo -ne "$study $id $dir $seqno $ndcm "
$(dirname $0)/hinfo $d 
echo
