library(dplyr)
db <- src_sqlite('db')
d <- as.data.frame(tbl(db,'mrinfo'))
ds <- d %>% group_by(lunadate,id,PATSize,PATweight) %>% summarise(n=n())
