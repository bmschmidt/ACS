

codebook = read.table("codebook.tsv",sep="\t",stringsAsFactors=F)
names(codebook) = c("field","fieldname","code","value")

nrow=10000
library(dplyr)
library(ggplot2)
tables = src_mysql("ACS",user='bschmidt',password="Try my raisin Brahms")
persons = tbl(src=tables,"persons")


table = persons %.% select(AGEP,FOD1P,PWGTP,PWGTP1) %.% collect() %.% encode("FOD1P")


rounding=2
table = table%.%
  mutate(decade=rounding*floor((2012-AGEP)/rounding))
p = table %.% filterToTopN("FOD1P",35) %.% filter(!is.na(FOD1P))
ageTotals = p %.% group_by(decade) %.% summarise(collegePop = sum(PWGTP))

totals = p %.% inner_join(ageTotals) %.% group_by(FOD1P,decade) %.% summarise(count=sum(PWGTP/collegePop))

ggplot(totals) + geom_area() + aes(x=decade+20,y=count,fill=FOD1P) + facet_wrap(~FOD1P)


commutes = persons %.% select(JWMNP,FOD1P,AGEP) %.% collect() %.% encode("FOD1P") %.% filterToTopN("FOD1P",25)
ggplot(commutes) + geom_boxplot(aes(y=JWMNP,x=FOD1P)) + coord_flip() + scale_y_log10()



#### Employed at all:

ESR


raw = persons %.% select(PINCP,AGEP,ESR,FOD1P,SEX,PWGTP) %.% filter(SCHL>=21,AGEP < 60,AGEP>22) %.% collect()

employed = raw %.% encode("FOD1P") %.% encode("SEX") %.% encode("ESR")
employed = employed %.% filterToTopN("FOD1P",35)

employStatus = employed %.% filter(AGEP>30,AGEP<39) %.% 
  group_by(FOD1P,SEX) %.% 
  mutate(totals = sum(PWGTP)) %.% 
  group_by("ESR") %.%
  summarize(percent=sum(PWGTP/totals))
  
  
ggplot(employStatus) + 
  geom_bar(aes(fill=ESR,x=FOD1P,y=percent),stat="identity") + coord_flip() + facet_wrap(~SEX)




raw = persons %.% select(PINCP,AGEP,PWGTP,PWGTP1,FOD1P,SEX,SCHL)  %.% filter(SCHL>=21,AGEP < 60,AGEP>20,WKHP>30) %.% collect()
incomes = raw %.% encode("FOD1P") %.% encode("SEX") %.% encode("SCHL")
ggplot(incomes %.% group_by(AGEP,SCHL) %.% 
         summarise(income=mean(PINCP))) + geom_line(aes(x=AGEP,y=income,color=SCHL))

rounding=5

primeYears = incomes %.% filterToTopN("FOD1P",25) %.%
  mutate(decade=rounding*floor((2012-AGEP)/rounding),ageGroup = ifelse(AGEP<26,"25 or under",ifelse(AGEP<=33,"26-35",ifelse(AGEP<=45,"36-45",ifelse(AGEP<=60,"46-60","Over 60"))))) %.% 
  filter(decade >= 1955,decade<=1985)

yearly = primeYears  %.%
  group_by(FOD1P,decade) %.% 
  summarise(income=weighted.mean(as.numeric(PINCP),weights=PWGTP)) %.%
  arrange(-income)

byBins = primeYears %.%
  group_by(FOD1P,ageGroup,SEX) %.%
  summarise(income=weighted.mean(as.numeric(PINCP),weights=PWGTP),median=median(PINCP)) %.%
  group_by(FOD1P,add=F) %.% mutate(overall=median(median)) %.%
  arrange(-overall)

ggplot(byBins) + facet_wrap(~FOD1P) + geom_bar(aes(x=ageGroup,y=median,fill=SEX),position="dodge",stat="identity") + scale_y_continuous(trans="sqrt")

ggplot(byBins) + facet_wrap(~ageGroup) + 
  geom_bar(aes(x=reorder(FOD1P,overall),y=median,fill=SEX),position="dodge",stat="identity") + coord_flip()

persons

PHDS = persons %.% filter(SCHL==24,AGEP < 60,AGEP>20,WKHP>30) %.% select(PINCP,AGEP,PWGTP,PWGTP1,FOD2P,SEX) %.% collect()
docs = PHDS %.% encode("FOD2P") %.% encode("SEX") %.% filterToTopN("FOD2P",25) %.%
  mutate(decade=rounding*floor((2012-AGEP)/rounding),ageGroup = ifelse(AGEP<26,"25 or under",ifelse(AGEP<=33,"26-35",ifelse(AGEP<=45,"36-45",ifelse(AGEP<=60,"46-60","Over 60")))))

docs %.% group_by(SEX,FOD2P) %.% 
  summarise(income=weighted.mean(as.numeric(PINCP),weights=PWGTP),num=n(),median = median(PINCP)) %.% 
  arrange(-median)

ggplot(byBins) + facet_wrap(~FOD2P) + geom_line(aes(x=2012-decade,y=income))

