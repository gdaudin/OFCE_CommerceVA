clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
global eastern "BGR CZE HRV HUN POL ROU"
global eastern_ZE "EST LTU LVA SVK SVN"


*--------------------------
*-----------------Pour graphiques HC
*--------------------------


*GRAPHIQUE HC 1 TIVA: comparaison évolution dans le temps 


use "$dir/Results/Devaluations/mean_chg_TIVA_HC_1995.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_1995 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_1995 = (pond_TIVA_HC_1995 - 1)/2

keep c pond_TIVA_HC_1995
save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2005.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_2005 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_2005 = (pond_TIVA_HC_2005 - 1)/2

keep c pond_TIVA_HC_2005

merge 1:1 c using "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1_old.dta"
drop _merge


label var pond_TIVA_HC_1995 "Prix de consommation, 1995 "
label var pond_TIVA_HC_2005 "Prix de consommation, 2005 "

save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.csv", replace


graph bar (asis) pond_TIVA_HC_1995 pond_TIVA_HC_2005 , over(c, sort(pond_TIVA_HC_2005) label(angle(vertical) labsize(tiny))) 

graph export "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/TIVA_HC_Graph_1.png", replace
save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.csv", replace
export excel "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.xlsx", firstrow(variable)replace


*GRAPHIQUE HC 1 WIOD: comparaison évolution dans le temps


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2000.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2000 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2000 = (pond_WIOD_HC_2000 - 1)/2

keep c pond_WIOD_HC_2000
save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2014.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2014 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2014 = (pond_WIOD_HC_2014 - 1)/2

keep c pond_WIOD_HC_2014

merge 1:1 c using "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1_old.dta"
drop _merge


label var pond_WIOD_HC_2000 "Prix de consommation, 2000 "
label var pond_WIOD_HC_2014 "Prix de consommation, 2014 "

save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.csv", replace


graph bar (asis) pond_WIOD_HC_2000 pond_WIOD_HC_2014 , over(c, sort(pond_WIOD_HC_2014) label(angle(vertical) labsize(tiny))) 

graph export "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/WIOD_HC_Graph_1.png", replace
save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.csv", replace
export excel "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.xlsx", firstrow(variable)replace


*--------------------------TABLEAUX

***Tableau 5

foreach year in  2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
	use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	
	
	if `year'==2000 local column B
	if `year'==2001 local column C
	if `year'==2002 local column D
	if `year'==2003 local column E
	if `year'==2004 local column F
	if `year'==2005 local column G
	if `year'==2006 local column H
	if `year'==2007 local column I
	if `year'==2008 local column J
	if `year'==2009 local column K
	if `year'==2010 local column L
	if `year'==2011 local column M
	if `year'==2012 local column N
	if `year'==2013 local column O
	if `year'==2014 local column P
	
	*ajouter un vecteur de nom de pays
	*merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	*drop _merge 
	
	keep c_full_FR shockEUR1
	order c_full_FR
	if `year'!=1995 drop c_full_FR 
	rename shockEUR1 _`year'
	replace _`year' = (_`year' - 1)/2
	
	
	export excel "$dir/Results/Devaluations/WIOD_Tableau_5.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	
	
