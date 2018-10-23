************************************
*On agrège les vecteurs de chocs en un scalaire pour les prix d'exports, de conso et de production


*****Lanceur du programme de choc par pays 

clear  
set more off

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

capture log  using "$dir/Temporaire/$S_DATE.log", replace
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off
cd $dir 

do GIT/commerce_va_inflation/Definition_pays_secteur.do   
do GIT/commerce_va_inflation/Aggregation_effets_des_chocs.do   
do GIT/commerce_va_inflation/compute_X.do   
do GIT/commerce_va_inflation/compute_HC.do
do GIT/commerce_va_inflation/compute_Y.do


Definition_pays_secteur TIVA
quietly append_HC TIVA 
append_X TIVA
append_Y TIVA

Definition_pays_secteur WIOD
append_HC WIOD
append_X WIOD
append_Y WIOD


*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM - agregation effet choc
*--------------------------------------------------------------------------------
clear
set more off


*foreach source in   TIVA { 
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
	
	*  foreach i of numlist 2011 {
	foreach i of numlist `start_year' (1)`end_year'  {
		
		local HC_fait 0
    	foreach j in  HC_neig_dom HC_alimentaire_dom HC_energie_dom HC_services_dom HC_dom ///
					HC_neig_impt HC_alimentaire_impt HC_energie_impt HC_services_impt HC_impt /*X Yt*/  {	

    	    if strpos("`j'","HC")!=0 & `HC_fait'==0 {
				compute_HC `i' `source'
				local HC_fait 1
			}
			if strpos("`j'","HC")==0 compute_`j' `i' `source'
			table_mean `i' `j' 1 `source'

	    }

    }

}

*secteurs HC : alimentaire neig services energie

*on va le mettre dans weight.

*HC_alimentaire HC_neig HC_services HC_energie

local nbr_sect=wordcount("$sector")	
log close

