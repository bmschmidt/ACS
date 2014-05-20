library(dplyr)
library(ggplot2)

returnWeights = function(weights=1:80) {
  if (!file.exists("weights.RData")) {
    persons = tbl(src=tables,"persons")
    query = 
      paste("SELECT SERIALNO,",paste0("PWGTP",1:80,collapse=","), "FROM persons LIMIT 30")
    elements = list(.data=persons,list(c("SERIALNO",paste0("PWGTP",weights))))
    data = do.call(s_select,elements) %.% collect()
    library(reshape2)
    n = melt(data,id.vars="SERIALNO")
    names(n) = c("SERIALNO","sample","weight")
    #I don't care if the sample numbers are the same, so just coerce
    n$sample = as.numeric(n$sample)
    save(n,file='weights.RData')
    return(n)
  } else {
    rm(n)
    load("weights.RData")
    return(n)
  }
}

writeOutFields = function() {
  #
  counts = persons %.% group_by(FOD1P) %.% summarize(count=n()) %.% arrange(-count) %.% collect()
  named = counts %.% encode("FOD1P")
  head(named)  
  write.table(named,file="majorNames.tsv",sep="\t",quote=F,row.names=F)
  #Then I assigned some values at MajorFields.tsv
}

encode = function(tab,fieldsname="FOD1P",looker=codebook) {
  #gives a factor sensible names from a codebook 
  lookups = looker %.% 
    filter(field==fieldsname) %.% 
    mutate(value = gsub(" $","",value),code=as.integer(code))
  counts = table(tab[,fieldsname])
  missingCounts = counts[!names(counts) %in% lookups$code]
  tab[,fieldsname] = 
    factor(tab[,fieldsname],levels = lookups$code,labels=lookups$value)
  tab
}

filterToTopN = function(frame,variable,n=30,countVariable=quote(PWGTP)) {
  topN = frame %.% regroup(list(variable)) %.% summarise(groupingCount=sum(countVariable)) %.% top_n(n)
  topN = topN[,1,drop=F]
  frame %.% inner_join(topN) 
}


factorByPrincomps = function(frame) {
head(frame)

}







#dplyr string workarounds:
# Helper functions that allow string arguments for  dplyr's data modification functions like arrange, select etc. 
# Author: Sebastian Kranz

# Examples are below

#' Modified version of dplyr's filter that uses string arguments
#' @export
s_filter = function(.data, ...) {
  eval.string.dplyr(.data,"filter", ...)
}

#' Modified version of dplyr's select that uses string arguments
#' @export
s_select = function(.data, ...) {
  eval.string.dplyr(.data,"select", ...)
}

#' Modified version of dplyr's arrange that uses string arguments
#' @export
s_arrange = function(.data, ...) {
  eval.string.dplyr(.data,"arrange", ...)
}

#' Modified version of dplyr's arrange that uses string arguments
#' @export
s_mutate = function(.data, ...) {
  eval.string.dplyr(.data,"mutate", ...)
}

#' Modified version of dplyr's summarise that uses string arguments
#' @export
s_summarise = function(.data, ...) {
  eval.string.dplyr(.data,"summarise", ...)
}

#' Modified version of dplyr's group_by that uses string arguments
#' @export
s_group_by = function(.data, ...) {
  eval.string.dplyr(.data,"group_by", ...)
}

#' Internal function used by s_filter, s_select etc.
eval.string.dplyr = function(.data, .fun.name, ...) {
  args = list(...)
  args = unlist(args)
  code = paste0(.fun.name,"(.data,", paste0(args, collapse=","), ")")
  df = eval(parse(text=code,srcfile=NULL))
  df  
}

# Examples
library(dplyr)

# Original usage of dplyr
mtcars %.%
  filter(gear == 3,cyl == 8) %.%  
  select(mpg, cyl, hp:vs)

# Select user specified cols.
# Note that you can have a vector of strings
# or a single string separated by ',' or a mixture of both
cols = c("mpg","cyl, hp:vs")
mtcars %.%
  filter(gear == 3,cyl == 8) %.%  
  s_select(cols)

# Filter using a string
col = "gear"
mtcars %.%
  s_filter(paste0(col,"==3"), "cyl==8" ) %.%
  select(mpg, cyl, hp:vs)

# Arrange without using %.%
s_arrange(mtcars, "-mpg, gear, carb")

# group_by and summarise with strings
mtcars %.%
  s_group_by("cyl") %.%  
  s_summarise("mean(disp), max(disp)")