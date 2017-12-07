*Calcul du contenu en importations de la consommation des ménages (HC)

clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
capture log using "$dir/$S_DATE.log", replace
set more off

capture program drop contenu_imp_HC
program contenu_imp_HC
args source


*HC_`source' contient la consommation des ménages (HC) du pays consommateur (pays_conso) 
*en provenance du pays producteur (pays) pour un sector donné pour toutes les années
* lorsque pays=pays_conso, pays_conso consomme un bien produit sur le marché domestique
use "$dir/Bases/HC_`source'.dta", clear

* Si la consommation est d'origine domestique (pays=pays_conso), imp=0 
* avec pays_conso le pays consommateur et pays le pays producteur du bien
gen imp=0 if pays==upper(pays_conso)|  pays==pays_conso ///
            |  pays_conso=="chn" & (pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4") ///
		    |  pays_conso=="mex" & (pays=="mx1" | pays=="mx2" | pays=="mx3")
			
	
replace imp=1 if imp==. 
	

*replace imp=1 if upper(pays)==upper(pays_conso)	
*replace imp=0 if imp==. 

*conso0= conso domestique, conso1= conso importée
collapse (sum) conso, by(imp year pays_conso)

tab imp
reshape wide conso, i(pays_conso year) j(imp)
gen contenu_impHC=conso1/(conso1+conso0)





if "`source'"=="WIOD" local start_year 2000
if "`source'"=="TIVA" local start_year 1995

if "`source'"=="WIOD" local end_year 2014
if "`source'"=="TIVA" local end_year 2011


foreach i of numlist `start_year' (1)`end_year'  {
	preserve
	keep if year==`i'
	save "$dir/Results/Devaluations/contenu_impHC_`source'_`i'.dta", replace
	export excel using "$dir/Results/Devaluations/contenu_impHC_`source'_`i'.xls", firstrow(variables) replace
	restore
}


end

*contenu_imp_HC TIVA
contenu_imp_HC WIOD

