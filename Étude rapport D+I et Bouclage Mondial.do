clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	

	

capture program drop etude
program etude
args year source type

**Exemple : etude 2011 WIOD HC
**Exemple : etude 2011 WIOD par_sect
	


if "`source'"=="TIVA" local liste_chocs shockEUR1-shockZAF1
if "`source'"=="WIOD" local liste_chocs shockEUR1-shockUSA1

if "`type'"=="HC" use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear
if "`type'"=="par_sect" use "$dir/Results/Devaluations/`source'_C_`year'_exch.dta", clear



foreach var of varlist `liste_chocs' {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0 ///
	& strpos("$china",c)==0 & strpos("$mexique",c)==0
	replace `var' = 0 if "`var'"!="shockCHN1" & strpos("$china",c)!=0
	replace `var' = 0 if "`var'"!="shockMEX1" & strpos("$mexique",c)!=0
}



egen pond_`source'_`type' = rowtotal(`liste_chocs')
replace pond_`source'_`type' = -(pond_`source'_`type' - 1)/2

drop shock*

merge m:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge


gen pays=lower(c)
if "`type'"=="par_sect" rename s sector
if "`type'"=="par_sect" replace sector=lower(sector)

if "`type'"=="HC" merge 1:1 pays using "$dir/Bases/imp_inputs_HC_`year'_`source'_hze_not.dta"
if "`type'"=="par_sect" {
	merge 1:1 pays sector using "$dir/Bases/imp_inputs_par_sect_`year'_`source'_hze_not.dta"
	rename ratio_ci_impt_prod ratio_ci_impt_`type'
}
*drop if c=="CHN"
*hze_not : on considère les autres pays de la ZE comme étranger (contraire de hze_yes)

*effet direct repondéré par le choc: le choc correspond à une appréciation de 100% 
*=>on double l'impact pour comparer le ratio de CI importées (comptable) à l'effet direct choqué
gen choc_dplusi_`type'=ratio_ci_impt_`type'/2




label var pond_`source'_`type' "Élasticité des prix (`type') en monnaie nationale à un choc de la monnaie nationale"

graph twoway (scatter pond_`source'_`type' ratio_ci_impt_`type', mlabel(c_full_FR)) (lfit pond_`source'_`type' ratio_ci_impt_`type')  , ///
			title("Elasticité des prix (`type') à une dévaluation") ///
			xtitle("Parts de l'étranger (`type')") ytitle("Elasticité prix (`type'). ") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3) 
*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»			
			
			
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph_`year'_`source'_`type'.pdf", replace
graph close

	

			
reg pond_`source'_`type' choc_dplusi_`type'	
gen R2=e(r2)
matrix COEF = e(b)
gen cst=COEF[1,2]
gen b=COEF[1,1]
gen year=`year'
gen source="`source'"
predict predict
valuesof pays if abs(ln(predict/pond_`source'_`type')) > 0.35
gen predict_hors_0_0_35 = "`r(values)'"
valuesof pays if choc_dplusi_`type'>= pond_`source'_`type'
gen D_I_trop_grand = "`r(values)'"
corr pond_`source'_`type' choc_dplusi_`type'	
gen corr = r(rho)

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'.dta", replace 
keep if _n==1
keep R2-corr
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`type'.dta"
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`type'.dta", replace



end 

*foreach source in  TIVA  {
foreach source in  WIOD  TIVA {



	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	



*	foreach i of numlist 2011  {
	foreach i of numlist `start_year' (1)`end_year'  {
		
		capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_HC.dta"
		etude `i' `source' HC
		capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_par_sect.dta"
		etude `i' `source' par_sect
		
	
		clear
	}



}



*************************
**Pour traiter la zone euro
******************************
