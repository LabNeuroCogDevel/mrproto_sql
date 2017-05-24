#!/usr/bin/env Rscript

## globals and 

suppressMessages(library(dplyr))     
#library(RSQLite) # needed for db, used interally by dplyr::src_sqlite
suppressMessages(library(lubridate)) # for testing age of table
library(methods) # needed b/c not loaded with Rscript

## gobals 
# what columns we can merge across
mergeBy = c('study','Name','RT','ET','PhaseEncodingDirection','Matrix')


# there are protocols with inconsistant names or 
# where each run of the same protcol type was named eg x1 x2
fixnames <- function(d) {
  d$Name <- as.character(d$Name)
  mmidx<-d$study=='multimodal'
  # all clock and switch become ep2d_MB_func, b/c protocol is the same
  d$Name[mmidx] <- gsub('ep2d_MB_[cs].*','ep2d_MB_func',d$Name[mmidx])
  # fix 2 l's
  d$Name[mmidx] <- gsub('MultimodallWM_v1_run4','MultimodalWM_v1_run4',d$Name[mmidx])

  # all multmodalWM are rally the same thing
  d$Name[mmidx] <- gsub('MultimodalWM_v1_run[1-4]','MultimodalWM_v1',d$Name[mmidx])

  petidx<-d$study=='pet'

  # started to number MTs -- but all protocols are the same
  d$Name[petidx] <- gsub('(tfl_(no)?MT)_x[0-9]','\\1',d$Name[petidx])
  d$Name[petidx] <- gsub('ep2d_BOLD_x[1-6]_200meas','ep2d_BOLD_200meas',d$Name[petidx])
  
  return(d)
}


rebuild_populare <- function(db) {
  mrinfo <- tbl(db,from='mrinfo') %>% as.data.frame() %>% fixnames
  # count all protocols with all the same values
  smry <- mrinfo %>% group_by(study,Name,RT,ET,PhaseEncodingDirection,Matrix) %>% summarise(first=min(Date),last=max(Date),n=n()) %>%  as.data.frame 
  
  # find the most represented one. 
  # sometimes we have scans that are named the same thing but have intentionally different settings
  # like 2 fieldmaps. idealy we'd have an equal number -- but indviduals might be repeated
  # so take anythig within  2% of the max count (and later make sure we have at least 5 scans)
  top <- smry %>% group_by(study,Name) %>% mutate(top=max(n),d=n-top,d.=ifelse(d > -n/50,0,d),r=rank(d)) %>% arrange(r)  
  top. <- top %>% filter(d.==0,n>5)
  
  
  # reduce output for easier exploring
  top.trunc <- top.[,c(mergeBy,'n','first','last')] #%>% filter(study=='pet')
  
  if(nrow(top.trunc) < 1L) {
    warning('FAILED TO BUILD popular_protocols')
    return
  }
  tryCatch( db$con %>% db_drop_table(table='popular_protocols'),error=function(e) cat("did not remove popular_protocols\n") )
  top.trunc <- copy_to(db,top.trunc,name='popular_protocols',temporary=F)
}



maxdate <- function(datestrvec) max(datestrvec[datestrvec!="NA"],na.rm=T) %>% ymd 
## rebuild popular if it's behind by more than 4 days
get_or_make_popular <- function(db) {

   # rebuild if necessary
   tryCatch( tbl(db,'popular_protocols') ,error=function(e) rebuild_populare(db) )
   
   top.trunc <- tbl(db,'popular_protocols')  %>% as.data.frame()
   mrinfo <- tbl(db,'mrinfo') %>% as.data.frame()
   #lastseen    <- maxdate(mrinfo$Date) 
   #lastpopular <- maxdate(top.trunc$last) 
   #maxdaysbehind <- 4
   #lagdate <- lastseen - maxdaysbehind

   #if (lastpopular=="NA" ||  lagdate > lastpopular ) {
   # top.trunc <- rebuild_populare(db) %>% as.data.frame()
   #}

   return(top.trunc)
}


# find bad in exampleIn
# using template 'top.trunc', which is probably popular protcolos from the db
findbad <- function(exampleIn,top.trunc) {
   M<-merge(top.trunc,exampleIn,all.y=T,by=mergeBy)

   notfoundidx <- is.na(M$first)
   bad <- M[notfoundidx,]
   if(nrow(bad)>0L){
    bad <- merge(
       bad %>% select(-n,-first,-last),
       #top.%>% select(-top,-d,-d.,-r) ,
       top.trunc, 
       all.x=T,by=c('study','Name'),suffix=c('.observed','.ideal'))
    #print.data.frame(bad %>% arrange(seqno),row.names=F)
   }
   return(bad)
}

fmtbad <- function(d) {
 d %>%
 select(
    study,lunadate,Name,seqno,
    RT.observed,RT.ideal,
    ET.observed,ET.ideal,
    phase.ob=PhaseEncodingDirection.observed,phase.ideal=PhaseEncodingDirection.ideal,
    Matrix.observed,Matrix.ideal,
    first,last,n) %>%
 # combine multple matches into one
 group_by(study,lunadate,Name,seqno) %>% 
 summarise_all(funs(paste(sep=":",collapse=":",unique(.)))) 
}

## example
badpetsubj <- function(id,mrinfo) {
 bad<-mrinfo[,c('lunadate','seqno',mergeBy,'dir','Operator')] %>% ungroup %>% filter(study=='pet',lunadate==id) %>% findbad(top.trunc) 
}

# an example
#top. %>% filter(study=='pet') %>% select(Name,RT,ET,phase=PhaseEncodingDirection,n,d,d.) %>% arrange(Name,n)%>% print.data.frame(row.names=F) 

# badpetsubj('11389_20160104') %>% select(study,lunadate,Name,RT.observed,RT.ideal,ET.observed,ET.ideal,phase.ob=PhaseEncodingDirection.observed,phase.ideal=PhaseEncodingDirection.ideal,Matrix.observed,Matrix.ideal,first,last)
# 
# allpet <- 
#  mrinfo[,c('lunadate','seqno',mergeBy,'dir','Operator')] %>%
#  ungroup %>% 
#  filter(study=='pet') %>%
#  findbad(top.trunc) %>%
#  fmtbad
# print.data.frame(allpet)
