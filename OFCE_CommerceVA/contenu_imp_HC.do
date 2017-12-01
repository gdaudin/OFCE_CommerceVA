clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
capture log using "$dir/$S_DATE.log", replace
set more off

capture program drop contenu_imp_HC
program contenu_imp_HC
args source

*conso0= conso domestique, conso1= conso importée

use "$dir/Bases/HC_`source'.dta", clear

if "`source'"=="WIOD" gen imp=0 if pays==upper(pays_conso)
if "`source'"=="TIVA" gen imp=0 if pays==pays_conso
replace imp=1 if imp==. 

collapse (sum) conso, by(imp year pays_conso)
tab imp
reshape wide conso, i(pays_conso year) j(imp)
gen contenu_impHC=conso1/(conso1+conso0)
blif




if "`source'"=="WIOD" local start_year 2000
if "`source'"=="TIVA" local start_year 1995

if "`source'"=="WIOD" local end_year 2014
if "`source'"=="TIVA" local end_year 2011


foreach i of numlist `start_year' (1)`end_year'  {
	preserve
	keep if year==`i'
	save "$dir/Results/Devaluations/contenu_impHC_`source'_`i'.dta", replace
	export excel using "$dir/Results/Devaluations/contenu_impHC_`source'_`i'.xls", firstrow(variables) replace
	restore
}


end

contenu_imp_HC TIVA
*contenu_imp_HC WIOD

