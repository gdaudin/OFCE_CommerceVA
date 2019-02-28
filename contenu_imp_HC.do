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



if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'


*HC_`source' contient la consommation des ménages (HC) du pays consommateur (pays_conso) 
*en provenance du pays producteur (pays) pour un sector donné pour toutes les années
* lorsque pays=pays_conso, pays_conso consomme un bien produit sur le marché domestique
use "$dir/Bases/HC_`source'.dta", clear

* Si la consommation est d'origine domestique (pays=pays_conso), imp=0 
* avec pays_conso le pays consommateur et pays le pays producteur du bien
			
	
gen imp="euro" if (strpos(lower("$eurozone"),lower(pays))!=0 & strpos(lower("$eurozone"),lower(pays_conso))!=0)

replace imp="no" if upper(pays)==upper(pays_conso) ///
            |  lower(pays_conso)=="chn" & (lower(pays)=="cn1" | lower(pays)=="cn2" | lower(pays)=="cn3" | lower(pays)=="cn4") ///
		    |  lower(pays_conso)=="mex" & (lower(pays)=="mx1" | lower(pays)=="mx2" | lower(pays)=="mx3")

	
	
replace imp="yes" if imp=="" 
	

*conso0= conso domestique, conso1= conso importée
collapse (sum) conso, by(imp year pays_conso)

tab imp
reshape wide conso, i(pays_conso year) j(imp) string

replace consoeuro=0 if consoeuro==.
gen contenu_impHC_0=(consoeuro+consoyes)/(consoeuro+consoyes+consono)
gen contenu_impHC_eur=(consoyes)/(consoeuro+consoyes+consono)

 reshape long contenu_impHC_, i(year pays_conso) j(euro) string

drop if strpos(lower("$eurozone"),lower(pays))==0 & euro=="eur" 
 
replace pays_conso = pays_conso+"_"+euro if euro=="eur"
rename contenu_impHC_ contenu_impHC

keep year pays_conso contenu_impHC

rename pays_conso pays
label var contenu_impHC "Part des consommations directement importées"


if "`source'"=="WIOD" local start_year 2000
if "`source'"=="TIVA" local start_year 1995
if "`source'"=="TIVA_REV4" local start_year 2005

if "`source'"=="WIOD" local end_year 2014
if "`source'"=="TIVA" local end_year 2011
if "`source'"=="TIVA_REV4" local end_year 2015

foreach i of numlist `start_year' (1)`end_year'  {
	preserve
	keep if year==`i'
	save "$dir/Bases/contenu_impHC_`source'_`i'.dta", replace
	export excel using "$dir/Bases/contenu_impHC_`source'_`i'.xls", firstrow(variables) replace
	restore
}


end

*contenu_imp_HC TIVA
*contenu_imp_HC WIOD
contenu_imp_HC TIVA_REV4

