#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# put lunadate into sqlite for cog using psql
#  20200222WF  init

# TODO: get and check sex/dob from both dbs
outsql=fix_cog_lunadate.sql
[ -r $outsql ] && echo "$outsql exists! cog is done. not rerunning" && exit 1

echo -n > cog_luna_missing.txt 
sqlite3 db "select distinct patname from mrinfo where study like '%cog%'" | while read bid; do
   [[ $bid =~ ^0 ]] && birc="${bid:1}" || birc=$bid
   read lunadate patname <<< $(lncddb "
       select
          l.id || '_' || to_char(b.edate,'YYYYmmdd') as lunadate,
          b.id
       from enroll l join enroll b on
         b.pid=l.pid and
         l.etype like 'LunaID' and
         b.id like '$birc'")
  [ -z "$lunadate" ] && echo "$bid ($birc): no match in sql!" >> cog_luna_missing.txt  && continue
  echo "update mrinfo set lunadate = '$lunadate' where patname = '$bid'; "
done |tee $outsql
