clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

*capture log close
*log using "$dir/$S_DATE.log", replace



if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'


*set scheme economist


************************************************************
*GRAPHIQUE RESULTATS DES REGRESSIONS  pond_hc=b*ratio_ci_impt_HC+constante
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results.dta", clear

************graphiques pour WIOD
drop if source=="TIVA"
*set scheme economist
graph bar (asis) R2 ,  title("R2, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_R2_Wiod.png", replace

*coefficient de correlation entre le vecteur Elasticité des prix de consommation à une dévaluation et le vecteur Parts des CI importées dans la conso dom + part conso importée de tous les pays pour une année donnée
graph bar (asis) corr ,  title("Coefficient de corrélation, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_corr_Wiod.png", replace


*coeff beta de la régression pond_wiod_hc=b*ratio_ci_impt_HC+constante
graph bar (asis) b ,  title("Coefficient de correlation de la régression, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_Wiod.png", replace

*constante de la régression
graph bar (asis) cst ,  title("Constante de la régression, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_Wiod.png", replace

*************graphiques pour TIVA
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results.dta", clear
drop if source=="WIOD"

graph bar (asis)  R2,  title("R2, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_R2_tiva.png", replace

graph bar (asis) corr ,  title("Coefficient de correlation, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_corr_tiva.png", replace

graph bar (asis) b ,  title("Coefficient de correlation de la régression, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_tiva.png", replace

graph bar (asis) cst ,  title("Constante de la régression, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_Tiva.png", replace


************************************************************
*ratio CI importées + biens de conso importés sur HH consumption

foreach source in  WIOD TIVA{
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2000_`source'.dta", clear
keep c  ratio_ci_impt_HC
rename ratio_ci_impt_HC ratio_ci_impt_HC_2000
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_`source'.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2011_`source'.dta", clear
rename ratio_ci_impt_HC ratio_ci_impt_HC_2011
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_`source'.dta"
drop _merge 

label var ratio_ci_impt_HC_2000 "2000"

label var ratio_ci_impt_HC_2011 "2011"

graph bar (asis) ratio_ci_impt_HC_2000 ratio_ci_impt_HC_2011, over(c, sort(ratio_ci_impt_HC_2000)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_`source'.png", replace
}


*WIOD 2014
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD.dta", clear
graph bar (asis) ratio_ci_impt_HC,  over(c, sort(ratio_ci_impt_HC)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_wiod_2014.png", replace
*title("Imported intermediate inputs and consumer goods to consumption")


*Evolution temporelle du ratio CI importées + biens de conso importés sur HH consumption en ze
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2000_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)!=0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2000
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2000_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2005_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)!=0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2005
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2005_2014.dta", replace


use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2007_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)!=0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2007
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2007_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2008_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)!=0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2008
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2008_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2009_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)!=0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2009
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2009_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2012_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)!=0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2012
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2012_2014.dta", replace


use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD.dta", clear
rename ratio_ci_impt_HC ratio_ci_impt_HC_2014
keep if strpos("$eurozone",c)!=0
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2000_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2005_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2007_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2008_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2009_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2012_2014.dta"
drop _merge 

label var ratio_ci_impt_HC_2000 "2000"
label var ratio_ci_impt_HC_2005 "2005"
label var ratio_ci_impt_HC_2007 "2007"
label var ratio_ci_impt_HC_2008 "2008"
label var ratio_ci_impt_HC_2009 "2009"
label var ratio_ci_impt_HC_2012 "2012"
label var ratio_ci_impt_HC_2014 "2014"

graph bar (asis) ratio_ci_impt_HC_2000 ratio_ci_impt_HC_2007 ratio_ci_impt_HC_2014, over(c, sort(year)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_WIOD_2000_2014_ze.png", replace



*Evolution temporelle du ratio CI importées + biens de conso importés sur HH consumption hors ze
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2000_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)==0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2000
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2000_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2005_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)==0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2005
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2005_2014.dta", replace


use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2007_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)==0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2007
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2007_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2008_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)==0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2008
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2008_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2009_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)==0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2009
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2009_2014.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2012_WIOD.dta", clear
keep c  ratio_ci_impt_HC year
keep if strpos("$eurozone",c)==0
rename ratio_ci_impt_HC ratio_ci_impt_HC_2012
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2012_2014.dta", replace


use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD.dta", clear
rename ratio_ci_impt_HC ratio_ci_impt_HC_2014
keep if strpos("$eurozone",c)==0
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2000_2014.dta"
drop _merge  
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2005_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2007_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2008_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2009_2014.dta"
drop _merge 
merge 1:1 c using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_2012_2014.dta"
drop _merge 
drop if c=="ROW"

label var ratio_ci_impt_HC_2000 "2000"
label var ratio_ci_impt_HC_2005 "2005"
label var ratio_ci_impt_HC_2007 "2007"
label var ratio_ci_impt_HC_2008 "2008"
label var ratio_ci_impt_HC_2009 "2009"
label var ratio_ci_impt_HC_2012 "2012"
label var ratio_ci_impt_HC_2014 "2014"

graph bar (asis) ratio_ci_impt_HC_2000 ratio_ci_impt_HC_2007 ratio_ci_impt_HC_2014, over(c, sort(year)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_WIOD_2000_2014.png", replace


***********************Comparaison de l'effet expliqué par ratio_ci_impt_HC sur le total

*calcul du ratio direct/total, on sait que ce ratio est exceptionnellement >1 en Irlande en 2011 avec TiVA
/*
foreach source in   WIOD  TIVA {
	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011

	foreach i of numlist `start_year' (1)`end_year'  {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`i'_`source'.dta", clear	
 gen ratio_direct_total=ratio_ci_impt_HC/pond_`source'_HC
 save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`i'_`source'.dta", replace		
	}
}
*/
