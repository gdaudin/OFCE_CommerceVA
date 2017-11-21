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


*GRAPHIQUE HC 1 TIVA: comparaison évolution dans le temps en devise nationale


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
save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_2011 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_2011 = (pond_TIVA_HC_2011 - 1)/2

keep c pond_TIVA_HC_2011

merge 1:1 c using "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1_old.dta"
drop _merge


label var pond_TIVA_HC_2000 "Prix de consommation, 2000 "
label var pond_TIVA_HC_2011 "Prix de consommation, 2011 "

save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.csv", replace


graph bar (asis) pond_TIVA_HC_2000 pond_TIVA_HC_2011 , over(c, sort(pond_TIVA_HC_2011) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/TIVA_HC_Graph_1.png", replace
save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.csv", replace
export excel "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_1.xlsx", firstrow(variable)replace


*GRAPHIQUE HC 1 WIOD: comparaison évolution dans le temps en devise nationale


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2000.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2000 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2000 = (pond_WIOD_HC_2000 - 1)/2

keep c pond_WIOD_HC_2000
save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2011 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2011 = (pond_WIOD_HC_2011 - 1)/2

keep c pond_WIOD_HC_2011

merge 1:1 c using "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1_old.dta"
drop _merge


label var pond_WIOD_HC_2000 "Prix de consommation, 2000 "
label var pond_WIOD_HC_2011 "Prix de consommation, 2011 "

save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.csv", replace


graph bar (asis) pond_WIOD_HC_2000 pond_WIOD_HC_2011 , over(c, sort(pond_WIOD_HC_2011) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/WIOD_HC_Graph_1.png", replace
save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.dta", replace
export delimited "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.csv", replace
export excel "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_1.xlsx", firstrow(variable)replace


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


local orig USA CHN JPN GBR EAS RUS SAU
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

export excel "$dir/Results/Devaluations/`source'_Tableau_2_`year'.xlsx", firstrow(variables) sheetmodify
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
