clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


use "$dir/Bases/csv_TIVA.dta", clear
generate agregat_secteur="na" 
replace agregat_secteur="alimentaire" if s=="C15T16" || s=="C01T05" 
replace agregat_secteur="neig" if s=="C17T19" || s=="C20" || s=="C21T22" || s=="C24" || s=="C25"  || s=="C26" || s=="C27"  || s=="C28" || s=="C29" || s=="C30T33X" || s=="C31" || s=="C34" || s=="C35" || s=="C36T37" || s=="C45"  
replace agregat_secteur="energie" if s=="C10T14" || s=="C40T41" || s=="C23" 
replace agregat_secteur="services" if s=="C55" || s=="C50T52" || s=="C60T63" || s=="C64" ||s=="C65T67" ||s=="C70" ||s=="C71" ||s=="C72" ||s=="C73T74" ||s=="C75" ||s=="C80" ||s=="C85" ||s=="C90T93" ||s=="C95" 

replace s = lower(s)
replace s = lower(s)
save "$dir/Bases/csv_TIVA.dta", replace
