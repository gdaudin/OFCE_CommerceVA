clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	

local year 2011
	
use "$dir/Results/Devaluations/auto_chocs_HC_WIOD_`year'.dta", clear
merge 1:1 c using  "$dir/Results/Devaluations/auto_chocs_HC_TIVA_`year'.dta"


gen year = `year'

insobs 1

local N_last_obs=_N

replace pond_TIVA_HC=0 in `N_last_obs'

regress pond_WIOD_HC pond_TIVA_HC
predict predict
gen error=abs(predict-pond_WIOD_HC)/pond_WIOD_HC
gen mylabel= c if /*error >.25 |*/ pond_WIOD_HC>=0.22 | c=="FRA"

graph twoway (scatter pond_WIOD_HC pond_TIVA_HC, mlabel(mylabel)) (lfit pond_WIOD_HC pond_TIVA_HC, clpattern(dash)) ///
			(lfit pond_TIVA_HC pond_TIVA_HC), ///
			yscale(range(0 0.4)) xscale(range(0 0.4)) ylabel(0 (0.1) 0.4) ///
			ytitle("WIOD elasticites `year' (absolute value)") xtitle("TIVA elasticites `year' (absolute value)") ///
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") )
			
graph export "$dir/commerce_VA_inflation/Rédaction/Comparaison_WIOD_TIVA_`year'.png", replace		




