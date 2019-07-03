
 

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


foreach year of numlist 2005(1)2015 {

	use "$dir/Results/Secteurs_pays/mean_chg_TIVA_REV4_HC_`year'.dta", clear

	drop p_shock
	gen year=`year'
	rename shock1 shockmulti
	if `year'!=2005 append using "$dir/Results/Secteurs_pays/mean_chg_TIVA_REV4_HC_2005-2015.dta"

	save "$dir/Results/Secteurs_pays/mean_chg_TIVA_REV4_HC_2005-2015.dta", replace
}

insheet using "$dir/Bases_sources/Prix_du_pétrole.csv", clear
rename v1 year
merge 1:m year using "$dir/Results/Secteurs_pays/mean_chg_TIVA_REV4_HC_2005-2015.dta"
drop if _merge==1
drop _merge

replace shockmulti=shockmulti/10
label var shockmulti "Effet sur les prix d'une augmentation du 10% du prix du pétrole"

gen shockadditif = shockmulti*100/brent_usd
label var shockadditif "Effet sur les prix d'une augmentation du 10$ du prix du pétrole"

label var brent_usd "Prix du baril de brent en USD"

graph twoway (line  shockmulti year, yaxis(1) )  ///
			(line  shockadditif year, yaxis(1)) ///
			(line  brent_usd year, yaxis(2) lstyle(dot)) if c=="FRA" , ///
			note("Pour la France. Source: PIWIM (TIVA_REV4)") ///
			legend(rows(3))
			
graph export "$dir/Results/secteurs_pays/graphiques/evolution_impact_pétrole_abs.png", replace
			
foreach varinteret of varlist shockmulti shockadditif brent_usd {
	bys c : gen blink= `varinteret' if year==2005
	egen base_`varinteret'=max(blink), by(c)
	drop blink
	gen indice_`varinteret'=`varinteret'/base_`varinteret'*100
}

label var indice_shockmulti "Effet sur les prix d'une augmentation du 10% du prix du pétrole, 100 en 2005"

label var indice_shockadditif "Effet sur les prix d'une augmentation du 10$ du prix du pétrole, 100 en 2005"

label var indice_brent_usd "Prix du baril de brent en USD, 100 en 2005"

sort year c

graph twoway (line  indice_shockmulti year)  ///
			(line  indice_shockadditif year) ///
			(line  indice_brent_usd year, lstyle(dot)) if c=="FRA" , ///
			note("Pour la France. Source: PIWIM (TIVA_REV4)") ///
			legend(rows(3) size(small))
			
graph export "$dir/Results/secteurs_pays/graphiques/evolution_impact_pétrole_indice.png", replace
			



