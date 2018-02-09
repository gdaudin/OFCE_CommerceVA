

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


use "$dir/Bases/csv_WIOD.dta", clear
generate agregat_secteur
replace agregat_secteur="alimentaire" if s=="a01" || s=="a02" ||  s=="a03"
replace agregat_secteur="manuf" if s=="c01" || 

save "$dir/Bases/csv_WIOD.dta", replace
