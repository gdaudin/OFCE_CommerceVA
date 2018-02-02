*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs à vérifier

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"




capture log close
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off
global test 1
*Mettre test=1 pour sauver les tableaux un par un et test=0 pour ne pas encombrer le DD.



	
local nbr_sect=wordcount("$sector")	

*----------------------------------------------------------------------------------
*CREATION OF A VECTOR CONTAINING MEAN EFFECTS OF A SHOCK ON EXCHANGE RATE FOR EACH COUNTRY
*----------------------------------------------------------------------------------
*Creation of the vector Y is required before table_adjst : matrix Yt
capture program drop compute_Yt
program compute_Yt
args yrs source
clear

use "$dir/Bases/`source'_`yrs'_OUT.dta"


mkmat $var_entree_sortie, matrix(Y)
matrix Yt = Y'

display "fin compute_Yt"

end

*Creation of the vector of export X : matrix X
* 2017-10-17 redondant avec le programme 1!!!
capture program drop compute_X
program compute_X
	args yrs source
	
use "$dir/Bases/X_`source'.dta", clear
keep if year == `yrs'

*keep year Country X
mkmat X, matrix(X)
display "fin compute_X"

end


*Creation of the vector of value-added VA : matrices Y, X, VA
/*
capture program drop compute_VA
program compute_VA
	args yrs
clear
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear
keep if v1 == "VA.TAXSUB"
drop v1
mkmat $var_entree_sortie, matrix(VA)
matrix VAt = VA'
end
*/
capture program drop compute_HC
program  compute_HC
	args yrs source 
	
	use "$dir/Bases/HC_`source'.dta", clear
	keep if year == `yrs'
	foreach pays_conso of global country_hc {
		preserve
		keep if pays_conso==strlower("`pays_conso'")
		mkmat conso, matrix(HC_`pays_conso')
		restore
	}
	
end
*===============================================================

capture program drop compute_mean    // matrix shock`cty'
program compute_mean
	args yrs groupeduchoc wgt source
clear
*set matsize 7000
set more off
clear


use "$dir/Results/Devaluations/`source'_C_`yrs'_`groupeduchoc'_exch.dta"
mkmat C`groupeduchoc't1, matrix(C`groupeduchoc't)

use "$dir/Bases/csv_`source'.dta", clear

*I decide whether I use the production or export or value-added vector as weight modifying the argument "wgt" : Yt or X or VAt
*Compute the vector of mean effects :




if ("`wgt'" == "Yt")  {
	matrix Yt = Y'
	svmat Yt 
	

}
if ("`wgt'" == "X")  {
	svmat X
}


if ("`wgt'" == "X") | ("`wgt'" == "Yt") {

	svmat C`groupeduchoc't
	generate Bt = C`groupeduchoc't1* `wgt'
	gen pays_interet=c
	replace pays_interet="CHN" if pays_interet=="CN1" | pays_interet=="CN2" | pays_interet=="CN3" | pays_interet=="CN4"
	replace pays_interet="MEX" if pays_interet=="MX1" | pays_interet=="MX2" | pays_interet=="MX3"
	bys pays_interet : egen tot_`wgt' = total(`wgt')
	generate sector_shock = Bt/tot_`wgt'
	bys pays_interet : egen shock`groupeduchoc' = total(sector_shock)
	bys pays_interet : keep if _n==1
	mkmat shock`groupeduchoc'
*   pourquoi pas  mkmat shock`groupeduchoc'_`pays_conso' ???
	
}



local blink 0
matrix C`groupeduchoc't= C`groupeduchoc''
svmat C`groupeduchoc't, name(C`groupeduchoc')	



if ("`wgt'" == "HC")  {
	foreach pays_conso of global country_hc {
        svmat HC_`pays_conso', name(HC_`pays_conso')
        generate Bt_`pays_conso' = C`groupeduchoc'* HC_`pays_conso'
        egen tot_HC_`pays_conso' = total(HC_`pays_conso')
        generate sector_shock_`pays_conso' = Bt_`pays_conso'/tot_`wgt'_`pays_conso'
        egen shock`groupeduchoc'_`pays_conso' = total(sector_shock_`pays_conso')
    *	keep if _n==1
        mkmat shock`groupeduchoc'_`pays_conso'

        if `blink'== 0 matrix shock`groupeduchoc' = shock`groupeduchoc'_`pays_conso'[1,1]
        if `blink'!= 0 matrix shock`groupeduchoc' = shock`groupeduchoc' \ shock`groupeduchoc'_`pays_conso'[1,1]
        matrix drop shock`groupeduchoc'_`pays_conso'
        local blink=`blink'+1	
        drop Bt* tot* sector_shock* HC*  shock*
    }
}



//svmat VAt

set more off
display "fin de compute_mean"


*Vector shock`cty' contains the mean effects of a shock on exchange rate (coming from the country `cty') on overall prices for each country

end


*----------------------------------------------------------------------------------------------------
*CREATION OF THE TABLE CONTAINING THE MEAN EFFECT OF A EXCHANGE RATE SHOCK FROM EACH COUNTRY TO ALL COUNTRIES
*----------------------------------------------------------------------------------------------------
capture program drop table_mean
program table_mean
	args yrs wgt shk source
*yrs = years, wgt = Yt (output) or X (export) or VAt (value-added) or HC (household consumption)
clear
*set matsize 7000
* set trace on
set more off


foreach i of global ori_choc {
	compute_mean `yrs' `i' `wgt' `source'
}


use "$dir/Bases/pays_en_ligne_`source'.dta", clear
drop if c=="MX1" | c=="MX2" |  c=="MX3" |  c=="CN1"  |  c=="CN2"  |  c=="CN3"  |  c=="CN4" 
set more off

foreach i of global ori_choc {
		svmat shock`i'
		
}



* shockARG1 represents the mean effect of a price shock coming from Argentina for each country
save "$dir/Results/Devaluations/mean_chg_`source'_`wgt'_`yrs'.dta", replace
*We obtain a table of mean effect of a price shock from each country to all countries

export excel using "$dir/Results/Devaluations/mean_chg_`source'_`wgt'_`yrs'.xls", firstrow(variables) replace

* set trace off
set more on

end




*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM
*--------------------------------------------------------------------------------




clear
set more off


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

    	foreach j in HC /*X Yt*/  {	

    	    compute_`j' `i' `source'
			table_mean `i' `j' 1 `source'

	    }

    }

}





capture log close


