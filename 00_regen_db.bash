#!/usr/bin/env bash
cd $(dirname $0)

set -e
MRI_DB=db

if [ $(uname) == "Darwin" ];then
  _stat(){ stat -f "%Sm" -t "%Y%m%d" $1; }
else
  _stat(){ stat -c %y $1|sed s/-//g|cut -f1 -d' '; }
fi

# where to store old dicominfo.txt
[ ! -d old ] && mkdir old
# creates dicominfo.txt, used by import.sql
[ -r dicominfo.txt ] && mv dicominfo.txt old/$(_stat dicominfo.txt)

date +%s > timeit
# get header for all mr scans
./getHdr.bash # create dicominfo.txt -- list of all headers
./mkSession.R # create dicominfo_session.txt -- used by import.sql
Rscript -e 'source("funcs.R"); rebuild_populare( src_sqlite("./db"))'

# move to back if it's not empty
[ -r $MRI_DB -a $(du -m $MRI_DB|awk '{print $1}') -gt 0 ] && mv $MRI_DB $MRI_DB.bak

# recreate the database
[ -r $MRI_DB ] && rm $MRI_DB
sqlite3 $MRI_DB < <(
 cat  \
  schema.sql \
  import.sql \
  mksubj.sql \
  mkvisit.sql \
)
date +%s >> timeit

# add analysis to db
#./redoanalysis.bash
