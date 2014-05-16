
encode = function(tab,fieldsname="FOD1P",looker=codebook) {
  lookups = looker %.% filter(field==fieldsname) %.% mutate(value = gsub(" $","",value),code=as.integer(code))
  tab[,fieldsname] = 
    factor(tab[,fieldsname],levels = lookups$code,labels=lookups$value)
  tab
}

filterToTopN = function(frame,variable,n=30) {
  topN = frame %.% regroup(list(variable)) %.% summarise(groupingCount=sum(PWGTP)) %.% top_n(n)
  topN = topN[,1,drop=F]
  frame %.% inner_join(topN) 
}