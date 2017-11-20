clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


capture log close
log using "$dir/$S_DATEto.log", replace


global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
global eastern "BGR CZE HRV HUN POL ROU"
global eastern_ZE "EST LTU LVA SVK SVN"


*--------------------------
*-----------------Pour graphiques HC
*--------------------------


*GRAPHIQUE HC 1 : comparaison évolution dans le temps




foreach source in  TIVA WIOD { 

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear

if "`source'"=="TIVA" {
foreach var of varlist shockEUR1- shockZAF1{
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_`source'_HC_2000 = rowtotal(shockEUR1-shockZAF1)
replace pond_`source'_HC_2000 = (pond_`source'_HC_2000 - 1)/2
keep c pond_`source'_HC_2000
save "$dir/Results/Devaluations/Pour_`source'HC_Graph_1_old.dta", replace

}

if "`source'"=="WIOD" {
foreach var of varlist shockEUR1- shockUSA1{
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_`source'_HC_2000 = rowtotal(shockEUR1-shockUSA1)
replace pond_`source'_HC_2000 = (pond_`source'_HC_2000 - 1)/2
keep c pond_`source'_HC_2000
save "$dir/Results/Devaluations/Pour_`source'HC_Graph_1_old.dta", replace
}



use "$dir/Results/Devaluations/mean_chg_`source'_HC_2004.dta", clear

if "`source'"=="TIVA" {
foreach var of varlist shockEUR1-shockZAF1{
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_`source'_HC_2004 = rowtotal(shockEUR1-shockZAF1)
replace pond_`source'_HC_2004 = (pond_`source'_HC_2004 - 1)/2

keep c pond_`source'_HC_2004

merge 1:1 c using "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1_old.dta"
drop _merge
label var pond_`source'_HC_2000 "Prix de consommation, 2000 "
label var pond_`source'_HC_2004 "Prix de consommation, 2004 "

save "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.csv", replace


graph bar (asis) pond_`source'_HC_2000 pond_`source'_HC_2004 , over(c, sort(pond_`source'_HC_2004) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/`source'_HC_Graph_1.png", replace
save "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.csv", replace
export excel "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.xlsx", firstrow(variable)replace}

if "`source'"=="WIOD" {
foreach var of varlist shockEUR1-shockUSA1{
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_`source'_HC_2004 = rowtotal(shockEUR1-shockUSA1)



replace pond_`source'_HC_2004 = (pond_`source'_HC_2004 - 1)/2

keep c pond_`source'_HC_2004

merge 1:1 c using "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1_old.dta"
drop _merge
label var pond_`source'_HC_2000 "Prix de consommation, 2000 "
label var pond_`source'_HC_2004 "Prix de consommation, 2004 "

save "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.csv", replace


graph bar (asis) pond_`source'_HC_2000 pond_`source'_HC_2004 , over(c, sort(pond_`source'_HC_2004) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/`source'_HC_Graph_1.png", replace
save "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.csv", replace
export excel "$dir/Results/Devaluations/Pour_`source'_HC_Graph_1.xlsx", firstrow(variable)replace
}

}


