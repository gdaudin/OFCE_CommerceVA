* Obtention de la part des CI importées dans la production (Y), dans les exportations (X) et dans la consommation des ménages (HC)
*Distinction, pour la ZE, des inputs importés en provenance des pays ZE et hors ZE

clear
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/"
if ("`c(username)'"=="w817186") global dirgit "X:\Agents\FAUBERT\commerce_VA_inflation\"
if ("`c(username)'"=="n818881") global dirgit "X:\Agents\LALLIARD\commerce_VA_inflation\"



capture log close
log using "$dir/$S_DATE.log", replace
set matsize 7000



capture program drop imp_inputs_par_sect // fournit le % des ci importées/prod par pays*sect
program imp_inputs_par_sect
args yrs source hze


* exemple  hze_not ou hze_yes pour pays membres de la ZE et pays hors ZE

*Ouverture de la base contenant le vecteur ligne de production par pays et secteurs

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop if v1 == "VA.TAXSUB" | v1 == "OUT"
	generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
}

* on conserve uniquement les CI, en éliminants les emplois finals
if "`source'"=="WIOD" {
	 
	drop *57 *58 *59 *60 *61
	rename Country pays
	 
}

keep pays $var_entree_sortie




foreach var of varlist $var_entree_sortie {
*	On cherche à enlever les auto-consommations intermédiaires
	if "`source'" == "TIVA" local pays_colonne = substr("`var'",1,3)
	if "`source'" == "WIOD" local pays_colonne = substr("`var'",2,3)
	replace `var' = 0 if pays=="`pays_colonne'"
	local pays_colonne = upper("`pays_colonne'")
	
	if "`hze'"=="hze_yes" & strpos("$eurozone","`pays_colonne'")!=0 {
		*display "turf"
	
	*Et les internes dans la zone euro
		foreach i of global eurozone {	
			replace `var' = 0 if pays == lower("`i'")
		}
	}
}



collapse (sum) $var_entree_sortie
display "after collapse"

*obtention de deux lignes, l'une de CI, l'autre de prod pour chaque secteur
append using "$dir/Bases/`source'_`yrs'_OUT.dta"

*transpositin en colonne, puis création d'un ratio de CI importées par secteurs 
xpose, clear varname
rename v1 ci_impt
rename v2 prod
generate ratio_ci_impt_prod=ci_impt / prod

if "`source'"=="TIVA" {
	generate pays = strlower(substr(_varname,1,3))
	generate sector = strlower(substr(_varname,strpos(_varname,"_")+1,.))
}


if "`source'"=="WIOD" {
	merge 1:1 _n using "$dir/Bases/csv_WIOD.dta"
	rename c pays
	rename s sector
	replace pays=lower(pays)
	drop p_shock
	drop _merge
 
}
save "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", replace
* enregistrement des ratio de CI importés par secteur

end










**************************************







capture program drop imp_inputs // fournit le total des inputs importés par chaque pays
program imp_inputs
args yrs source vector hze

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
		gen pays_1 = pays
		replace pays = "chn" if pays_1=="cn1" | pays_1=="cn2" | pays_1=="cn3" | pays_1=="cn4" 
		replace pays = "mex" if pays_1=="mx1" | pays_1=="mx2" | pays_1=="mx3"
		collapse (sum) ci_impt prod, by(pays sector)
		generate ratio_ci_impt_prod=ci_impt / prod
		save "$dir/Bases/imp_inputs_par_sect_modif.dta", replace
	}
	

	use "$dir/Bases/HC_`source'.dta", clear
	if "`source'"=="TIVA" {
		replace pays = "chn" if pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4" 
		replace pays = "mex" if pays=="mx1" | pays=="mx2" | pays=="mx3"
		collapse (sum) conso, by(pays pays_conso year sector)
	}
	*HC se présente avec le pays d'origine du bien, puis les pays de consommation 
	*Manipulation de la base de données HC en vue d'ordonner la consommation du pays_conso pour tous les secteurs
	keep if lower(pays)==lower(pays_conso) 
	keep if year==`yrs'
	
	if "`source'"=="WIOD" merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta"
	if "`source'"=="TIVA" merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_modif.dta"
	if "`source'"=="TIVA" erase  "$dir/Bases/imp_inputs_par_sect_modif.dta"
	drop _merge
	
	gen ci_impt_HC = ratio_ci_impt_prod * conso
	
	collapse (sum) ci_impt_HC conso, by(pays)
	generate ratio_ci_impt_HC = ci_impt_HC/conso
	save "$dir/Bases/imp_inputs_HC_`yrs'_`source'_`hze'.dta", replace
}

if "`vector'" == "X"  { 
	
	use "$dir/Bases/X_`source'.dta", clear
 
	keep if year==`yrs'
	
	merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta"
	
	blif
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

do "Definition_pays_secteur" `source' WIOD
imp_inputs_par_sect 2011 WIOD hze_not

imp_inputs 2011 WIOD X hze_not



blif


foreach source in TIVA WIOD {

Definition_pays_secteur `source'

	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	




	foreach i of numlist `start_year' (1)`end_year'  {
		//clear
		imp_inputs `i' `source' HC hze_not
		imp_inputs `i' `source' HC hze_yes
		imp_inputs `i' `source' X hze_yes
		
	
		clear
	}



}

