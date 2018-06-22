clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
global dirgit "X:\Agents\LALLIARD"

*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	
 use "Y:\DiagConj\Commun\CommerceVA\Results\Étude rapport D+I et Bouclage Mondial\Elast_par_pays_2000_WIOD_HC.dta"
 
correlate pond_WIOD_HC E1HC E2HC E3HC, covariance
gen 
