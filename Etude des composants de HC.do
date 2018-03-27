
clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"




capture log close
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'


capture program drop composants_HC
program composants_HC
args yrs source


local i 0
foreach origine in dom impt {
	foreach sector in energie alimentaire neig services {
	
		local wgt `sector'_`origine'
		use "$dir/Results/Devaluations/mean_chg_`source'_HC_`wgt'_`yrs'.dta", clear
		gen `sector'_`origine'=.
		foreach pays of global country {
			replace `sector'_`origine' = shock`pays'1 if c=="`pays'"
		}
		keep c `sector'_`origine'
		if `i' != 0 {
			merge 1:1 c using   "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta
			drop _merge
		}
		save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'.dta", replace
		if `i'==0 {
			local i 1
		}
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

end

composants_HC 2011 WIOD


capture log close


