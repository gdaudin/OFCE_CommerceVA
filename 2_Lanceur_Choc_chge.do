*****Lanceur du programme de change (attention, c'est long)

*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM
*--------------------------------------------------------------------------------


clear
set more off
*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs à vérifier

*******Définition du directory
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

capture log using "$dir/Temporaire/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

cd $dir 

******Définition des Pays et des secteurs ********************
**On le lance pour mettre à jour les macros (en mémoire)
do GIT/commerce_va_inflation/Definition_pays_secteur.do   


**local nbr_sect=wordcount("$sector")	

do GIT/commerce_va_inflation/choc_chge.do
***** POUR TEST***********
global test = 1 
Definition_pays_secteur TIVA
*compute_leontief 2005 TIVA
compute_B_B2 2005 ARG	TIVA B
compute_B_B2 2005 ARG	TIVA B2
vector_shock_exch 1 ARG TIVA
shock_exch 2005 ARG TIVA
*compute_X 2011 TIVA
*compute_Yt 2011 TIVA
*compute_HC 2011 TIVA
/*
global ori_choc "EUR"

table_mean 2011 X 1 TIVA

blink 
**blink = erreur pour plantage



*foreach source in   WIOD { 
foreach source in   WIOD TIVA { 


	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011

	
	if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source' 
	if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source' 
	if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source' 
	

	// Fabrication des fichiers d'effets moyens des chocs de change
	// pour le choc CPI, faire tourner compute_HC et compute_leontief, les autres ne sont pas indispensables
	*2005 2009 2010 2011




	if "`source'"=="TIVA" {
	*	global ori_choc "CHN"
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL CHN COL CRI CYP CZE DEU DNK ESP EST FIN"
		global ori_choc "$ori_choc FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR LTU LUX LVA MAR MEX MLT MYS NLD NOR NZL PER "
		global ori_choc "$ori_choc PHL POL PRT ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	}

	if "`source'"=="WIOD" {
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc AUS AUT BEL BGR BRA     CAN CHE CHN                             CYP CZE DEU DNK ESP EST FIN " 
		global ori_choc "$ori_choc FRA GBR GRC     HRV HUN IDN IND IRL       ITA JPN     KOR LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
		global ori_choc "$ori_choc ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	}
	
	





*   foreach i of numlist 2011 {
	foreach i of numlist `start_year' (1)`end_year'  {
		clear
		set more off
		compute_leontief `i' `source'
			local pour_gros_fichier 1
			foreach groupeduchoc of global ori_choc {
			compute_B_B2 `i' `groupeduchoc' `source' B
			compute_B_B2 `i' `groupeduchoc' `source' B2
			vector_shock_exch 1 `groupeduchoc' `source'
			shock_exch `i' `groupeduchoc' `source'
			
			use "$dir/Results/Devaluations/`source'_C_`i'_`groupeduchoc'_exch.dta"
			rename C*t1 shock*1
			
			if `pour_gros_fichier'==0 {
				merge 1:1 _n using "$dir/Results/Devaluations/`source'_C_`i'_exch.dta"
				drop _merge
			}
			save "$dir/Results/Devaluations/`source'_C_`i'_exch.dta", replace
			local pour_gros_fichier=0
	    }
	order *, alphabetic
	order shockEUR1 shockEAS1
	merge 1:1 _n using "$dir/Bases/csv_`source'"
	drop _merge
	drop p_shock
	order c s
	save "$dir/Results/Devaluations/`source'_C_`i'_exch.dta", replace	
    }

}





capture log close


