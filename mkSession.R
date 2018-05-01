#!/usr/bin/env Rscript
# want to add session and session number
# after the fact hack
library(dplyr);
n<-strsplit(system('./hinfo -gethdr',intern=T),' ')[[1]]
n<-c('study',n)

# want to pull out
# 01.29.2013-15:37:30
# or if that doesnt exist: lunaid_date 
getsessionname.idv <- function(rawdir) {
 regex.time='[0-9.:-]{19}'
 regex.ld='[0-9]{5}_[0-9]{8}'
 session<-regmatches(rawdir,regexpr(regex.time,rawdir))
 if(length(session)==0L) session<-regmatches(rawdir,regexpr(regex.ld,rawdir))
 if(length(session)==0L) session<-"NULL"
 return(session)
}
sessionname <- function(rawdirvec) {
 unlist(lapply(rawdirvec,getsessionname.idv))
}

d <- 
 read.table("dicominfo.txt",sep=" ",header=F,comment.char="",quote=NULL,fill=T) %>% 
 # remove extra delimter created empty column
 `names<-`(c(n,'junk')) %>%
 select(-junk) %>%
 #mutate(session=basename(dirname(dirname(as.character(rawdir))))) %>% 
 #mutate(session=rawdir%>%as.character%>%dirname %>% basename) %>% 
 mutate(session=sessionname(rawdir)) %>% 
 group_by(dirid) %>% 
 mutate(sessionno=as.numeric(as.factor(session))) %>% 
 mutate(bad=F) 


write.table(d,row.names=F,col.names=F,quote=F,sep=" ",file="dicominfo_session.txt")

