
clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


capture log close
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

capture program drop composants_HC
program composants_HC
args yrs source


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'



use "$dir/Bases/HC_`source'.dta", clear
rename sector s
rename pays_conso c
keep if year==`yrs'


merge m:1 s c using "$dir/Bases/csv_`source'.dta"
drop _merge

gen origine = "impt" if lower(c)!=lower(pays)
replace origine = "dom" if lower(c)==lower(pays)
collapse (sum) conso, by(agregat_secteur origine c)
egen conso_tot = total(conso), by(c)
sort c
gen share = conso/conso_tot
keep c agregat_secteur origine share




replace agregat_secteur = agregat_secteur + "_" + origine
drop origine
reshape wide share, i(c) j(agregat_secteur) string
rename share* s_*
egen s_HC_impt=rowtotal(s*impt)
egen s_HC_dom=rowtotal(s*dom)
replace c = upper(c)


 
save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta", replace



foreach origine in dom impt {
	foreach sector in energie alimentaire neig services {
	
		local wgt `sector'_`origine'
		use "$dir/Results/Devaluations/mean_chg_`source'_HC_`wgt'_`yrs'.dta", clear
		gen `sector'_`origine'=.
		foreach pays of global country {
			replace `sector'_`origine' = shock`pays'1 if c=="`pays'"
		}
		keep c `sector'_`origine'
		
		merge 1:1 c using   "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta
		drop _merge
		save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta", replace
		
	}
	use "$dir/Results/Devaluations/mean_chg_`source'_HC_`origine'_`yrs'.dta", clear
	gen HC_`origine'=.
	foreach pays of global country {
			replace HC_`origine' = shock`pays'1 if c=="`pays'"
		}
	keep c HC_`origine'
	merge 1:1 c using   "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta
	drop _merge
	save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta", replace
}


**Passage en prix domestiques (et en négatif)

foreach origine in dom impt {
	foreach sector in HC energie alimentaire neig services {
		replace `sector'_`origine' = -(1-`sector'_`origine'/s_`sector'_`origine')/2*s_`sector'_`origine'
	
	}
}


end

*foreach source in  WIOD  {
foreach source in  WIOD  TIVA {



	if "`source'"=="WIOD" global start_year 2000
	if "`source'"=="TIVA" global start_year 1995


	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	


*	foreach i of numlist 2014  {
	foreach i of numlist $start_year (1) $end_year  {
		composants_HC `i' `source'
	}
}



capture log close


