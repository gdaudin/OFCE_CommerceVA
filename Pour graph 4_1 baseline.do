clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	

	
********Figure 1 (Comparing consumer price elasticity to an exchange rate appreciation for WIOD and TIVA, 2011)	
	
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

graph twoway (scatter pond_WIOD_HC pond_TIVA_HC, mlabel(mylabel)) ///
(lfit pond_WIOD_HC pond_TIVA_HC, clpattern(dash)) ///
			(lfit pond_TIVA_HC pond_TIVA_HC), ///
			yscale(range(0 0.4)) xscale(range(0 0.4)) ylabel(0 (0.1) 0.4) ///
			ytitle("WIOD elasticites `year' (absolute value)") xtitle("TIVA elasticites `year' (absolute value)") ///
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") )
			
graph export "$dir/commerce_VA_inflation/Rédaction/Comparaison_WIOD_TIVA_`year'.png", replace



*************Figure 2 (presenting results)

use "$dir/Results/Devaluations/auto_chocs_HC_WIOD_2014.dta", clear
gen blouf = 0

gen mylabel= c if strpos("FRA DEU DEU_EUR ITA ITA_EUR GBR CHN USA CAN JPN ",c)!=0

twoway histogram pond_WIOD_HC, width(0.05) frequency xscale(range(0.04 0.36)) || ///
	scatter blouf pond_WIOD_HC if mylabel!="", /// 
	mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
	legend(off) ytitle("Number of countries in each bin") xtitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro" ///
	"FRA_EUR is in the same position as JPN") ///
	

graph export "$dir/commerce_VA_inflation/Rédaction/WIOD_HC_elasticities.png", replace


*************Figure 3 (relation with share of imported consumer goods)

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_2014_WIOD_HC.dta", clear

gen mylabel1= c if strpos("FRA ITA ITA_EUR CHN CAN JPN",c)!=0
gen mylabel2= c if c=="FRA_EUR" | c=="USA" | c=="GBR" | c=="DEU_EUR" | c=="DEU"

insobs 1
local N_last_obs=_N
replace pond_WIOD_HC=0 in `N_last_obs'
gen pour_45 = pond_WIOD_HC if pond_WIOD_HC <=0.2

twoway scatter pond_WIOD_HC E1HC  if mylabel1=="" & mylabel2=="" , msize(small) || ///
	   scatter pond_WIOD_HC E1HC  if mylabel1!="", mlabel(mylabel1) mlabangle(vertical) mlabgap(huge) ///
	mlabcolor(green)  mcolor(green) mlabposition(12) mlabsize(small)|| ///
	scatter pond_WIOD_HC E1HC  if mylabel2!="", mlabel(mylabel2) mlabangle(vertical) mlabgap(huge) ///
	mlabposition(6) mlabsize(small) mlabcolor(green)  mcolor(green) || ///
	lfit pond_WIOD_HC E1HC,  ///
	legend(off) xtitle("Share of imported goods and services in household consumption") ///
	ytitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro")
	
graph export "$dir/commerce_VA_inflation/Rédaction/WIOD_HC_E1HC.png", replace
