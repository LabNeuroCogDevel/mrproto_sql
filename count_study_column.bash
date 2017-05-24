#!/usr/bin/env bash
study=$1; shift
column=$1;shift
proto=$1; shift
usepopular=$1; shift

usage() {
 cat <<HEREDOC
USAGE:
$0 study column [protocolName] [popular]
 list counts for all values of a column within a study, optionally restricted to a specific protcol name
 useful for exploring after checkForMistake.R
 optionaly add 'popular' to the end of the call to pull from the popular_protocol table
HEREDOC
}
[[ -z "$column" || $study =~ help$ || $study == "-h" ]] && usage && exit 1

[ "$column" == "phase" ] && column="PhaseEncodingDirection"

# search all if no protocol
[ "$proto" == "popular" ] && proto="%"  && usepopular="popular"
[ -z "$proto" ] && proto="%" 


if [ "$usepopular" == "popular" ]; then
  table="popular_protocols"
  n_and_date="n,first,last"
else
  table="mrinfo"
  n_and_date="
    count(*) as n,
    min(Date) as first,
    max(Date) as last "
fi

sqlite3 -header $(dirname $0)/db "
   select 
    $column,
    $n_and_date,
    group_concat(distinct(Name)) as protocols
   from $table 
   where study like '$study' and 
   Name like '$proto'  
   group by $column" | column -ts "|"
