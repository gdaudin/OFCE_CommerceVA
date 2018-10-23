

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
svmat C`groupeduchoc't, name(C`groupeduchoc')	



if strpos("`wgt'","HC")!=0  {
	foreach pays_conso of global country_hc {
        svmat HC_`pays_conso', name(HC_`pays_conso')
        generate Bt_`pays_conso' = C`groupeduchoc'* HC_`pays_conso'
        egen tot_HC_`pays_conso' = total(HC_`pays_conso')
        generate sector_shock_`pays_conso' = Bt_`pays_conso'/tot_HC_`pays_conso'
		foreach sector in alimentaire neig energie services {
			if strpos("`wgt'","`sector'")!=0	replace sector_shock_`pays_conso'= 0 if agregat_secteur!="`sector'"
		}
		if strpos("`wgt'","imp")!=0 replace  sector_shock_`pays_conso'= 0 if lower("`pays_conso'")==c
		if strpos("`wgt'","dom")!=0 replace  sector_shock_`pays_conso'= 0 if lower("`pays_conso'")!=c
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
display "fin de compute_mean `yrs' `groupeduchoc' `wgt' `source'"


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


