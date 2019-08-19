
cd "K:\BE\1255\Projects\Indian Mergers\work\data\original"

* Products traded/produced
* 34294_1_195_20190509_182020_dat.txt
* 34294_1_195_20190509_182020_map.txt


* identity data: what do the company and firm codes look like??
import delimited "34294_1_5_20190509_182020_dat.txt", delimiter("|") clear  bindquotes(nobind) 

* There are company codes
* AND owner group codes!

* what do we know for mergers/acquisitions?




import delimited "34294_1_195_20190509_182020_dat.txt", delimiter("|") clear  bindquotes(nobind) 

bys products_product_code: g pn=_n
count if pn==1

cap drop pnn
bys product_name_mst: g pnn=_n
count if pnn==1


* Merger and Acquisition events
* 34294_1_220_20190509_182020_dat.txt
* 34294_1_220_20190509_182020_map.txt

* Merger and Acquisitions
* 34294_1_215_20190509_182020_dat.txt
* 34294_1_215_20190509_182020_map.txt



* * merger events * *

import delimited "34294_1_220_20190509_182020_dat.txt",  delimiter("|") clear  bindquotes(nobind) 

tab mr_info_full_name

g year = substr(string(me_date_of_info,"%12.0g"),1,4)

destring year, replace

bys year: g yN=_N
bys year: g yn=_n


scatter yN year if yn==1

egen type = group(mr_info_full_name)

tab type mr_info_full_name

bys year type: g yNt=_N
bys year type: g ynt=_n

scatter yNt year if ynt==1 & type==1 || ///
scatter yNt year if ynt==1 & type==2 || ///
scatter yNt year if ynt==1 & type==3 





