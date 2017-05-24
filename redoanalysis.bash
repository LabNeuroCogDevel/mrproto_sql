#!/usr/bin/env bash
cd $(dirname $0)
source ../funcs.src.bash
[ -z "$MRI_DB" -o ! -r "$MRI_DB" ] && warn "no db '$MRI_DB'" && exit 1

sqlite3 $MRI_DB 'delete from analysis'
./getPrepProc.bash > ppinfo.txt
sqlite3 $MRI_DB < import_preproc.sql
