
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 

import excel "$dir/Bases_Sources/Data_GDP_95_18_new.xlsx", /*
			*/sheet("WEO_Data (4)") firstrow clear
keep CodeTiva y*
drop if CodeTiva==""
reshape long y, i(CodeTiva) j(year)
rename y GDP
rename CodeTiva pays
replace GDP=GDP*1000000000

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


import excel "$dir/Bases_Sources/banque_mondiale_conso_finale.xlsx", sheet("conso_a_utiliser") cellrange(A7:AC69) firstrow clear
foreach v of varlist E-AC {
    local x : variable label `v'
	rename `v' y`x'
}

keep CountryCode y*
rename y* conso*
reshape long conso,i(CountryCode) j(year)
replace conso=conso*1000000000
rename CountryCode pays
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace

import excel "$dir/Bases_Sources/Eurostat_conso_intermediaires_new.xls", sheet("Data (2)") cellrange(A11:Y43) firstrow clear
rename GEOTIME pays
foreach v of varlist B-Y {
    local x : variable label `v'
	rename `v' y`x'
}
rename y* conso_interm*
reshape long conso_interm,i(pays) j(year)
destring conso_interm, replace force
replace conso_interm=conso_interm*1000000
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


import excel "$dir/Bases_Sources/UN_comtrade_biens_de_conso_95_2018.xlsx", /*
	*/sheet("UN_comtrade_biens_de_conso") firstrow clear
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_conso
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


import excel "$dir/Bases_Sources/UN_comtrade_biens_intermediaires_95_2018.xlsx", /*
	*/sheet("Biens intermédiaires") firstrow clear
***Rq : on a enlevé un secteur qui manquait parfois
*Il y a un sujet sur les imports 321* Fuels and lubricants, processed (motor spirit)
*qui disparaissent certaines années dans certains 
*pays... A ce stade, je les ai exclues de la base, ce qui n'est pas très satisfaisant.
******	
	
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_interm
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace

/*
*Au 29 novembre 2019, il manque 2008 et plus dans total
import excel "$dir/Bases_Sources/UN_comtrade_total.xlsx", /*
	*/sheet("Total") firstrow clear
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_tot
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta", keep(3)
drop _merge
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace
*/

drop if year==1995 | year==1996 | year==1997


save "$dir/Bases_Sources/Doigt_mouillé.dta", replace



*********************************************Régression en cross-section 



capture program drop collecter_resultats_reg
program collecter_resultats_reg
args source y reg
	use "$dir/Bases_Sources/Doigt_mouillé.dta", clear
	if "`reg'"=="reg1" generate ratio_impt_conso=impt_conso/GDP
	if "`reg'"=="reg1" generate ratio_impt_interm = impt_interm/GDP
	
	if "`reg'"=="reg2" generate ratio_impt_conso=impt_conso/conso
	if "`reg'"=="reg2" generate ratio_impt_interm = impt_interm/conso_interm*(1-impt_conso/conso)
	
	gen E1_E2 = ratio_impt_conso + ratio_impt_interm
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_`source'_`y'.dta", keep(3)
	drop if strmatch(pays,"*_EUR")==1
	
	replace pond_`source'_HC=-pond_`source'_HC
	reg pond_`source'_HC E1_E2
	
	predict x
	
	
	gen y=x
	gen z=pond_`source'_HC
	graph twoway (scatter x pond_`source'_HC, mlabel(pays)) (line x y) (line z pond_`source'_HC), /*
	*/ title (`reg'_`source'_`y') /*
	 */ name("resultats_`reg'_`source'_`y'", replace)
	graph export  "$dir/Results/resultats_doigt_mouillé_`reg'_`source'_`y'.pdf", replace
	
	keep year
	gen source="`source'"
	gen R2=e(r2)
	gen b_cst=_b[_cons]
	*gen b_conso=_b[ratio_impt_conso]
	*gen b_interm=_b[ratio_impt_interm]
	gen b_E1_E2=_b[E1_E2]
	gen se_cst=_se[_cons]
	*gen se_conso=_se[ratio_impt_conso]
	*gen se_interm=_se[ratio_impt_interm]
	gen se_E1_E2=_se[E1_E2]
	gen nbr_obs = e(N)
	keep if _n==1
	capture append using "$dir/Results/resultats_doigt_mouillé_`reg'.dta"
	save "$dir/Results/resultats_doigt_mouillé_`reg'.dta", replace
	
end



set graphics off

capture erase "$dir/Results/resultats_doigt_mouillé_reg1.dta"
capture erase "$dir/Results/resultats_doigt_mouillé_reg2.dta"

foreach y of num 1998(1)2011 {

	collecter_resultats_reg TIVA `y' reg1
	collecter_resultats_reg TIVA `y' reg2
}

foreach y of num 2000(1)2014 {
	collecter_resultats_reg WIOD `y' reg1
	collecter_resultats_reg WIOD `y' reg2
}


foreach y of num 2005(1)2015 {
	collecter_resultats_reg TIVA_REV4 `y' reg1
	collecter_resultats_reg TIVA_REV4 `y' reg2
}	

set graphics on



****************** Graphiques de coefficients

foreach reg in reg2 reg1 {

	use "$dir/Results/resultats_doigt_mouillé_`reg'.dta", clear
	
	gen high_E1_E2=b_E1_E2-1.96*se_E1_E2
	gen low_E1_E2=b_E1_E2+1.96*se_E1_E2
	graph twoway (rarea high_E1_E2 low_E1_E2 year if source=="TIVA", fcolor(%20) ) (connected b_E1_E2 year if source=="TIVA") /*
				*/ (rarea high_E1_E2 low_E1_E2 year if source=="TIVA_REV4" , fcolor(%20) ) (connected b_E1_E2 year if source=="TIVA_REV4")/*
				*/ (rarea high_E1_E2 low_E1_E2 year if source=="WIOD" , fcolor(%20)  ) (connected b_E1_E2 year if source=="WIOD"), /*
				*/ legend( order(1 3 5) label(1 TIVA) label(3 TIVA_REV4) label(5 WIOD) ) /*
				*/ title(beta)
	graph export "$dir/Results/`reg'_beta.pdf", replace
	
	/*if "`reg'"=="reg2"*/ label var b_E1_E2 "Coefficient of the proxy of E1HC+E2HC (with 95% confidence intervals)"
	label var R2 "R2"
	
	
	
	
	graph twoway ///
		(line b_E1_E2 year if source=="WIOD", lcolor(black)) ///
		(line low_E1_E2 year  if source=="WIOD", lpattern(dash) lwidth(vthin) lcolor(black)) ///
		(line high_E1_E2 year  if source=="WIOD",lpattern(dash) lwidth(vthin) lcolor(black)) ///
		(connected R2 year  if source=="WIOD",  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4) rows(2) size(small)) ///
		scheme(s1color)
	graph export "$dir/Results/`reg'_beta_WIOD.pdf", replace
	graph export "$dir/commerce_VA_inflation/Rédaction/`reg'_beta_WIOD.pdf", replace
	

	
	/*
	gen high_interm=b_interm-1.96*se_interm
	gen low_interm=b_interm+1.96*se_interm
	graph twoway (rarea high_interm low_interm year if source=="TIVA", fcolor(%20) ) (connected b_interm year if source=="TIVA") /*
				*/ (rarea high_interm low_interm year if source=="TIVA_REV4" , fcolor(%20) ) (connected b_interm year if source=="TIVA_REV4") /*
				*/ (rarea high_interm low_interm year if source=="WIOD" , fcolor(%20)  ) (connected b_interm year if source=="WIOD"), /*
				*/ legend( order(1 3 5) label(1 TIVA) label(3 TIVA_REV4) label(5 WIOD) )  /*
				*/ title(gamma)
	graph export "$dir/Results/`reg'_gamma_`source'_`y'.pdf", replace
	*/
	
	gen high_cst=b_cst-1.96*se_cst
	gen low_cst=b_cst+1.96*se_cst
	graph twoway (rarea high_cst low_cst year if source=="TIVA", fcolor(%20) ) (connected b_cst year if source=="TIVA") /*
				*/ (rarea high_cst low_cst year if source=="TIVA_REV4" , fcolor(%20) ) (connected b_cst year if source=="TIVA_REV4") /*
				*/ (rarea high_cst low_cst year if source=="WIOD" , fcolor(%20)  ) (connected b_cst year if source=="WIOD"), /*
				*/ legend( order(1 3 5) label(1 TIVA) label(3 TIVA_REV4) label(5 WIOD) ) /*
				*/ title(alpha)
	graph export "$dir/Results/`reg'_alpha.pdf", replace
	
	
		graph twoway (connected R2 year if source=="TIVA") /*
				*/   (connected R2 year if source=="TIVA_REV4") /*
				*/   (connected R2 year if source=="WIOD"), /*
				*/ legend( order(1 2 3) label(1 TIVA) label(2 TIVA_REV4) label(3 WIOD) ) /*
				*/ title(R2)
	graph export "$dir/Results/`reg'_R2.pdf", replace
	
	
}

***************** Pour les calculs en panel

use "$dir/Bases_Sources/Doigt_mouillé.dta", clear
	
foreach y of num 1998(1)2011 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_TIVA_`y'.dta", update
		drop _merge
	
}

foreach y of num 2000(1)2014 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_WIOD_`y'.dta", update
		drop _merge
	
}


foreach y of num 2005(1)2015 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_TIVA_REV4_`y'.dta",  update
		drop _merge
	
}	

	


encode pays, generate(pays_num)

tsset pays_num year
generate ratio_impt_conso=impt_conso/conso
generate ratio_impt_interm = impt_interm/conso_interm*(1-impt_conso/conso)



foreach source in WIOD TIVA TIVA_REV4 {

	reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num
	predict x
	replace x = -x
	replace pond_`source'_HC=-pond_`source'_HC
	gen y=x
	gen z=pond_`source'_HC
	graph twoway (scatter x pond_`source'_HC, mlabel(pays)) (line x y) (line z pond_`source'_HC), /*
	*/ title (Reg2_`source'_panel) /*
	 */ name("resultats_panel_`source'", replace)
	graph export  "$dir/Results/resultats_doigt_mouillé_panel_`source'.pdf", replace
	drop x
	drop y
	drop z
}

local WIOD_pred=2014
local TIVA_REV4_pred=2015
local TIVA_pred = 2011



*****************Pour les prédictions après Panel


foreach reg in reg2 reg1 {

	if "`reg'"=="reg1" {
		replace ratio_impt_conso=impt_conso/GDP
		replace ratio_impt_interm = impt_interm/GDP
	}
	if "`reg'"=="reg2" {
		replace ratio_impt_conso=impt_conso/conso
		replace ratio_impt_interm = impt_interm/conso_interm*(1-impt_conso/conso)
	}
	
	foreach lag_pred of numlist 1(1)8 {
		foreach source in WIOD TIVA TIVA_REV4 {
			foreach trend in no yes {
				local `source'_out = ``source'_pred'-`lag_pred'+1
				
				if "`trend'"=="no" reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num if year <``source'_out'
				if "`trend'"=="yes" reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num year if year <``source'_out'
				predict x if year== ``source'_pred'
				gen y=x
				gen z=pond_`source'_HC
				corr x pond_`source'_HC
				local correlation = r(rho)
				local correlation : display %4.3f `correlation'
				
				gen error = abs(x-pond_`source'_HC)/ pond_`source'_HC
				summarize error
				local mean_error= r(mean)
				local mean_error : display %4.3f `mean_error'
				summarize error, detail
				local median_error= r(p50)
				local median_error : display %4.3f `median_error'
				
				label var pond_`source'_HC "Elasticity from `source'"
				label var x "Predicted elasticity"
				
				
				graph twoway (scatter x pond_`source'_HC, mlabel(pays)) (lfit x pond_`source'_HC, lpattern(dash)) /*
				*/ (line x y) (line z pond_`source'_HC), legend(off) /*
				*//* title (`source'_`reg'_pred_`lag_pred'y trend: `trend') *//*
				 */ name("`source'_pred_`lag_pred'y", replace) ytitle("Predicted elasticity")/*
				 */ note("Correlation: `correlation' Mean error: `mean_error' p.c.  Median error: `median_error' p.c.") 
				
				graph export  "$dir/Results/resultats_`reg'_doigt_mouillé_`source'_pred_`lag_pred'y_trend_`trend'.pdf", replace
				if "`source'"=="WIOD" & "`trend'"=="no" & `lag_pred'==6 {
					graph export  "$dir/commerce_VA_inflation/Rédaction/resultats_`reg'_doigt_mouille_`source'_pred_`lag_pred'y_trend_`trend'.pdf", replace
				}
				drop x
				drop y
				drop z
				drop error
			}
		}
	}

}





