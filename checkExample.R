source('funcs.R')
library(dplyr)
db <- src_sqlite('./db')
pop <- get_or_make_popular(db)

mrinfo <- tbl(db,'mrinfo') %>% as.data.frame()

mrinfo %>% filter(study=='p5',grepl('diff',Name)) %>% findbad(pop) %>% fmtbad %>% write.csv(file='p5dti.csv',row.names=F)


