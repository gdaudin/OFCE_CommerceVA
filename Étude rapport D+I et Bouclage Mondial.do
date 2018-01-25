clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace

/*
capture program drop graphiques
program graphiques
args source 
*/	
if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	

	
	


*Pour avoir des élasticités comparables aux BMEs + calculs divers
local source WIOD
if "`source'"=="TIVA" local liste_chocs shockEUR1-shockZAF1
if "`source'"=="WIOD" local liste_chocs shockEUR1-shockUSA1

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear

blif

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

merge 1:1 pays using "$dir/Bases/imp_inputs_HC_2011_`source'_hze_not.dta"
*drop if c=="CHN"

label var pond_`source'_HC "Élasticité des prix de consommation en monnaie nationale à un choc de la monnaie nationale"

graph twoway (scatter pond_`source'_HC ratio_ci_impt_HC, mlabel(c_full_FR)) (lfit pond_`source'_HC ratio_ci_impt_HC)  , ///
			title("Elasticité des prix de consommation à une dévaluation") ///
			xtitle("Parts des CI importées dans la conso dom + part conso importée") ytitle("Elasticité prix de conso. ") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3)
			
reg pond_`source'_HC ratio_ci_impt_HC	


list if ratio_ci_impt_HC >= pond_`source'_HC
blif




*************************
**Pour traiter la zone euro
******************************
