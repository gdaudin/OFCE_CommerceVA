clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
global dirgit "X:\Agents\LALLIARD"

*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	

global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"



	


capture program drop etude
program etude
args year source type

**Exemple : etude 2011 WIOD HC
**Exemple : etude 2011 WIOD par_sect
	


if "`source'"=="TIVA" local liste_chocs shockEUR1-shockZAF1
if "`source'"=="WIOD" local liste_chocs shockEUR1-shockUSA1

if "`type'"=="HC" | "`type'" =="HC_note" use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear
if "`type'"=="par_sect" use "$dir/Results/Devaluations/`source'_C_`year'_exch.dta", clear



foreach var of varlist `liste_chocs' {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0 ///
	& strpos("$china",c)==0 & strpos("$mexique",c)==0
	replace `var' = 0 if "`var'"!="shockCHN1" & strpos("$china",c)!=0
	replace `var' = 0 if "`var'"!="shockMEX1" & strpos("$mexique",c)!=0
}



egen pond_`source'_`type' = rowtotal(`liste_chocs')


drop shock*

*** Pour aller chercher les chocs de la ZE
if "`type'"=="HC" | "`type'" =="HC_note" {
	merge 1:1 c using "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta"
	keep c pond_`source'_`type' shockEUR
}
if "`type'"=="par_sect" {
	merge 1:1 c s using "$dir/Results/Devaluations/`source'_C_`year'_exch.dta"
	keep c s pond_`source'_`type' shockEUR
}

rename shockEUR1 s_EUR
rename pond_`source'_`type' s_auto



if "`type'"=="HC" | "`type'" =="HC_note" reshape long s_, i(c) j(source_shock) string
if "`type'"=="par_sect"  reshape long s_, i(c s) j(source_shock) string


drop if strpos("$eurozone",c)==0 & source_shock=="EUR" 

replace c=c+"_EUR" if source_shock=="EUR" 

drop source_shock

rename s_ pond_`source'_`type'


replace pond_`source'_`type' = -(pond_`source'_`type' - 1)/2

*replace c =c+"_EUR" if source_shock=="EUR" 



gen pays=lower(c)
if "`type'"=="par_sect" rename s sector
if "`type'"=="par_sect" replace sector=lower(sector)


if "`type'"=="HC" | "`type'" =="HC_note" {
	merge 1:1 pays using "$dir/Bases/imp_inputs_HC_`year'_`source'_hze_not.dta"
	drop _merge
	replace pays =upper(pays) 
	merge 1:1 pays using "$dir/Bases/contenu_dom_HC_impt_`year'_`source'_hze_not.dta"
	drop _merge
	replace pays =lower(pays)

	replace pays =pays+"_AUTO"
	replace pays = substr(pays,1,3) if strmatch(pays,"*_eur_AUTO")==1
	merge 1:1 pays using "$dir/Bases/imp_inputs_HC_`year'_`source'_hze_yes.dta", update
	drop _merge
	replace pays =upper(pays) 
	merge 1:1 pays using "$dir/Bases/contenu_dom_HC_impt_`year'_`source'_hze_yes.dta", update 
	replace pays =lower(pays) 
	drop _merge
	replace pays = pays+"_eur" if strlen(pays)==3
	replace pays =substr(pays,1,3) if strmatch(pays,"*_auto")==1
	
	merge 1:1 pays using "$dir/Bases/contenu_impHC_`source'_`year'.dta"
	drop if _merge ==1
	drop _merge year
	
	*replace ratio_ci_impt_HC = ratio_ci_impt_HC*(1-contenu_impHC) + contenu_impHC - contenu_dom_HC_etranger
	
}



if "`type'"=="par_sect" {
	merge 1:1 pays sector using "$dir/Bases/imp_inputs_par_sect_`year'_`source'_hze_not.dta"
	drop _merge
	replace pays =pays+"_AUTO"
	replace pays = substr(pays,1,3) if strmatch(pays,"*_eur_AUTO")==1
	
	merge 1:1 pays sector using "$dir/Bases/imp_inputs_par_sect_`year'_`source'_hze_yes.dta", update
	drop _merge
	replace pays = pays+"_eur" if strlen(pays)==3
	replace pays =substr(pays,1,3) if strmatch(pays,"*_AUTO")==1
	
	rename ratio_ci_impt_prod ratio_ci_impt_`type'
}


*drop if c=="CHN"
*hze_not : on considère les autres pays de la ZE comme étrangers (contraire de hze_yes)

*effet direct repondéré par le choc: le choc correspond à une appréciation de 100% 
*=>on double l'impact pour comparer le ratio de CI importées (comptable) à l'effet direct choqué
if "`type'"=="HC" | "`type'" =="HC_note" {
gen E1HC = contenu_impHC/2
gen E2HC = (ratio_ci_impt_HC)*(1-contenu_impHC)/2
gen E3HC = - contenu_dom_HC_etranger
}

gen E1HC_E2HC=E1HC + E2HC
label var pond_`source'_`type' "Élasticité des prix (`type') en monnaie nationale à un choc de la monnaie nationale"

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`year'_`source'_`type'.dta", replace

if "`type'"=="HC" {


	replace c="" /*if c!="FRA_EUR" & c!="DEU_EUR" & c!="LUX_EUR" & c!="FRA" & c!="DEU" & c!="LUX" ///
					& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" */
	graph twoway (scatter pond_`source'_`type' E1HC_E2HC, mlabel(c) mlabsize(medium)) ///
			(lfit pond_`source'_`type' E1HC_E2HC) ///
			(lfit pond_`source'_`type' pond_`source'_`type',lwidth(vthin) color(black)) , ///
			/*title("Comparing direct and modelled effects")*/ ///
			xtitle("E1HC + E2HC") ytitle("`source' Elasticities `year'") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3) ///
			legend(off)
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»			
						
	
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph_`year'_`source'_`type'.pdf", replace
	
	graph close

	
	
}



if "`type'"=="HC_note" & `year'==2014 {

	keep if strpos(c,"_EUR")!=0
	replace c=subinstr(c,"_EUR"e,"",.)
	replace pond_`source'_HC=-pond_`source'_HC/20*100
	replace E1HC_E2HC = -E1HC_E2HC/20*100
	gen sample = 0
	replace sample=1 if c=="FRA" | c=="DEU" | c=="NLD" | c=="ESP" | c=="ITA"
	replace c="" if c!="FRA" & c!="DEU" & c!="NLD"  & c!="IRL"
	graph twoway  ///
			(scatter pond_`source'_HC E1HC_E2HC if sample==0, mlabel(c) mlabsize(medium) mlabcolor(sky) mcolor(sky)) ///
			(scatter pond_`source'_HC E1HC_E2HC if sample==1, mlabel(c) mlabsize(medium) mcolor(black) mlabcolor(black) ) ///
			(lfit pond_`source'_HC E1HC_E2HC) ///
			(lfit pond_`source'_HC pond_`source'_HC,lwidth(vthin) color(black)) ///
			(lfit E1HC_E2HC E1HC_E2HC,lwidth(vthin) color(black)) , ///
			xtitle("Impact D+I, en %", /*size(vsmall) */) ///
			ytitle("Impact PIWIM, en %") ///
			yscale(range(-1 -0.25)) xscale(range(-1 -0.25)) xlabel(-1 (0.25) -0.25) ylabel(-1 (0.25) -0.25) ///
			legend(off) ///
			ylabel(,format(%9.2fc)) ///
			note("PIWIM (WIOD, 2014)")
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»			
	

	
	graph export "$dirgit/Rédaction_note/Rapport_D+I_bouclé_pour_note.png", replace
	
	graph close
	
	aiuesnaiusret
	
	

	
	
}



if "`type'" == "HC" {

	foreach reg in reg_ns reg_sep  {

		if "`reg'"=="reg_sep" reg pond_`source'_HC E1HC E2HC E3HC
		if "`reg'"=="reg_ns" reg pond_`source'_HC E1HC_E2HC
		
		preserve
		gen year=`year'
		gen source="`source'"
		gen R2_`reg'=e(r2)
		gen reg="`reg'"
	*	matrix COEF = e(b)
	*	matrix VARCOVAR=e(V)
		if "`reg'"=="reg_ns" {
			
			gen b_ns=_b[E1HC_E2HC]
			gen se_ns=_se[E1HC_E2HC]
			gen b_cst_reg_ns=_b[_cons]
			gen se_cst_reg_ns=_se[_cons]
		}
		if "`reg'"=="reg_sep" {
			
			gen b_E1HC=_b[E1HC]
			gen b_E2HC=_b[E2HC]
			gen b_E3HC=_b[E3HC]
			gen se_cst=_se[_cons]
			gen se_E1HC=_se[E1HC]
			gen se_E2HC=_se[E2HC]
			gen se_E3HC=_se[E3HC]
			gen b_cst_reg_sep=_b[_cons]
			gen se_cst_reg_sep =_se[_cons] 
		}
	
/*
predict predict
valuesof pays if abs(ln(predict/pond_`source'_`type')) > 0.35
gen predict_hors_0_0_35 = "`r(values)'"
valuesof pays if choc_dplusi_`type'>= pond_`source'_`type'
gen D_I_trop_grand = "`r(values)'"
corr pond_`source'_`type' choc_dplusi_`type'	
gen corr = r(rho)
*/

		
		keep if _n==1
		keep year source R2_`reg'-se_cst_`reg'
		save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'_`reg'.dta", replace 
		if "`reg'"=="reg_sep" {
			merge 1:1 year source using ///
			"$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'_reg_ns.dta"
			assert _merge==3
			drop _merge
			save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'.dta", replace 
		
			if `year'!=$start_year {
				append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"
			}

			save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta", replace
		}
		restore

	
	}

}



end 


****************************************************************************


foreach source in  WIOD  TIVA {



	if "`source'"=="WIOD" global start_year 2000
	if "`source'"=="TIVA" global start_year 1995


	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	
	
   capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta" 
	foreach type in HC /*HC_note*/ {
		capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"

*		foreach i of numlist 2014  {
		foreach i of numlist $start_year (1) $end_year  {
			etude `i' `source' `type'		
		}
	
	clear
	}

}





/*
foreach source in  WIOD  {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_HC.dta", clear
	foreach var in ns cst_reg_ns E1HC E2HC E3HC cst_reg_sep {
		gen borne_inf_`var'= b_`var'-1.96*se_`var'
		gen borne_sup_`var' =b_`var'+1.96*se_`var'
	}
	label var b_ns "b_E1HC_E2HC"
	
	graph twoway ///
		(line b_ns year, lcolor(black) ) (line borne_inf_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_ns year,lpattern(dash) lwidth(vthin) lcolor(black) ) ///
		(line b_E1HC year,  lcolor(turquoise)) (line borne_inf_E1HC year, lpattern(dash) lwidth(vthin) lcolor(turquoise)) (line borne_sup_E1HC year,lpattern(dash) lwidth(vthin) lcolor(turquoise) ) ///
		(line b_E2HC year, lcolor(red)) (line borne_inf_E2HC year, lpattern(dash) lwidth(vthin) lcolor(red)) (line borne_sup_E2HC year,lpattern(dash) lwidth(vthin) lcolor(red) ) /// 
		(line b_E3HC year,  lcolor(sienna)) (line borne_inf_E3HC year, lpattern(dash) lwidth(vthin) lcolor(sienna)) (line borne_sup_E3HC year,lpattern(dash) lwidth(vthin) lcolor(sienna) )   ///
		(connected R2_reg_sep year,  lcolor(black) msize(small) mcolor(black)) (connected R2_reg_ns year,  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4 7 10 13 14))

	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_E_`source'_HC.pdf", replace
	
	label var b_cst_reg_ns "Constant_equation 1"
	label var b_cst_reg_sep "Constant_equation 2"
		graph twoway ///
		(line b_cst_reg_ns year, lcolor(black) ) (line borne_inf_cst_reg_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_cst_reg_ns year,lpattern(dash) lwidth(vthin) lcolor(black) )    ///
		(connected b_cst_reg_sep year,  lcolor(black) msize(small) mcolor(black)) (connected borne_inf_cst_reg_sep year, lpattern(dash) lwidth(vthin) lcolor(black) msize(small) mcolor(black)) (connected borne_sup_cst_reg_sep year,lpattern(dash) lwidth(vthin) lcolor(black) msize(small) mcolor(black) )   /// 
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4 7 10 13 16))

	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_cst_`source'_HC.pdf", replace
}
*/



foreach source in  WIOD TIVA {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_HC.dta", clear
	foreach var in ns cst_reg_ns {
		gen borne_inf_`var'= b_`var'-1.96*se_`var'
		gen borne_sup_`var' =b_`var'+1.96*se_`var'
	}
	label var b_ns "Coefficient of E1HC+E2HC (with 95% confidence intervals)"
	label var R2_reg_ns "R2"
	
	graph twoway ///
		(line b_ns year, lcolor(black) ) (line borne_inf_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_ns year,lpattern(dash) lwidth(vthin) lcolor(black) ) ///
		(connected R2_reg_ns year,  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4) rows(2))

	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_E_`source'_HC.pdf", replace
	
	label var b_cst_reg_ns "Constant (with 95% confidence intervals)"
		graph twoway ///
		(line b_cst_reg_ns year, lcolor(black) ) (line borne_inf_cst_reg_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_cst_reg_ns year,lpattern(dash) lwidth(vthin) lcolor(black) )    ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1))

	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_cst_`source'_HC.pdf", replace
}

foreach source in  WIOD TIVA {
	if "`source'"=="WIOD" global start_year 2000
	if "`source'"=="TIVA" global start_year 1995


	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	
	foreach i of numlist 2014  {
	graph drop _all
*	foreach i of numlist $start_year (1) $end_year  {
			use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`i'_`source'_HC.dta", clear 
			gen E4HC = pond_WIOD_HC - E1HC - E2HC - E3HC
			foreach var in E1HC E2HC E3HC E4HC {
				gen share_`var'=`var'/pond_WIOD_HC
				histogram share_`var', start(-0.2) width(0.1) freq name(`var')  xscale(range(-0.1 (0.1) 0.8)) xlabel(-0.1 (0.1) 0.8)
			}
		graph combine 	E1HC E2HC E3HC E4HC
		graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/hist_components_`source'.pdf", replace
			
		}
	
	
	
}





