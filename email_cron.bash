#!/usr/bin/env bash

# remove duplicate headers and sort so header is on top 
headerfirst(){ sed 's/^ *study/0study/g'| column -t|sort |uniq|sed 's/0study/study/g'; }
# html needs br for line breaks
addbr(){ sed 's/$/<br>/'; }

# print a stream and error at the end if the stream was empty
checkempty(){ perl -pse '$l=$_;END{exit 1 if $.<=1 && $l eq "" }'; }

#
#mailit(){ mail  -a 'Content-Type: text/html' -s "MR report one last time" willforan@gmail.com; } 

wrapmono() { sed '1s/^/<body><div style="font-family:monospace;font-size=9"><pre>\n/; $s:$:\n</pre></div></body>:'; }

# what's new from yesterday
# find switches: 
#  -daystart -ctime -1  (newer than one day ago from the start of today)
# slightly different than -ctime 0 (relative to execution time)
report() {
  find /Volumes/Phillips/Raw/MRprojects/ \
    -mindepth 3 -maxdepth 3 -type d \
    -ipath '*20[0-9[0-9]*' -and -not -ipath '*/WPC*' \
    -daystart -ctime -1 |
    # run basename on each entry unless there are none (-r==--no-run-if-empty)
    xargs -rn1 basename |
    xargs -rn1 ./checksubj.bash 2>/dev/null  
}
#whats new this week
seenew() { find /Volumes/Phillips/Raw/MRprojects/ -mindepth 3 -maxdepth 3 -type d -ipath '*20[0-9[0-9]*' -and -not -ipath '*/WPC*' -ctime -8 -printf "%c\t%P\n";} 

doit() {
    mailtxt=$(
      report |
      headerfirst | 
      addbr | 
      wrapmono)

    [ -n "$mailtxt" ] && echo "$mailtxt" | mail -a 'Content-Type: text/html' -s "MR report protocol report" lncd_notification@googlegroups.com
}


# run if running (not sourcing)
[ "${BASH_SOURCE}" == $0 ] && cd $(dirname $0) && doit
