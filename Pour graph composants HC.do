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
args year source

use "$dir/Results/Devaluations/decomp_WIOD_HC_2014.dta", clear

rename *energie* *energy*
rename *alimentaire* *food*



gen part_import = HC_impt / (HC_impt+HC_dom)
label var part_import  "Share of imported final consumption in the impact of a nominal exchange rate shock"
histogram part_import, name(import, replace) kdensity start(0) width(0.05) ///
			frequency note("`source', `year'")
graph export "$dir/commerce_VA_inflation/Rédaction/Share_impt_HC_`source'_`year'.png", replace	



foreach sector in energy neig services food {
	gen part_`sector' = (`sector'_impt+`sector'_dom)/ (HC_impt+HC_dom)
	label var part_`sector'  "`sector' final consumption"
	histogram part_`sector', name(`sector', replace) kdensity start(0) width(0.05) ///
		frequency /*legend(size(small))*/
}

graph combine neig services energy  food, xcommon ycommon ///
	title("Sectoral shares of the impact of a nominal exchange rate shock") note("`source', `year'")
graph export "$dir/commerce_VA_inflation/Rédaction/Share_sector_HC_`source'_`year'.png", replace



local width_`dom' 0.1
local width_`impt' 0.5

foreach origin in dom impt {
	gen int_`origin'=HC_`origin'/(HC_impt+HC_dom)/s_HC_`origin'
	
	histogram int_`origin', name(`origin', replace) kdensity ///
		start(0) width(`width_`origin'') frequency /*legend(size(small))*/
	
	local liste_graph_`origin' `origin'
	
	foreach sector in energy neig food services {
		gen int_`sector'_`origin'=`sector'_`origin'/(HC_impt+HC_dom)/s_`sector'_`origin'
		histogram int_`sector'_`origin', name(`sector'_`origin', replace) kdensity ///
			start(0) width(`width_`origin'') frequency /*legend(size(small))*/
		local liste_graph_`origin' `liste_graph_`origin'' `sector'_`origin'
	}
	macro dir 
	graph combine `liste_graph_`origin'', xcommon ycommon title("Intensity_`origin'") note("`source', `year'")
	graph export "$dir/commerce_VA_inflation/Rédaction/Int_HC_`source'_`year'_`origin'.png", replace

}


end

etude 2014 WIOD
