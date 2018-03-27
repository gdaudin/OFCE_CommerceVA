* Obtention de la part des CI importées dans la production (Y), dans les exportations (X) et dans la consommation des ménages (HC)
*Distinction, pour la ZE, des inputs importés en provenance des pays ZE et hors ZE

clear
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"



capture log close
log using "$dir/$S_DATE.log", replace
set matsize 7000



capture program drop imp_inputs_par_sect // fournit le % des ci importées/prod par pays*sect
program imp_inputs_par_sect
args yrs source hze

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'

* exemple  hze_not ou hze_yes pour pays membres de la ZE et pays hors ZE

*Ouverture de la base contenant le vecteur ligne de production par pays et secteurs

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop if v1 == "VA+TAXSUB" | v1 == "OUT"
	gen pays=lower(substr(v1,1,3))
	gen secteur = lower(substr(v1,5,.))
	order pays secteur
}


* on conserve uniquement les CI, en éliminants les emplois finals
if "`source'"=="WIOD" {
	 
	drop *57 *58 *59 *60 *61
	rename Country pays
	rename IndustryCode secteur
	order pays secteur
	sort pays secteur
	drop if pays=="TOT"
	* on supprime les lignes total intermediate conso à GO de la base wiod_icio
}


keep pays $var_entree_sortie




foreach var of varlist $var_entree_sortie {
*	On cherche à enlever les auto-consommations intermédiaires
	if "`source'" == "TIVA" local pays_colonne = substr("`var'",1,3)
	if "`source'" == "WIOD" local pays_colonne = substr("`var'",2,3)
	
	replace `var' = 0 if pays=="`pays_colonne'"
	
	
	if strpos(lower("$china"),lower("`pays_colonne'"))!=0  {
			foreach i of global china {	
			replace `var' = 0 if lower(pays) == lower("`i'")
		}
	}
	
	
	if strpos(lower("$mexique"),lower("`pays_colonne'"))!=0 {
			foreach i of global mexique {	
			replace `var' = 0 if lower(pays) == lower("`i'")
		}
	}
		
	if "`hze'"=="hze_yes" & strpos(lower("$eurozone"),lower("`pays_colonne'"))!=0 {
	
		*display "turf"
	
	*Et les internes dans la zone euro
		foreach i of global eurozone {	
			replace `var' = 0 if lower(pays) == lower("`i'")		
		}
	}
	display "`hze' -- `pays_colonne'" 
}


*somme des CI pour chaque secteur de chaque pays
collapse (sum) $var_entree_sortie

display "after collapse"


*obtention de deux lignes, l'une de CI, l'autre de prod pour chaque secteur, issue de la base  `source'_`yrs'_OUT
append using "$dir/Bases/`source'_`yrs'_OUT.dta"

*transpositin en colonne, puis création d'un ratio de CI importées par secteur 
xpose, clear varname
rename v1 ci_impt
rename v2 prod
generate ratio_ci_impt_prod=ci_impt / prod




/*
if "`source'"=="TIVA" {
	generate pays = strlower(substr(_varname,1,3))
	generate sector = strlower(substr(_varname,strpos(_varname,"_")+1,.))
}


*renomme les pays et secteur à partir de la base csv_WIOD
if "`source'"=="WIOD" {
*/


merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
rename c pays
rename s sector
replace sector = lower(sector)
replace pays=lower(pays)
drop p_shock
drop _merge
 
*}
save "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", replace
* enregistrement des ratio de CI importés par secteur

end










**************************************







capture program drop imp_inputs // fournit le total des inputs importés par chaque pays
program imp_inputs
args yrs source vector hze

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'

* exemple vector X Y HC hze_not ou hze_yes

*Création d'un agrégat national pour Chine et Mexique pour ci importées et production 
*La part des CI importées est à présent calculée pour l'ensemble de l'économie, et non plus par secteurs

if "`vector'" == "Y" { 
	use "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", clear

	if "`source'"=="TIVA" {
		gen pays_1 = pays
		replace pays = "chn" if pays_1=="cn1" | pays_1=="cn2" | pays_1=="cn3" | pays_1=="cn4" 
		replace pays = "mex" if pays_1=="mx1" | pays_1=="mx2" | pays_1=="mx3"
		collapse (sum) ci_impt prod, by(pays sector)

	}
	
	collapse (sum) ci_impt prod, by(pays)
	generate ratio_ci_impt_Y = ci_impt/prod
	save "$dir/Bases/imp_inputs_Y_`yrs'_`source'_`hze'.dta", replace
}


*Création d'un agrégat national pour ci importées et production pour Chine et Mexique
*HC présente en revanche déjà une consommation agrégée au niveau de la Chine et du Mexique entiers
if "`vector'" == "HC"  { 

	
	if "`source'"=="TIVA" {
		use  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", replace
		replace pays = "chn" if pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4" 
		replace pays = "mex" if pays=="mx1" | pays=="mx2" | pays=="mx3"
		collapse (sum) ci_impt prod, by(pays sector)
		generate ratio_ci_impt_prod=ci_impt / prod
		save "$dir/Bases/imp_inputs_par_sect_modif.dta", replace
	}
	

	use "$dir/Bases/HC_`source'.dta", clear
	replace pays=lower(pays)
	if "`source'"=="TIVA" {
		replace pays = "chn" if pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4" 
		replace pays = "mex" if pays=="mx1" | pays=="mx2" | pays=="mx3"
		collapse (sum) conso, by(pays pays_conso year sector)
	}
	
	*HC se présente avec le pays d'origine du bien, puis les pays de consommation 
	*Manipulation de la base de données HC en vue d'ordonner la consommation du pays_conso pour tous les secteurs
	keep if lower(pays)==lower(pays_conso) 
	keep if year==`yrs'
	
	if "`source'"=="WIOD" replace pays=lower(pays)
	if "`source'"=="WIOD" replace sector=lower(sector)
	if "`source'"=="WIOD" merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta"
	if "`source'"=="TIVA" merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_modif.dta" 
	if "`source'"=="TIVA" erase  "$dir/Bases/imp_inputs_par_sect_modif.dta"
	drop _merge
		
	gen ci_impt_HC = ratio_ci_impt_prod * conso
	label var ci_impt_HC "Les CI importées dans la consommation de secteurs domestiques"
	
	
	collapse (sum) ci_impt_HC conso, by(pays)
	generate ratio_ci_impt_HC = ci_impt_HC/conso
	label var ratio_ci_impt_HC "Part des CI dans la conso domestique"
	save "$dir/Bases/imp_inputs_HC_`yrs'_`source'_`hze'.dta", replace
}


if "`vector'" == "X"  { 
	
	use "$dir/Bases/X_`source'.dta", clear
 
	keep if year==`yrs'
	
	merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta"
	

	drop _merge
	
	gen ci_impt_X = ratio_ci_impt_prod * X
	
	if "`source'"=="TIVA" {
		replace pays = "chn" if pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4" 
		replace pays = "mex" if pays=="mx1" | pays=="mx2" | pays=="mx3"

	}
	
	collapse (sum) ci_impt_X X, by(pays)
	generate ratio_ci_impt_X = ci_impt_X/X
	save "$dir/Bases/imp_inputs_X_`yrs'_`source'_`hze'.dta", replace
}

end

********************************************************************************************

//graphiques avec 
//   - impact choc euro / part des importations en provenance de pays hors zone euro
//   - impact chocs pays / 



**pOUR TEST

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" WIOD
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" WIOD
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" WIOD
/*
*imp_inputs_par_sect 2000 WIOD hze_not

*imp_inputs 2000 WIOD X hze_not

*imp_inputs_par_sect 2000 WIOD hze_yes

*imp_inputs 2000 WIOD X hze_yes

*imp_inputs 2000 WIOD HC hze_not

*/


*foreach source in WIOD {
foreach source in   WIOD  TIVA {



	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	



*	foreach i of numlist 2010  {
	foreach i of numlist `start_year' (1)`end_year'  {
		
		imp_inputs_par_sect `i' `source' hze_not
		imp_inputs_par_sect `i' `source' hze_yes
		
		clear
	}



}

*/

*foreach source in  WIOD {
foreach source in  WIOD  TIVA {



	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	



*	foreach i of numlist 2000  {
	foreach i of numlist `start_year' (1)`end_year'  {
		
		imp_inputs `i' `source' HC hze_not
		imp_inputs `i' `source' HC hze_yes
		imp_inputs `i' `source' X hze_yes
		imp_inputs `i' `source' X hze_not
		
	
		clear
	}



}

