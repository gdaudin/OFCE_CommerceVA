
*****HC, GD, 10/2018----------------------------------------
*****Lanceur du programme de pétrole (attention, c'est très long)
*****Ce lanceur lance pour chaque base, chaque année  un choc pour le ou les secteurs choisi et pour le ou les pays choisis
*****Attention, lors de chaque mise à jour des données, il faut changer les dates de début/fin dans 1_constr_bases.do (l 20, 53 , 230-235, 327-331)
*****Pour changer la taille du choc, changer la ligne 98 (ici choc de +100%)
*****IMPORTANT : le programme 2_choc_change doit avoir tourné car on ne fait pas retourner la matrice de Leontieff
*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM
*--------------------------------------------------------------------------------


clear
set more off
*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs 
global test = 1
*******Définition du directory

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv269a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv269a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 


capture log using "$dir/Temporaire/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

cd $dir  

******Définition des Pays et des secteurs ********************
**On le lance pour mettre à jour les macros (en mémoire)
do "$dirgit/Definition_pays_secteur.do"   


**local nbr_sect=wordcount("$sector")	
do "$dirgit/choc_secteurs_pays.do"

*foreach source in   WIOD { 
foreach source in   /* WIOD TIVA */ TIVA_REV4 { 


	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="TIVA_REV4" local start_year 2005


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	if "`source'"=="TIVA_REV4" local end_year 2015

	
	Definition_pays_secteur `source'

*   foreach i of numlist 2011 {
	foreach i of numlist `start_year' (1)`end_year'  {
		clear
		set more off
		
		vector_shock_secteurs_pays 1 `source' 
		shock_secteurs_pays `i' `source'
		use "$dir/Results/Secteurs_pays/`source'_`i'_secteurs_pays.dta"
		rename S*t1 shock*1

		merge 1:1 _n using "$dir/Bases/csv_`source'"
		drop _merge
		drop p_shock
		order c s
		save "$dir/Results/Secteurs_pays/`source'_`i'_secteurs_pays", replace	
    }

}





capture log close


