#!/usr/bin/env Rscript
source('funcs.R')
# where the database is
db <- src_sqlite('./db')
# headers from `./hinfo -rhead`
args = commandArgs(trailingOnly=TRUE)
options(width=10000)
if(length(args)==1L && file.exists(args[1])){
  #d <- read.table(args[1],header=T,sep=" ")
  d <- read.table(args[1],header=T) # no sep for p5 (20170523)

  # checkd ata
  columns <- c('lunadate','seqno',mergeBy,'dir','Operator')
  missingCols <- ! columns %in% names(d)
  if(any( missingCols )) stop('input needs to have header columns: ',paste(collapse=",",columns[missingCols]))

  popular_protocols <- get_or_make_popular(db)
  # find bad
  bad <- d %>% fixnames  %>% select_(.dots=columns) %>% findbad(popular_protocols)
  if(nrow(bad) == 0L) {
    notmpInName <- gsub('^\\..*?_','',args[1],perl=T) # if given a temp file it'll look like '.XXXX_' -- remove that
    cat('# ',notmpInName," all good\n")
    quit(save="no",0)
  }
  bad <- bad %>% fmtbad
  print.data.frame(bad,row.names=F)
}
