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
args year

**Exemple : etude 2011 WIOD HC
**Exemple : etude 2011 WIOD par_sect
	
foreach source in TIVA WIOD {

	if "`source'"=="TIVA" local liste_chocs shockEUR1-shockZAF1
	if "`source'"=="WIOD" local liste_chocs shockEUR1-shockUSA1

	use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear




	foreach var of varlist `liste_chocs' {
		local pays = substr("`var'",6,3)
		replace `var' = 0 if strmatch(c,"*`pays'*")==0 ///
		& strpos("$china",c)==0 & strpos("$mexique",c)==0
		replace `var' = 0 if "`var'"!="shockCHN1" & strpos("$china",c)!=0
		replace `var' = 0 if "`var'"!="shockMEX1" & strpos("$mexique",c)!=0
	}

	egen pond_`source'_`type' = rowtotal(`liste_chocs')


	drop shock*

	*** Pour aller chercher les chocs de la ZE

	merge 1:1 c using "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta"
	keep c pond_`source'_`type' shockEUR

	rename shockEUR1 s_EUR
	rename pond_`source'_`type' s_auto



	reshape long s_, i(c) j(source_shock) string



	drop if strpos("$eurozone",c)==0 & source_shock=="EUR" 

	replace c=c+"_EUR" if source_shock=="EUR" 

	drop source_shock

	rename s_ pond_`source'_`type'


	replace pond_`source'_`type' = -(pond_`source'_`type' - 1)/2
	if "`source'"=="WIOD" merge 1:1 c using  "$dir/Results/Devaluations/auto_chocs_HC_`year'.dta"
	save "$dir/Results/Devaluations/auto_chocs_HC_`year'.dta", replace

}

gen year = `year'

insobs 1

replace pond_TIVA_=0 in 84

graph twoway (scatter pond_WIOD_ pond_TIVA_) (lfit pond_WIOD_ pond_TIVA_, clpattern(dash)) (lfit pond_TIVA_ pond_TIVA_), ///
			yscale(range(0 0.4)) xscale(range(0 0.4)) ylabel(0 (0.1) 0.4) ///
			ytitle("WIOD elasticites") xtitle("TIVA elasticites") ///
			legend(order (2 3)  label(2 "linear fit") label(3 "45° line") )
			
			


end

etude 2010
