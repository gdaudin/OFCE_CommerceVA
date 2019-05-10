clear  
set more off

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv269a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv269a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 


if ("`c(username)'" == "guillaumedaudin") use "$dir/BME.dta", clear
if ("`c(hostname)'" == "widv269a") use  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear
if ("`c(hostname)'" == "FP1376CD") use  "T:\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear


capture program drop etude_pour_papier
program etude_pour_papier
args year source

use "$dir/Results/Devaluations/decomp_`source'_HC_`year'.dta", clear

rename *energie* *energy*
rename *alimentaire* *food*

foreach var of varlist HC_impt-energy_dom {
	replace `var' =-`var'
}

gen HC_tot=HC_impt+HC_dom
label var HC_dom  "Explained by the price evolution of domestic goods"
label var HC_impt "Explained by the price evolution of imported goods"


keep if c=="FRA_EUR" | c=="DEU_EUR" | c=="USA" | c=="JPN" | c=="CHN" | c=="GBR" | c=="CAN" 
replace c=subinstr(c,"_EUR"e,"",.)
gsort HC_tot
graph bar (asis) HC_dom HC_impt , over(c,sort(HC_tot)) stack ///
		legend(rows(2) size(small)) ///
		note("Source: PIWIM (`source',`year')") ///
		scheme(s1mono) ///
		ylabel(,format(%9.2fc)) ///
		ytitle("elasticity (absolute value)") ///
		note("For DEU and FRA, this is the elasticity to a shock on the Euro")
		
/*		title("Impact d'une appréciation de 5% de l'euro sur les prix à la consommation", span size(medium)) /// */
	
if "`nature_choc'"=="chge"  graph export "$dirgit\Rédaction\decomp_origine_`source'_`year'.png", replace
if "`nature_choc'"=="oil"  graph export "$dir\Results\secteurs_pays\graphiques\decomp_origine_`source'_`year'.png", replace


foreach sector in neig services food energy {
	gen `sector'=`sector'_impt + `sector'_dom
}

label var neig "non-energy industrial goods"

graph bar (asis) services neig energy food , over(c,sort(HC_tot)) stack ///
		legend(rows(2) size(small)) ///
		note("Source: PIWIM (`source',`year')") /// 
		scheme(s1mono) ///
		ylabel(,format(%9.2fc)) ///
		ytitle("elasticity (absolute value)") ///
		note("For DEU and FRA, this is the elasticity to a shock on the Euro")
		
/*		title("Impact d'une appréciation de 5% de l'euro sur les prix à la consommation par secteur", span size(medsmall)) /// */
if "`nature_choc'"=="chge"  graph export "$dirgit\Rédaction\decomp_sect_`source'_`year'.png", replace
if "`nature_choc'"=="oil"  graph export "$dir\Results\secteurs_pays\graphiques\decomp_sect_`source'_`year'.png", replace



gen ss_jacente_impt= services_impt+neig_impt
label var ss_jacente_imp "Imported core inflation"

gen ss_jacente_dom= services_dom+neig_dom
label var ss_jacente_dom "Domestic core inflation"

gen volatile_impt= energy_impt+food_impt
label var volatile_impt "Imported food and energy inflation"

gen volatile_dom= energy_dom+food_dom
label var volatile_dom "Domestic food and energy inflation"

graph bar (asis) ss_jacente_dom ss_jacente_impt  volatile_dom volatile_impt  , over(c,sort(HC_tot)) stack ///
		legend(rows(2) size(vsmall)) ///
		note("Source: PIWIM (`source',`year')") /// 
		scheme(s1mono) ///
		ylabel(,format(%9.2fc)) ///
		ytitle("elasticity (absolute value)") ///
		note("For DEU and FRA, this is the elasticity to a shock on the Euro")
		
		
/*		title("Impact d'une appréciation de 5% de l'euro sur les prix à la consommation par secteur et origine", span size(small)) /// */		
if "`nature_choc'"=="chge"  graph export "$dirgit\Rédaction\decomp_sectxorigin_`source'_`year'.png", replace
if "`nature_choc'"=="oil"  graph export "$dir\Results\secteurs_pays\graphiques\decomp_sectxorigin_`source'_`year'.png", replace




/*

gen part_import = HC_impt / (HC_impt+HC_dom)
label var part_import  "all, imported"
histogram part_import, name(import, replace) kdensity start(0) width(0.05) ///
			frequency note("`source', `year'")
graph export "$dir/commerce_VA_inflation/Rédaction/Share_impt_HC_`source'_`year'.png", replace	



foreach sector in energy neig services food {
	gen part_`sector' = (`sector'_impt+`sector'_dom)/ (HC_impt+HC_dom)
	label var part_`sector'  "`sector'"
	histogram part_`sector', name(`sector', replace) kdensity start(0) width(0.05) ///
		frequency /*legend(size(small))*/
}

graph combine neig services energy  food, xcommon ycommon ///
	/*title("Sectoral shares of the impact of a nominal exchange rate shock")*/ note("`source', `year'")
graph export "$dir/commerce_VA_inflation/Rédaction/Share_sector_HC_`source'_`year'.png", replace



local width_`dom' 0.1
local width_`impt' 0.5

foreach origin in dom impt {
	
	if "`origin'"=="dom" local origine_dev "domestic"
	if "`origin'"=="impt" local origine_dev "imported"
	gen int_`origin'=HC_`origin'/(HC_impt+HC_dom)/s_HC_`origin'
	label var int_`origin' "all, `origine_dev'"
	
	
	histogram int_`origin', name(`origin', replace) kdensity ///
		start(0) width(`width_`origin'') frequency /*legend(size(small))*/
	local liste_graph_`origin' `origin'
	
	
	foreach sector in energy neig food services {
		
		gen int_`sector'_`origin'=`sector'_`origin'/(HC_impt+HC_dom)/s_`sector'_`origin'
		label var int_`sector'_`origin'  "`sector', `origine_dev'"
		histogram int_`sector'_`origin', name(`sector'_`origin', replace) kdensity ///
			start(0) width(`width_`origin'') frequency /*legend(size(small))*/
		local liste_graph_`origin' `liste_graph_`origin'' `sector'_`origin'
	}
	macro dir 
	graph combine `liste_graph_`origin'', xcommon ycommon /*title("Intensity, `origine_dev'")*/ note("`source', `year'")
	graph export "$dir/commerce_VA_inflation/Rédaction/Int_HC_`source'_`year'_`origin'.png", replace

}

*/
end



capture program drop etude_pour_note
program etude_pour_note
args year source nature_choc

if "`nature_choc'"=="chge" use "$dir/Results/Devaluations/decomp_`source'_HC_`year'_agreg_oui.dta", clear
if "`nature_choc'"=="oil" use "$dir/Results/secteurs_pays/decomp_`source'_HC_`year'_agreg_oui.dta", clear



if "`nature_choc'"=="chge" local scale1 -1.5(0.25) 0.0
if "`nature_choc'"=="chge" local scale2 -1.5 0.0
if "`nature_choc'"=="oil"  local scale1  0.0 (0.20) 1.0
if "`nature_choc'"=="oil"  local scale2  0.0 1.0
drop s_*
rename sect_* *
order *, alphabetic
order c HC_impt
rename *energie* *energy*
rename *alimentaire* *food*

foreach var of varlist HC_impt-services_impt {
	if "`nature_choc'"=="chge"	replace `var' =`var'*10
	if "`nature_choc'"=="oil" & `year'==2015  replace  `var'  =`var'*100*10/47.22
}

gen HC_tot=HC_impt+HC_dom
label var HC_dom "Expliqué par l'évolution des prix des biens finaux de consommation domestiques"
label var HC_impt "Expliqué par l'évolution des prix des biens finaux de consommation importés"

if "`nature_choc'"=="chge" {
	keep if c=="FRA_EUR" | c=="DEU_EUR" | c=="ESP_EUR" | c=="ITA_EUR" | c=="NLD_EUR" 
	replace c=subinstr(c,"_EUR","",.)
}

if "`nature_choc'"=="oil" keep if c=="FRA" | c=="DEU" | c=="ESP" | c=="ITA" | c=="NLD" 
gsort HC_tot
graph bar (asis) HC_dom HC_impt , over(c,sort(HC_tot) descending) stack ///
		legend(rows(2) size(small)) ///
		note("Source: PIWIM (`source',`year')") ///
		scheme(s2mono) ///
		ylabel(`scale1',format(%9.2fc)) ///
		yscale(range(`scale2'))  ///
		ytitle("%")
		
/*		title("Impact d'une appréciation de 5% de l'euro sur les prix à la consommation", span size(medium)) /// */
	
if "`nature_choc'"=="chge"  graph export "$dirgit/Rédaction_Note/Decomp_origine_`source'_`year'.png", replace
if "`nature_choc'"=="oil"  graph export "$dir\Results\secteurs_pays\graphiques\decomp_origine_`source'_`year'.png", replace



foreach sector in neig services food energy {
	gen `sector'=`sector'_impt + `sector'_dom
}

rename food alimentaire
rename energy energie


graph bar (asis) services neig energie alimentaire , over(c,sort(HC_tot) descending) stack ///
		legend(rows(2) size(small)) ///
		note("Source: PIWIM (`source',`year')") /// 
		scheme(s2mono) ///
		ylabel(`scale1',format(%9.2fc)) ///
		yscale(range(`scale2'))  ///
		ytitle("%")
		
/*		title("Impact d'une appréciation de 5% de l'euro sur les prix à la consommation par secteur", span size(medsmall)) /// */
if "`nature_choc'"=="chge"  graph export "$dirgit/Rédaction_Note/Decomp_sect_`source'_`year'.png", replace
if "`nature_choc'"=="oil"  graph export "$dir\Results\secteurs_pays\graphiques\decomp_sect_`source'_`year'.png", replace


gen ss_jacente_impt= services_impt+neig_impt
label var ss_jacente_imp "Inflation sous-jacente importée"

gen ss_jacente_dom= services_dom+neig_dom
label var ss_jacente_dom "Inflation sous-jacente domestique"

gen volatile_impt= energy_impt+food_impt
label var volatile_impt "Inflation alimentaire et énergie importée"

gen volatile_dom= energy_dom+food_dom
label var volatile_dom "Inflation alimentaire et énergie domestique"

graph bar (asis) ss_jacente_dom ss_jacente_impt  volatile_dom volatile_impt  , over(c,sort(HC_tot) descending) stack ///
		legend(rows(2) size(vsmall)) ///
		note("Source: PIWIM (`source',`year')") /// 
		scheme(s2mono) ///
		ylabel(`scale1',format(%9.2fc)) ///
		yscale(range(`scale2'))  ///
		ytitle("%")
		
/*		title("Impact d'une appréciation de 5% de l'euro sur les prix à la consommation par secteur et origine", span size(small)) /// */		
if "`nature_choc'"=="chge"  graph export "$dirgit/Rédaction_Note/Decomp_sectxorigin_`source'_`year'.png", replace
if "`nature_choc'"=="oil"  graph export "$dir\Results\secteurs_pays\graphiques\decomp_sectxorigin_`source'_`year'.png", replace

	



end


*etude_pour_papier 2014 WIOD chge
*etude_pour_papier 2015 TIVA_REV4 chge
etude_pour_note 2014 WIOD chge
etude_pour_note 2015  TIVA_REV4 chge
etude_pour_note 2015 TIVA_REV4 oil 
