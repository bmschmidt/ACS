

database: ss12pusa.csv
	mysql < makeDatabase.SQL
	touch database

csv_pus.zip:
	wget http://www2.census.gov/acs2012_3yr/pums/csv_pus.zip

ss12pusa.csv: csv_pus.zip
	unzip csv_pus.zip

Sequence_Number_and_Table_Number_Lookup.txt:
	wget http://ftp2.census.gov/acs2012_3yr/summaryfile/Sequence_Number_and_Table_Number_Lookup.txt

codebook.txt: PUMS_Data_Dictionary_2010-2012.pdf
	pdf2txt.py PUMS_Data_Dictionary_2010-2012.pdf > codebook.txt

weights.txt: database
	mysql -e "SELECT SERIALNO, PWGTP1,PWGTP2,PWGTP3,PWGTP4,PWGTP5,PWGTP6,PWGTP7,PWGTP8,PWGTP9,PWGTP10,PWGTP11,PWGTP12,PWGTP13,PWGTP14,PWGTP15,PWGTP16,PWGTP17,PWGTP18,PWGTP19,PWGTP20,PWGTP21,PWGTP22,PWGTP23,PWGTP24,PWGTP25,PWGTP26,PWGTP27,PWGTP28,PWGTP29,PWGTP30,PWGTP31,PWGTP32,PWGTP33,PWGTP34,PWGTP35,PWGTP36,PWGTP37,PWGTP38,PWGTP39,PWGTP40,PWGTP41,PWGTP42,PWGTP43,PWGTP44,PWGTP45,PWGTP46,PWGTP47,PWGTP48,PWGTP49,PWGTP50,PWGTP51,PWGTP52,PWGTP53,PWGTP54,PWGTP55,PWGTP56,PWGTP57,PWGTP58,PWGTP59,PWGTP60,PWGTP61,PWGTP62,PWGTP63,PWGTP64,PWGTP65,PWGTP66,PWGTP67,PWGTP68,PWGTP69,PWGTP70,PWGTP71,PWGTP72,PWGTP73,PWGTP74,PWGTP75,PWGTP76,PWGTP77,PWGTP78,PWGTP79,PWGTP80 FROM persons" ACS | awk 'BEGIN{FS="\t";OFS="\t"}{ if ($$1!="SERIALNO") {for(i = 2; i <= NF; i++) { print $$1,i-1,$$i; }}}' > weights.txt

codebook.tsv: codebook.txt
#There are some weird whitespace characters in here...
	perl -ne 's/\s/ /g; if (m/^([A-Z0-9]{1,}) +[0-9]/){$$field=$$1};if (m/^\s{4,5}([A-Z].*[^ ])/){$$realname=$$1};if (m/^ {10,}([0-9]+) \.(.*[^ ])/) {$$code=$$1;$$name=$$2; print "$$field\t$$realname\t$$code\t$$name\n"}' $< > $@
