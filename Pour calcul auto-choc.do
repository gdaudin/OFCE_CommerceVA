clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:/home/T822289/CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:/CommerceVA" 

*capture log close
*log using "$dir/$S_DATE.log", replace


global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"


capture program drop etude
program etude
args year source type

**Exemple : etude 2011 WIOD HC
**Exemple : etude 2011 WIOD par_sect

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="widv270a") do "D:/home/T822289/CommerceVA/GIT/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="FP1376CD") do  "T:/CommerceVA/GIT/commerce_VA_inflation/Definition_pays_secteur.do" `source'	


if "`source'"=="TIVA" |  "`source'"=="TIVA_REV4" local liste_chocs shockEUR1-shockZAF1
if "`source'"=="WIOD" local liste_chocs shockEUR1-shockUSA1

if "`type'"=="HC" | "`type'" =="HC_note" use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'_S.dta", clear
//if "`type'"=="par_sect" use "$dir/Results/Devaluations/`source'_C_`year'_exch.dta", clear



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
if "`type'"=="HC" | "`type'" =="HC_note" {
	merge 1:1 c using "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'_S.dta"
	keep c pond_`source'_`type' shockEUR
}
/*
if "`type'"=="par_sect" {
	merge 1:1 c s using "$dir/Results/Devaluations/`source'_C_`year'_exch.dta"
	keep c s pond_`source'_`type' shockEUR
}
*/
rename shockEUR1 s_EUR
rename pond_`source'_`type' s_auto

*****Cette partie met les chocs EUR dans des lignes séparées

if "`type'"=="HC" | "`type'" =="HC_note" reshape long s_, i(c) j(source_shock) string
if "`type'"=="par_sect"  reshape long s_, i(c s) j(source_shock) string


drop if strpos("$eurozone",c)==0 & source_shock=="EUR" 

replace c=c+"_EUR" if source_shock=="EUR" 

drop source_shock

rename s_ pond_`source'_`type'

*replace pond_`source'_`type' = -(pond_`source'_`type' - 1)/2
sort c
gen year=`year'
rename c pays
save "$dir/Results/Devaluations/auto_chocs_`type'_`source'_`year'.dta", replace

end







					
***********
*foreach source in  WIOD {

foreach source in   TIVA WIOD  TIVA_REV4 {

			

	if "`source'"=="WIOD" global start_year 2000
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2005



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015
	
	
   capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta" 
	foreach type in  HC HC_note /*par_sect*/ {
		capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"

*		foreach i of numlist 2014  {
		foreach i of numlist $start_year (1) $end_year  {
			etude `i' `source' `type'		
		}
	
	clear
	}

}


