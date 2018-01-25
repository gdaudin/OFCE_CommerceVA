clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	
capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results.dta"
	

capture program drop etude
program etude
args year source

**Exemple : etude 2011 WIOD
	


if "`source'"=="TIVA" local liste_chocs shockEUR1-shockZAF1
if "`source'"=="WIOD" local liste_chocs shockEUR1-shockUSA1

use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear



foreach var of varlist `liste_chocs' {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_`source'_HC = rowtotal(`liste_chocs')
replace pond_`source'_HC = -(pond_`source'_HC - 1)/2

keep c pond_`source'_HC
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge

gen pays=lower(c)

merge 1:1 pays using "$dir/Bases/imp_inputs_HC_`year'_`source'_hze_not.dta"
*drop if c=="CHN"

label var pond_`source'_HC "Élasticité des prix de consommation en monnaie nationale à un choc de la monnaie nationale"

graph twoway (scatter pond_`source'_HC ratio_ci_impt_HC, mlabel(c_full_FR)) (lfit pond_`source'_HC ratio_ci_impt_HC)  , ///
			title("Elasticité des prix de consommation à une dévaluation") ///
			xtitle("Parts des CI importées dans la conso dom + part conso importée") ytitle("Elasticité prix de conso. ") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3) 
			
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph_`year'_`source'.pdf", replace
graph close

			
reg pond_`source'_HC ratio_ci_impt_HC	
gen R2=e(r2)
matrix COEF = e(b)
gen cst=COEF[1,2]
gen b=COEF[1,1]
gen year=`year'
gen source="`source'"
predict predict
valuesof pays if abs(ln(predict/pond_`source'_HC)) > 0.35
gen predict_hors_0_1 = "`r(values)'"
valuesof pays if ratio_ci_impt_HC >= pond_`source'_HC
gen D_I_trop_grand = "`r(values)'"
corr pond_`source'_HC ratio_ci_impt_HC
gen corr = r(rho)

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'.dta", replace 
keep if _n==1
keep R2-corr
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results.dta"
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results.dta", replace



end 
etude 2011 TIVA
etude 2011 WIOD




*************************
**Pour traiter la zone euro
******************************
