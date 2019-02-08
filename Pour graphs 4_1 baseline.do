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
drop if c=="ROW"

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
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") ) scheme(s1color)
			
graph export "$dir/commerce_VA_inflation/Rédaction/Comparaison_WIOD_TIVA_`year'.png", replace



*************Figure 2 (presenting results)

use "$dir/Bases/Y_WIOD.dta", clear
collapse (sum) Y, by(pays year)
rename pays c
keep if year==2014


merge 1:1 c using "$dir/Results/Devaluations/auto_chocs_HC_WIOD_2014.dta"
gen blouf = 0

gen mylabel= c if strpos("FRA DEU DEU_EUR ITA ITA_EUR GBR CHN USA CAN JPN ",c)!=0

twoway histogram pond_WIOD_HC, width(0.05) frequency xscale(range(0.04 0.36)) || ///
	scatter blouf pond_WIOD_HC if mylabel!="", /// 
	mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
	legend(off) ytitle("Number of countries in each bin") xtitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro" ///
	"FRA_EUR is in the same position as JPN") ///
	 scheme(s1color)
	



graph export "$dir/commerce_VA_inflation/Rédaction/WIOD_HC_elasticities.png", replace

replace Y=round(Y,.)

twoway histogram pond_WIOD_HC [fweight=Y],  width(0.05) fraction xscale(range(0.04 0.36)) || ///
	scatter blouf pond_WIOD_HC if mylabel!="", /// 
	mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
	legend(off) ytitle("Share of world output in each bin") xtitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro" ///
	"FRA_EUR is in the same position as JPN") ///
	 scheme(s1color)
	



*************Figure 3 (relation with share of imported consumer goods)


use "$dir/Bases/Y_WIOD.dta", clear
collapse (sum) Y, by(pays year)
rename pays c
keep if year==2014


merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_2014_WIOD_HC.dta"

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
	"*_EUR designate the effet of an shock on the Euro") ///
	 scheme(s1color)
	
graph export "$dir/commerce_VA_inflation/Rédaction/WIOD_HC_E1HC.png", replace

/*

twoway scatter pond_WIOD_HC E1HC  if mylabel1=="" & mylabel2=="" [w=Y], msize(small) msymbol(circle_hollow) || ///
	   scatter pond_WIOD_HC E1HC  if mylabel1!="" [w=Y], mlabel(mylabel1) mlabangle(vertical) mlabgap(huge)  ///
	msymbol(circle_hollow) mlabcolor(green)  mcolor(green) mlabposition(12) mlabsize(small)|| ///
	scatter pond_WIOD_HC E1HC  if mylabel2!="" [w=Y], mlabel(mylabel2) mlabangle(vertical) mlabgap(huge) ///
	msymbol(circle_hollow) mlabposition(6) mlabsize(small) mlabcolor(green)  mcolor(green) || ///
	lfit pond_WIOD_HC E1HC,  ///
	legend(off) xtitle("Share of imported goods and services in household consumption") ///
	ytitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro")
	
	
twoway scatter pond_WIOD_HC E1HC   [w=Y], msize(small) msymbol(circle_hollow)
*/

*************Figure 4 (évolutions dans le temps)

	
global common_sample "   AUS AUT BEL BGR BRA CAN CHE" 
global common_sample "$common_sample CHN CYP CZE DEU DNK ESP EST FIN"
global common_sample "$common_sample FRA GBR GRC     HRV HUN IDN IND IRL        ITA JPN     KOR"
global common_sample "$common_sample LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
global common_sample "$common_sample ROU RUS       SVK SVN SWE       TUR TWN USA        "

foreach source in TIVA WIOD  {

	if "`source'"=="WIOD" global start_year 2000
	if "`source'"=="TIVA" global start_year 1995


	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011

	use "$dir/Bases/Y_`source'.dta", clear
	rename Y Y_`source'
	replace pays="CHN" if pays=="CN1" | pays=="CN2" | pays=="CN3" | pays=="CN4"
	replace pays="MEX" if pays=="MX1" | pays=="MX2" | pays=="MX3"
	keep if strpos("$common_sample",pays)!=0


	collapse (sum) Y_`source', by(pays year)
	rename pays c

	foreach year of numlist $start_year (1) $end_year  {
		merge 1:1 year c  using "$dir/Results/Devaluations/auto_chocs_HC_`source'_`year'.dta", update
		drop _merge
	}


	egen Y_tot_per_year=total(Y_`source'), by(year)
	gen weight=Y_`source'/Y_tot_per_year
	gen elast_pond=pond_`source'_HC*weight
	

	egen `source'_elast_annual_pond=total(elast_pond), by(year)
	egen `source'_elast_annual=mean(pond_`source'_HC), by(year)
	
	drop Y_tot_per_year weight elast_pond
	
	
	save temp_`source'.dta, replace
}

use temp_WIOD.dta, clear
merge 1:1 year c using temp_TIVA.dta
sort year

bys year: keep if _n==1
drop c



twoway 	(line WIOD_elast_annual year, lcolor(blue) lpattern(dash)) ///
		(line WIOD_elast_annual_pond year, lcolor(blue)) ///
		(line TIVA_elast_annual year, lcolor(red) lpattern(dash)) ///
		(line TIVA_elast_annual_pond year, lcolor(red)), ///
		legend(label(1 "WIOD") label(2 "WIOD, output weighted") ///
		label(3 "TIVA") label(4 "TIVA, output weighted"))  /// 
		ytitle("elasticity (absolute value)", ) ///
		note("Computed on a common sample of 43 countries assuming no Eurozone")
		

graph export "$dir/commerce_VA_inflation/Rédaction/PIWIM_LONGITUDINAL.png", replace
	

		
erase temp_TIVA.dta
erase temp_WIOD.dta
