

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


use "$dir/Bases/csv_WIOD.dta", clear
replace c=lower(c)
replace s=lower(s)
generate agregat_secteur="na" 
replace agregat_secteur="alimentaire" if s=="a01" || s=="a03"

*NEIG: bien manuf hors energie
replace agregat_secteur="neig" if s=="a02" || s=="c10-c12"|| s=="c13-c15" ||s=="c16" || s=="c17" ||s=="c18"|| s=="c20"|| s=="c21"|| s=="c22"|| s=="c23"||s=="c24"||s=="c25"||s=="c26"||s=="c27"|| s=="c28"||s=="c29" || s=="c30" || s=="c31_c32"|| s=="c33"||s=="f"

replace agregat_secteur="services" if s=="e36" || s=="e37-39" || s=="h49" || s=="h50" || s=="h51" || s=="h52" || s=="h53" || s=="i"|| s=="j58"|| s=="j59_j60" || s=="j61" || s=="j62_j63" || s=="k64" || s=="k65" || s=="k66" ||  s=="e36" || s=="e37-e39" || s=="l68" || s=="m69_m70"|| s=="m71" || s=="m72" || s=="m73" || s=="m74_m75" || s=="n" || s=="o84" || s=="p85" ||  s=="q" ||  s=="r_s" ||  s=="g45" ||  s=="g46" ||  s=="g47" || s=="t" || s=="u"

replace agregat_secteur="energie" if s=="d35"  || s=="c19" || s=="b"
 save "$dir/Bases/csv_WIOD.dta", replace
