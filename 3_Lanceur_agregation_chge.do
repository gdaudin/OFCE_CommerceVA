************************************
*On agrège les vecteurs de chocs en un scalaire pour les prix d'exports, de conso et de production
*Ligne 49 : source
*Ligne 82 : années
*Ligne 86 : Total ou composantes


*****Lanceur du programme de choc par pays 

clear  
set more off

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 


* else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

capture log  using "$dir/Temporaire/$S_DATE.log", replace
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off
cd "$dir" 

do "$dirgit/Definition_pays_secteur.do"   
do "$dirgit/Aggregation_effets_des_chocs_chge.do"   
do "$dirgit/compute_X.do"
do "$dirgit/compute_HC.do"
do "$dirgit/compute_Y.do"

* A faire tourner la 1ere fois
Definition_pays_secteur TIVA
append_HC TIVA 
append_X TIVA
append_Y TIVA

Definition_pays_secteur WIOD
append_HC WIOD
append_X WIOD
append_Y WIOD


Definition_pays_secteur TIVA_REV4
append_HC TIVA_REV4
append_X TIVA_REV4
append_Y TIVA_REV4



*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM - agregation effet choc
*--------------------------------------------------------------------------------
clear
set more off


*foreach source in   TIVA { 
foreach source in   WIOD /*TIVA TIVA_REV4*/ { 


	Definition_pays_secteur `source'
	if "`source'"=="WIOD" local start_year 2013
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="TIVA_REV4" local start_year 2005


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	if "`source'"=="TIVA_REV4" local end_year 2015

	
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

		if "`source'"=="TIVA_REV4" {
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc  ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
		global ori_choc "$ori_choc  CHN   COL CRI CYP CZE DEU DNK ESP EST FIN"
		global ori_choc "$ori_choc  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KAZ KHM KOR"
		global ori_choc "$ori_choc  LTU LUX LVA MAR MEX MLT    MYS NLD NOR NZL PER PHL POL PRT"
		global ori_choc "$ori_choc  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	}
		
	if "`source'"=="WIOD" {
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc AUS AUT BEL BGR BRA     CAN CHE CHN                             CYP CZE DEU DNK ESP EST FIN " 
		global ori_choc "$ori_choc FRA GBR GRC     HRV HUN IDN IND IRL       ITA JPN     KOR LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
		global ori_choc "$ori_choc ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	}
	
	*  foreach i of numlist 2011 {
	
**Faire historique des principales pondérations
	foreach i of numlist  `end_year' (-1) `start_year'  {
		
		local HC_fait 0
    	foreach j in  HC X Y HC_neig_dom HC_alimentaire_dom HC_energie_dom HC_services_dom HC_dom ///
					HC_neig_impt HC_alimentaire_impt HC_energie_impt HC_services_impt HC_impt */  {	

    	    if strpos("`j'","HC")!=0 & `HC_fait'==0 {
				compute_HC_vect `i' `source'
				local HC_fait 1
			}
			if strpos("`j'","HC")==0 compute_`j'_vect `i' `source' 
			table_mean `i' `j' 1 `source' Sdollar
			table_mean `i' `j' 1 `source' S

	    }

    }
	
	
****Faire toutes les variations pour la dernière année
		
	local HC_fait 0
    foreach j in  HC X Y HC_neig_dom HC_alimentaire_dom HC_energie_dom HC_services_dom HC_dom ///
				HC_neig_impt HC_alimentaire_impt HC_energie_impt HC_services_impt HC_impt   {	
   	    if strpos("`j'","HC")!=0 & `HC_fait'==0 {
			compute_HC_vect `end_year' `source'
			local HC_fait 1
		}
		if strpos("`j'","HC")==0 compute_`j'_vect `end_year' `source' 
		table_mean `end_year' `j' 1 `source' Sdollar
		table_mean `end_year' `j' 1 `source' S
	   }

 
	

	if "`source'"=="TIVA_REV4"	{
		local HC_fait 0
		foreach j in  HC X Y HC_neig_dom HC_alimentaire_dom HC_energie_dom HC_services_dom HC_dom ///
					HC_neig_impt HC_alimentaire_impt HC_energie_impt HC_services_impt HC_impt   {	
			if strpos("`j'","HC")!=0 & `HC_fait'==0 {
				compute_HC_vect 2014 `source'
				local HC_fait 1
			}
			if strpos("`j'","HC")==0 compute_`j'_vect 2014 `source' 
			table_mean 2014 `j' 1 `source' Sdollar
			table_mean 2014 `j' 1 `source' S
		}
	}
		
	
	
	
	
	

}


*secteurs HC : alimentaire neig services energie

*on va le mettre dans weight.

*HC_alimentaire HC_neig HC_services HC_energie

local nbr_sect=wordcount("$sector")	
log close

