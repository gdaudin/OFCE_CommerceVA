clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace

program graphiques
args source 
	
if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	



*--------------------------
*-----------------Pour graphiques HC
*--------------------------
*Graphique 1: élasticité des prix de production,  d'exportations et de consommation à une appréciation de la monnaie locale
*TIVA

use "$dir/Results/Devaluations/mean_chg_TIVA_X_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_X = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_X = (pond_TIVA_X - 1)/2

keep c pond_TIVA_X

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC = (pond_TIVA_HC - 1)/2

keep c pond_TIVA_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old.dta"
drop _merge

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old2.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_Y = rowtotal(shockEUR1-shockZAF1)

keep c pond_TIVA_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old2.dta"

drop _merge 

replace pond_TIVA_Y = (pond_TIVA_Y - 1)/2 

label var pond_TIVA_Y "Prix de production"
label var pond_TIVA_X "Prix d'exportation"
label var pond_TIVA_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old3.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old3.csv", replace

graph bar (asis) pond_TIVA_X pond_TIVA_Y  pond_TIVA_HC, over(c, sort(pond_TIVA_HC) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/HC_Graph_1_TIVA_old3.png", replace

drop if strpos("$eurozone",c)==0


graph bar (asis) pond_TIVA_X pond_TIVA_Y pond_TIVA_HC, over(c_full_FR, sort(pond_TIVA_HC) label(angle(vertical) labsize(small)))

graph export "$dir/Results/Devaluations/HC_Graph_1_TIVA.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA.xlsx", firstrow(variable)replace




*Graph 1 WIOD

use "$dir/Results/Devaluations/mean_chg_WIOD_X_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_X = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_X = (pond_WIOD_X - 1)/2

keep c pond_WIOD_X

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC = (pond_WIOD_HC - 1)/2

keep c pond_WIOD_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old.dta"
drop _merge

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old2.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_Y = rowtotal(shockEUR1-shockUSA1)

keep c pond_WIOD_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old2.dta"

drop _merge 

replace pond_WIOD_Y = (pond_WIOD_Y - 1)/2 

label var pond_WIOD_Y "Prix de production"
label var pond_WIOD_X "Prix d'exportation"
label var pond_WIOD_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old3.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old3.csv", replace

graph bar (asis) pond_WIOD_X pond_WIOD_Y  pond_WIOD_HC, over(c, sort(pond_WIOD_HC) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/HC_Graph_1_WIOD_old3.png", replace

drop if strpos("$eurozone",c)==0


graph bar (asis) pond_WIOD_X pond_WIOD_Y pond_WIOD_HC, over(c_full_FR, sort(pond_WIOD_HC) label(angle(vertical) labsize(small)))

graph export "$dir/Results/Devaluations/HC_Graph_1_WIOD.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD.xlsx", firstrow(variable)replace








*GRAPHIQUE HC 2 TIVA: comparaison évolution dans le temps en devise nationale
* Correspond au Graphique 2 du working paper

use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2000.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_2000 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_2000 = (pond_TIVA_HC_2000 - 1)/2

keep c pond_TIVA_HC_2000
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_2011 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_2011 = (pond_TIVA_HC_2011 - 1)/2

keep c pond_TIVA_HC_2011

merge 1:1 c using "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2_old.dta"
drop _merge


label var pond_TIVA_HC_2000 "Prix de consommation, 2000 "
label var pond_TIVA_HC_2011 "Prix de consommation, 2011 "

save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2.dta", replace
export delimited "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2.csv", replace


graph bar (asis) pond_TIVA_HC_2000 pond_TIVA_HC_2011 , over(c, sort(pond_TIVA_HC_2011) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/HC_Graph_2_TIVA.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_2_TIVA.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_2_TIVA.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_2_TIVA.xlsx", firstrow(variable)replace


*GRAPHIQUE HC 2 WIOD: comparaison évolution dans le temps en devise nationale


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2000.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2000 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2000 = (pond_WIOD_HC_2000 - 1)/2

keep c pond_WIOD_HC_2000
save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2011 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2011 = (pond_WIOD_HC_2011 - 1)/2

keep c pond_WIOD_HC_2011

merge 1:1 c using "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2_old.dta"
drop _merge


label var pond_WIOD_HC_2000 "Prix de consommation, 2000 "
label var pond_WIOD_HC_2011 "Prix de consommation, 2011 "

save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2.dta", replace
export delimited "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2.csv", replace


graph bar (asis) pond_WIOD_HC_2000 pond_WIOD_HC_2011 , over(c, sort(pond_WIOD_HC_2011) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2.png", replace

drop if strpos("$eurozone",c)==0

graph export "$dir/Results/Devaluations/HC_Graph_2_WIOD.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_2_WIOD.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_2_WIOD.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_2_WIOD.xlsx", firstrow(variable)replace



**Graphique 3 WP OFCE: élasticité des prix de prod, d'exportations et de consommation en euros à une appréciation de l'euro

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_X_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_X
replace pond_`source'_X = (pond_`source'_X - 1)/2
keep c pond_`source'_X
save "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_Yt_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_Yt
replace pond_`source'_Yt = (pond_`source'_Yt - 1)/2
keep c pond_`source'_Yt 
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'_old.dta"
drop _merge
save "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'_old2.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_HC
replace pond_`source'_HC = (pond_`source'_HC - 1)/2
keep c pond_`source'_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'_old2.dta"
drop _merge
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge

label var pond_`source'_Yt "Prix de production"

label var pond_`source'_X "Prix d'exportation"

label var pond_`source'_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_`source'_X pond_`source'_Yt pond_`source'_HC, over(c_full_FR, sort(pond_`source'_X) label(angle(vertical) )) 
graph export "$dir/Results/Devaluations/HC_Graph_3_`source'.png" , replace
}




**Graphique 4 du working paper : élasticité des prix en monnaie locale
*comparaison des effets prix d'exportations, de production et de consommation: comme dans le WP

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_X_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_X
save "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_Yt_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_Yt
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old.dta"
drop _merge
save "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old2.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old2.dta"
drop _merge

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge

label var pond_`source'_Yt "Prix de production"

label var pond_`source'_X "Prix d'exportation"

label var pond_`source'_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_`source'_X pond_`source'_Yt pond_`source'_HC, over(c_full_FR, sort(pond_`source'_X) descending label(angle(vertical) labsize(vsmall))) 

graph export "$dir/Results/Devaluations/HC_Graph_4_`source'.png", replace

}


*comparaison des effets dans le temps : 4 temp
* des pays hors zone euro à une appréciation dudit euro

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4temp_`source'.png", replace
}

**Graphique 4tempb  : élasticité des prix 
* des pays zone euro à une appréciation de la livre

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockGBR1
keep if strpos("$eurozone",c)!=0
rename shockGBR1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockGBR1
keep if strpos("$eurozone",c)!=0
rename shockGBR1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_`source'_Graph_4tempb.png", replace
}

**Graphique 4bb : élasticité des prix 
* de tous les pays à une appréciation de la livre

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockGBR1
drop if strmatch(c,"GBR")==1
rename shockGBR1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockGBR1
drop if strmatch(c,"GBR")==1
rename shockGBR1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4tempbb_`source'.png", replace
}

**Graphique 4c : élasticité des prix 
* des pays zone euro à une appréciation USD

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockUSA1
keep if strpos("$eurozone",c)!=0
rename shockUSA1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempc_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempc_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockUSA1
keep if strpos("$eurozone",c)!=0
rename shockUSA1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempc_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4tempc_`source'.png", replace
}

**Graphique 4cb : élasticité des prix 
* des pays zone euro à une appréciation USD

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockUSA1
drop if strmatch(c,"USA")==1
rename shockUSA1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_Graph_4tempb_old_`source'.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_old_`source'.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockUSA1
drop if strmatch(c,"USA")==1
rename shockUSA1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_old_`source'.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4tempcb_`source'.png", replace
}

*GRAPHIQUE 7 WP: élasticité des prix de consommation des pays de la ze 
*à un choc sur l'euro et part des importations dans la conso
foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/contenu_impHC_`source'_2011.dta", clear  

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
label var contenu_impHC "Parts des importations en provenance de pays dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph_imp_deval_`source'.dta", replace
	

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockEUR1
keep if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_imp_deval_`source'.dta"
drop _merge
	
graph twoway (scatter pond_HC contenu_impHC, mlabel(c_full_FR)) (qfit pond_HC contenu_impHC)  , ///
			xtitle("Parts des importations dans la consommation") ytitle("Elasticité des prix de consommation en euro") ///
			yscale(range(0.6 0.9)) xscale(range(0.1 0.6)) xlabel (0.1(0.1) 0.6) ylabel(0.6 (0.1) 0.9)
		
graph export "$dir/Results/Devaluations/HC_Graph_7_`source'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_`Graph_7_source'.xlsx", firstrow(variable)replace
}

*GRAPHIQUE 7b WP: élasticité des prix de consommation ZE
*à un choc sur la livre et part des importations dans la conso
foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/contenu_impHC_`source'_2011.dta", clear  

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
label var contenu_impHC "Parts des importations en provenance de pays dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalb_`source'.dta", replace
	

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockGBR1
*drop if strmatch(c,"GBR")==1
keep if strpos("$eurozone",c)!=0
rename shockGBR1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalb_`source'.dta"
drop _merge
	
graph twoway (scatter pond_HC contenu_impHC, mlabel(c_full_FR)) (qfit pond_HC contenu_impHC)  , ///
			xtitle("Parts des importations dans la consommation") ytitle("Elasticité des prix de consommation") ///
			yscale(range(0.0 0.12)) xscale(range(0.0 0.6)) xlabel (0.0(0.1) 0.6) ylabel(0.0 (0.01) 0.12)
		
graph export "$dir/Results/Devaluations/HC_Graph_7b_`source'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_7b_`source'.xlsx", firstrow(variable)replace
}

*GRAPHIQUE 7c WP: élasticité des prix de consommation ZE
*à un choc usd et part des importations dans la conso
foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/contenu_impHC_`source'_2011.dta", clear  

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
label var contenu_impHC "Parts des importations en provenance de pays dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalc_`source'.dta", replace
	

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockUSA1
*drop if strmatch(c,"GBR")==1
keep if strpos("$eurozone",c)!=0
rename shockUSA1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalc_`source'.dta"
drop _merge
	
graph twoway (scatter pond_HC contenu_impHC, mlabel(c_full_FR)) (qfit pond_HC contenu_impHC)  , ///
			xtitle("Parts des importations dans la consommation") ytitle("Elasticité des prix de consommation") ///
			yscale(range(0.0 0.1)) xscale(range(0.0 0.6)) xlabel (0.0(0.1) 0.6) ylabel(0.0 (0.02) 0.1)
		
graph export "$dir/Results/Devaluations/HC_Graph_7c_`source'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_7c8_`source'.xlsx", firstrow(variable)replace
}



*--------------------------TABLEAUX

local i =1 

**Tableau 1 WP: élasticité du CPI à une appréciation de l'euro 2011 en devise nationale

foreach year in 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 {
	use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	
	if `year'==1995 local column A
	if `year'==1996 local column C
	if `year'==1997 local column D
	if `year'==1998 local column E
	if `year'==1999 local column F
	if `year'==2000 local column G
	if `year'==2001 local column H
	if `year'==2002 local column I
	if `year'==2003 local column J
	if `year'==2004 local column K
	if `year'==2005 local column L
	if `year'==2006 local column M
	if `year'==2007 local column N
	if `year'==2008 local column O
	if `year'==2009 local column P
	if `year'==2010 local column Q
	if `year'==2011 local column R
		
	keep c_full_FR shockEUR1
	order c_full_FR
	if `year'!=1995 drop c_full_FR 
	rename shockEUR1 _`year'
	replace _`year' = (_`year' - 1)/2	
	export excel "$dir/Results/Devaluations/TIVA_Tableau_1.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	
foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
	use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	if `year'==2000 local column A
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
	keep c_full_FR shockEUR1
	order c_full_FR
	if `year'!=2000 drop c_full_FR 
	rename shockEUR1 _`year'
	replace _`year' = (_`year' - 1)/2	
	export excel "$dir/Results/Devaluations/WIOD_Tableau_1.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	

	
	***Tableau 3 WP: élasticité à une appréciation d'une monnaie d'un des pays origin

/*
*local orig USA CHN JPN GBR EAS RUS 
foreach source in  WIOD TIVA { 
foreach year in  2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c_full_FR  shockUSA1 shockCHN1 shockJPN1 shockGBR1 shockEAS1 shockRUS1 
order c_full_FR shockGBR1 shockUSA1 shockJPN1 shockEAS1 shockCHN1 shockRUS1  
rename shockGBR1 Royaume_Uni
rename shockUSA1 États_Unis
rename shockJPN1 Japon
rename shockEAS1 Pecos_hors_ZE
rename shockCHN1 Chine
rename shockRUS1 Russie

export excel "$dir/Results/Devaluations/`source'_HC_Tab2_`year'.xlsx", firstrow(variables) sheetmodify
}
}
*/

	***Tableau 3 exhaustif WP: élasticité à une appréciation d'une monnaie d'un des pays origin
*local orig USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR 
foreach source in  WIOD TIVA { 
foreach year in  2000  2011 {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c_full_FR  shockUSA1 shockCHN1 shockJPN1 shockGBR1 shockEAS1 shockRUS1  shockAUS1 shockBRA1 shockCHE1 shockCAN1 shockDNK1 shockIDN1 shockIND1 shockKOR1 shockMEX1 shockNOR1 shockSWE1 shockTUR1
order c_full_FR shockGBR1 shockUSA1 shockJPN1 shockEAS1 shockCHN1 shockRUS1  shockAUS1 shockBRA1 shockCHE1 shockCAN1 shockDNK1 shockIDN1 shockIND1 shockKOR1 shockMEX1 shockNOR1 shockSWE1 shockTUR1
rename shockGBR1 Royaume_Uni
rename shockUSA1 États_Unis
rename shockJPN1 Japon
rename shockEAS1 Pecos_hors_ZE
rename shockCHN1 Chine
rename shockRUS1 Russie
rename shockAUS1 Australie
rename shockBRA1 Brésil
rename shockCHE1 Suisse
rename shockCAN1 Canada
rename shockDNK1 Danemark
rename shockIDN1 Indonésie
rename shockIND1 Inde
rename shockKOR1 Corée
rename shockMEX1 Mexique
rename shockNOR1 Norvège
rename shockSWE1 Suède
rename shockTUR1 Turquie
export excel "$dir/Results/Devaluations/`source'_HC_Tab2long_`year'.xlsx", firstrow(variables) sheetmodify
}
}


***Tableau 3 exhaustif WP: élasticité à une appréciation d'une monnaie d'un des pays origin
* Comparaison de TIVA et WIOD
foreach  orig in  USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR {
foreach year in   2011  {
use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c c_full_FR  shock`orig'1 
rename shock`orig'1 shock`orig'1_TIVA_`year'
save "$dir/Results/Devaluations/Compa_Tabl2long_TIVA_`year'_`orig'_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    
rename shock`orig'1 shock`orig'1_WIOD_`year'
merge 1:1 c using "$dir/Results/Devaluations/Compa_Tabl2long_TIVA_`year'_`orig'_old.dta"
drop _merge	


keep c_full_FR  shock`orig'1*
order c_full_FR shock`orig'1_WIOD* shock`orig'1_TIVA*
export excel "$dir/Results/Devaluations/Compa_Tableau_2long_`year'_`orig'.xlsx", firstrow(variables)   replace
}
}

***Tableau 4 WP: récupère la colonne shockEAS1 pour les pays de la ZE 

foreach year in  2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
	use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	if `year'==2000 local column A
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
	
	* importation des noms de pays entiers 
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	
	keep c_full_FR shockEAS1
	order c_full_FR
	if `year'!=2000 drop c_full_FR
	rename shockEAS1 _`year'
	export excel "$dir/Results/Devaluations/WIOD_Tableau_4.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	
	
foreach year in 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011  {
	use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	if `year'==1995 local column A
	if `year'==1996 local column C
	if `year'==1997 local column D
	if `year'==1998 local column E
	if `year'==1999 local column F
	if `year'==2000 local column G
	if `year'==2001 local column H
	if `year'==2002 local column I
	if `year'==2003 local column J
	if `year'==2004 local column K
	if `year'==2005 local column L
	if `year'==2006 local column M
	if `year'==2007 local column N
	if `year'==2008 local column O
	if `year'==2009 local column P
	if `year'==2010 local column Q
	if `year'==2011 local column R

	
	* importation des noms de pays entiers 
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	
	keep c_full_FR shockEAS1
	order c_full_FR
	if `year'!=1995 drop c_full_FR
	rename shockEAS1 _`year'
	export excel "$dir/Results/Devaluations/TIVA_Tableau_4.xlsx", firstrow(variables) cell(`column'1) sheetmodify
	
}

end
graphiques `source' 

