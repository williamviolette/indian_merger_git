//Company Information 

* identity data: what do the company and firm codes look like??
import delimited "34294_1_5_20190509_182020_dat.txt", delimiter("|") clear  bindquotes(nobind) 

	*keep if co_industry_type ===="1" //drops non-banking finance companies and banks 

	keep co_code company_name state_code owner_code owner_gp_name co_industry_gp_code co_nic_code ///
	incorporation_year hocity hoaddr hostate hopin corpaddr corpcity corpstate
	
	gen conglom_ind = 1
	replace conglom_ind =0 if owner_gp_name == "Private (Indian)" | owner_gp_name == "Private (Foreign)" | owner_gp_name == "Government Local Bodies" | owner_gp_name == "Joint Sector" | owner_gp_name == "State and Private sector" ///
	| owner_gp_name == "State Road Transports" | owner_gp_name == "State Govt. - Statutory Bodies" | owner_gp_name == "State Govt. - Departmental Undertaking" | owner_gp_name == "State Govt. - Commercial Enterprises" | owner_gp_name == "State Electricity Boards" | owner_gp_name == "Central & State Governments" ///
	| owner_gp_name == "Central Govt. - Commercial Enterprises" | owner_gp_name == "Central and Private sector" | owner_gp_name == "Central Govt. - Statutory Bodies" | owner_gp_name == "Central Govt. - Statutory Bodies" | owner_gp_name == "Central Govt. - Statutory Bodies" | owner_gp_name == "Central Govt. - Management Enterprises" | owner_gp_name == "Central Government - Takenover Enterprises" ///
	| owner_gp_name == "Central Govt. - Departmental Undertaking" | owner_gp_name == "Co-operative Sector" 
		
	gen m_ind = 0
	replace m_ind = 1 if(regexm(company_name, "MERGED"))
	tab m_ind 
	
	* do we care about SoEs? (State or National) vs privately owned? (Able to ID foreign owned) field: owner_code 

*ONLY one co_code per company_name. co_codes in this file will be the "origin" code used in later analyses to ID mergers etc. 
preserve 
keep co_code company_name owner_gp_name conglom_ind
duplicates drop
save "company_list.dta", replace 
restore


//Create list of companies with MERGED in the title and MERGED removed from the title 
preserve
keep if m_ind == 1  
keep company_name owner_gp_name
ren (company_name owner_gp_name) (target_co targ_gp)
replace target_co = subinstr(target_co, " [MERGED]", "",.) 
replace target_co = subinstr(target_co, "[MERGED]", "",.) 
bys target_co: gen n_codes = _n ==1 
drop if n_codes ==0 
drop n_codes
save "acq_company_list1.dta", replace 
restore

preserve
keep if m_ind == 1  
keep company_name owner_gp_name
ren (company_name owner_gp_name) (target_co targ_gp)
bys target_co: gen n_codes = _n ==1 
drop if n_codes ==0
drop n_codes 
save "acq_company_list2.dta", replace 
restore

preserve
keep if m_ind == 0  
keep company_name owner_gp_name
ren (company_name owner_gp_name) (target_co targ_gp)
bys target_co: gen n_codes = _n ==1 
drop if n_codes ==0
drop n_codes 
save "company_list1.dta", replace 
restore


use "acq_company_list1.dta", clear 
append using "acq_company_list2.dta"
append using "company_list1.dta"
sort target_co
duplicates drop 
duplicates tag target_co, gen(id)
drop if id ==1 & targ_gp =="Private (Indian)"
drop if id ==1 & targ_gp =="Private (Foreign)"
replace targ_gp = "Bangur P.D./B.G. Group" if targ_gp =="Bangur G.D. Group"
duplicates drop 
drop id 
save "acq_co_list.dta", replace 

//Product Section

	import delimited "34294_1_195_20190509_182020_dat.txt", delimiter("|") clear  bindquotes(nobind)
	
	ren products_cocode co_code 
	sort co_code 

	gen year = substr(string(prod_date,"%12.0g"),1,4)
	destring year, replace 

	sort co_code year 
	drop clubflag* 

	ds *, has(type string)
	foreach x of varlist `=r(varlist)' {
		replace `x' ="." if `x' =="NA" | `x' =="ER"
		destring `x', replace 
		}


	bys products_product_code: g pn=_n
	count if pn==1

	cap drop pnn
	bys product_name_mst: g pnn=_n
	count if pnn==1

	sort product_name 

save "product_info.dta", replace 


//Merger Section 

* Merger Event Table: 

	import delimited "34294_1_220_20190509_182020_dat.txt",  delimiter("|") clear  bindquotes(nobind) 

	keep co_code company_name me_date_of_info mr_info_full_name entity_name_mst acquirer owner_gp_name me_acquirer_product_gp_code product_name_mst
	tab mr_info_full_name

	gen m_ind = 0
		replace m_ind = 1 if(regexm(company_name, "MERGED"))
		replace m_ind =1 if mr_info_full_name == "Merger"
			tab m_ind 

	g year = substr(string(me_date_of_info,"%12.0g"),1,4)

	destring year, replace

	bys year: g yN=_N
	bys year: g yn=_n


	//scatter yN year if yn==1

	egen type = group(mr_info_full_name)

	tab type mr_info_full_name

	bys year type: g yNt=_N
	bys year type: g ynt=_n

	//scatter yNt year if ynt==1 & type==1 || ///
	//scatter yNt year if ynt==1 & type==2 || ///
	//scatter yNt year if ynt==1 & type==3 

save "merger_events.dta", replace 

*Merger 

	import delimited "34294_1_215_20190509_182020_dat.txt",  delimiter("|") clear  bindquotes(nobind) 

	keep co_code company_name mr_info_full_name merg_num mgtkas_date entity_name_mst acquirer asset_name ///
	acquirer_owner_code acq_owner_gp_name target_owner_code target_owner_gp_name modalities

	gen asset_ind = 0
	replace asset_ind = 1 if mr_info_full_name =="Sale of asset" 

	gen m_ind = 0
	replace m_ind =1 if(regexm(company_name, "MERGED"))
	replace m_ind =1 if mr_info_full_name == "Merger"
		tab m_ind 

save "merger_info.dta", replace 

//Annual Financials 
import delimited "$sa\34294_1_70_20190509_182020_dat.txt", delimiter("|") clear  bindquotes(nobind) 

ren (sa_finance1_cocode sa_company_name) (co_code company_name) 

g year = substr(string(sa_finance1_year,"%12.0g"),1,4)

destring year, replace

	ds *, has(type string)
	foreach x of varlist `=r(varlist)' {
		replace `x' ="." if `x' =="NA" | `x' =="ER"
		destring `x', replace 
		}

save "annual_financials.dta", replace 
