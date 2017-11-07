clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
capture log using "$dir/$S_DATE.log", replace
set more off
***************************************************************************************************
*Création des tables  de consommation finale des ménages (HFCE) : on crée le vecteur 1*67 des hfce de chaque pays

***************************************************************************************************
*Creation of the vector of households final consumption H
capture program drop compute_HC
program compute_HC
	args source yrs

use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear


if "`source'"=="TIVA" {
*v1: pays_secteur

	use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear
	keep v1 hfce*
	drop if v1=="OUT" | v1=="VA+TAXSUB"
	reshape long hfce_, i(v1) j(pays_conso) string

	generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
	generate sector = strlower(substr(v1,strpos(v1,"_")+1,.))
	rename hfce_ conso
	generate year = `yrs'

}


if "`source'"=="WIOD" {
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear


keep IndustryCode Country Year v*59
reshape long v, i(Country IndustryCode Year) j(pays_conso) string
rename  Country pays
rename  IndustryCode sector 
replace sector = strlower(sector)
replace pays_conso=strlower(substr(pays_conso,1,3))
 
drop if pays=="TOT"

rename v conso		
rename Year year	
sort year pays sector pays_conso
replace pays = strupper(pays)
}
*keep year pays HC
*collapse (sum) HC, by(pays year)
end

capture program drop append_HC
program append_HC
args source
*We create a .dta that includes all vectors of HFCE of all years
if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="WIOD" local first_yr 2000
foreach y of numlist `yr_list' { 
	compute_HC `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/HC_`source'.dta" 
	}
	save "$dir/Bases/HC_`source'.dta", replace
}	
sort year , stable
save "$dir/Bases/HC_`source'.dta", replace
 
end
append_HC TIVA
append_HC WIOD


