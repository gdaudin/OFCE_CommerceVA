
 

set more off




if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv269a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv269a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 


if ("`c(username)'" == "guillaumedaudin") use "$dir/BME.dta", clear
if ("`c(hostname)'" == "widv269a") use  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear
if ("`c(hostname)'" == "FP1376CD") use  "T:\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear



capture log close
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)


set more off




capture program drop composants_HC
program composants_HC
args yrs source nature_choc agregation
*pour nature_choc, il s'agit du change (chge) ou du pétrole (oil)
*agregation = oui pour 4 secteurs ; non pour avoir l'ensemble des secteurs


do "$dirgit/Definition_pays_secteur.do"   
Definition_pays_secteur `source'


use "$dir/Bases/HC_`source'.dta", clear
rename sector s
rename pays_conso c
keep if year==`yrs'



merge m:1 s c using "$dir/Bases/csv_`source'.dta", keep(1 3)
drop _merge



gen origine = "impt" if lower(c)!=lower(pays)
replace origine = "dom" if lower(c)==lower(pays) | ///
		c=="MEX" & strpos("$mexique",pays)!=0 | ///
		c=="CHN" & strpos("$china",pays)!=0


if "`agregation'" == "oui" { 
	collapse (sum) conso, by(agregat_secteur origine c) 
	rename agregat_secteur s 
}
if "`agregation'" == "non" { 
	collapse (sum) conso, by(s origine c) 
}

egen conso_tot = total(conso), by(c)
sort c
gen share = conso/conso_tot
keep c s origine share

replace s = s + "_" + origine
drop origine
reshape wide share, i(c) j(s) string
rename share* s_*
egen s_HC_impt=rowtotal(s*impt)
egen s_HC_dom=rowtotal(s*dom)
replace c = upper(c)




 

expand 2, gen(duplicate)
drop if strpos("$eurozone",c)==0 & duplicate==1
replace c = c+"_EUR" if strpos("$eurozone",c)!=0 & duplicate==1
drop duplicate

export excel using "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.xls", firstrow(variables) replace
save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace

export excel using "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.xls", firstrow(variables) replace
save "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace




*****Ici, nous avons les parts sectorielles importées / domestiques calculées pour tous les pays. 
***** Dans le fichier_mean_chge, on obtient les contributions par secteur à la hausse du prix
*****Pour le choc euro, la part ne change importée / domestique ne change pas. Les importées sont alors tous les biens venant d'autres pays.

if "`agregation'" == "oui"  local liste_secteurs energie alimentaire neig services
if "`agregation'" == "non"  local liste_secteurs "$sector"

foreach origine in dom impt {
	foreach sector in `liste_secteurs' {
		if "`nature_choc'" == "chge" {
			foreach euro in no_ze ze {				
				local wgt `sector'_`origine'
				use "$dir/Results/Devaluations/mean_chg_`source'_HC_`wgt'_`yrs'_Sdollar.dta", clear

				**Cela cela donne l'effet sur les prix d'un secteur particulir du choc de change
				** on peut donc ensuite le multiplier par l'importance du secteur

				gen sect_`sector'_`origine'=.
				foreach pays of global country_hc {
					if "`euro'"=="no_ze" {
						replace sect_`sector'_`origine' = shock`pays'1 if c=="`pays'"
					}
					if "`euro'"=="ze" & strmatch("$eurozone","*`pays'*")==1 {
						replace sect_`sector'_`origine' = shockEUR1 if c=="`pays'"
						replace c="`pays'_EUR" if c=="`pays'"
					}
				}
				if "`euro'"=="ze" keep if strpos(c,"_EUR")!=0
				keep c sect_`sector'_`origine'
			
				merge 1:1 c using   "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta"
				drop _merge
				save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace
				local folder Devaluations
			}
		}
		if "`nature_choc'" == "oil" {
			local wgt `sector'_`origine'
			use "$dir/Results/secteurs_pays/mean_chg_`source'_HC_`wgt'_`yrs'.dta", clear
			gen sect_`sector'_`origine'=.
			replace sect_`sector'_`origine' = shock1
			keep c sect_`sector'_`origine'
			merge 1:1 c using   "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta"
			drop _merge
			save "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace
			local folder secteurs_pays
		}
	}
	merge 1:1 c using   "$dir/Results/`folder'/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta"
	drop _merge
	save "$dir/Results/`folder'/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace	
}

	
foreach origine in dom impt {
	if "`nature_choc'" == "chge" {
		foreach euro in no_ze ze {		
			use "$dir/Results/Devaluations/mean_chg_`source'_HC_`origine'_`yrs'_Sdollar.dta", clear
			gen sect_HC_`origine'=.
			foreach pays of global country_hc {
				if "`euro'"=="no_ze" {
						replace sect_HC_`origine' = shock`pays'1 if c=="`pays'"
				}
				if "`euro'"=="ze" & strmatch("$eurozone","*`pays'*")==1 {
					replace sect_HC_`origine' = shockEUR1 if c=="`pays'"
					replace c="`pays'_EUR" if c=="`pays'"
				}	
			}
			keep c sect_HC_`origine'
			if "`euro'"=="ze" keep if strpos(c,"_EUR")!=0

			merge 1:1 c using   "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta"
			drop _merge
			save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace
		}
	}
	if "`nature_choc'" == "oil" {
		use "$dir/Results/secteurs_pays/mean_chg_`source'_HC_`origine'_`yrs'.dta"
		gen sect_HC_`origine'=.
			foreach pays of global country_hc {
				replace sect_HC_`origine' = shock1
			}
			keep c sect_HC_`origine'
			merge 1:1 c using   "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta"
			drop _merge
			save "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace
		}

}



**Passage en prix domestique (et en négaitif) uniquement pour le change

if "`nature_choc'" == "chge" {
	foreach origine in dom impt {
		foreach sector in HC `liste_secteurs' {
			replace sect_`sector'_`origine' = -(1-sect_`sector'_`origine'/s_`sector'_`origine')/2*s_`sector'_`origine'
		}		
	}
}

if "`nature_choc'" == "chge" save "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace
if "`nature_choc'" == "oil" save "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.dta", replace
if "`nature_choc'" == "chge" export excel using "$dir/Results/Devaluations/decomp_`source'_HC_`yrs'_agreg_`agregation'.xls", firstrow(variables) replace
if "`nature_choc'" == "oil" export excel using "$dir/Results/secteurs_pays/decomp_`source'_HC_`yrs'_agreg_`agregation'.xls", firstrow(variables) replace

end

foreach source in  WIOD  TIVA_REV4 {

*foreach source in  WIOD  TIVA TIVA_REV4  {

	if "`source'"=="WIOD" global start_year 2014
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2014


	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015


	*foreach i of numlist 2014  {

	foreach i of numlist $start_year (1) $end_year  {
		composants_HC `i' `source' chge oui
		composants_HC `i' `source' oil oui
		*composants_HC `i' `source' oil non
	
	}
}



capture log close
