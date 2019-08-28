
version 14.0 
set more off 

cd "K:\BE\1255\Projects\Indian Mergers\work\data\original"

capture log close
log using indian_merger_log, replace 

global sa "K:\BE\1255\Projects\Indian Mergers\work\data\original\Annual Financials"

do import_data 
do sales_validation

