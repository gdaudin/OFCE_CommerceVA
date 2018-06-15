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

gen E1HC_E2HC_E3HC=E1HC + E2HC + E3HC
label var pond_`source'_`type' "Élasticité des prix (`type') en monnaie nationale à un choc de la monnaie nationale"

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`year'_`source'_`type'.dta", replace

if "`type'"=="HC" {


	replace c="" /*if c!="FRA_EUR" & c!="DEU_EUR" & c!="LUX_EUR" & c!="FRA" & c!="DEU" & c!="LUX" ///
					& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" */
	graph twoway (scatter pond_`source'_`type' E1HC_E2HC_E3HC, mlabel(c) mlabsize(medium)) ///
			(lfit pond_`source'_`type' E1HC_E2HC_E3HC) ///
			(lfit pond_`source'_`type' pond_`source'_`type',lwidth(vthin) color(black)) , ///
			title("Comparing direct and modelled effects") ///
			xtitle("E1HC_E2HC_E3HC") ytitle("Price elasticity") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3) ///
			legend(off)
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»			
						
	
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph_`year'_`source'_`type'.pdf", replace
	
	graph close

	
	
}



if "`type'"=="HC_note" {

	keep if strpos(c,"_EUR")!=0
	replace c=subinstr(c,"_EUR"e,"",.)
	replace pond_`source'_HC=-pond_`source'_HC/5
	replace choc_dplusi_HC = -choc_dplusi_HC/5
	gen sample = 0
	replace sample=1 if c=="FRA" | c=="DEU" | c=="NLD" | c=="ESP" | c=="ITA"
	replace c="" if c!="FRA" & c!="DEU" & c!="NLD"  & c!="IRL"
	graph twoway  ///
			(scatter pond_`source'_HC E1HC_E2HC_E3HC if sample==0, mlabel(c) mlabsize(medium) mlabcolor(sky) mcolor(sky)) ///
			(scatter pond_`source'_HC E1HC_E2HC_E3HC if sample==1, mlabel(c) mlabsize(medium) mcolor(black) mlabcolor(black) ) ///
			(lfit pond_`source'_HC E1HC_E2HC_E3HC) ///
			(lfit pond_`source'_HC pond_`source'_HC,lwidth(vthin) color(black)) , ///
			xtitle("E1HC_E2HC_E3HC", /*size(vsmall) */) ///
			ytitle("PIWIM") ///
			yscale(range(-0.04 -0.01)) xscale(range(-0.04 -0.01)) xlabel(-0.04(0.005)-0.01) ylabel(-0.04(0.005)-0.01) ///
			legend(off) ///
			note("PIWIM (WIOD, 2014)")
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»			
	

	
	graph export "$dirgit\Commerce_VA_inflation\Rédaction_Note\Rapport_D+I_bouclé.png", replace
	
	graph close
	
	

	
	
}



if "`type'" == "HC" | "`type'" == "HC_note" {

	foreach reg in reg_ns reg_sep  {

		if "`reg'"=="reg_sep" reg pond_`source'_HC E1HC E2HC E3HC
		if "`reg'"=="reg_ns" reg pond_`source'_HC E1HC_E2HC_E3HC
		
		preserve
		gen year=`year'
		gen source="`source'"
		gen R2=e(r2)
		gen reg="`reg'"
	*	matrix COEF = e(b)
	*	matrix VARCOVAR=e(V)
		if "`reg'"=="reg_ns" {
			
			gen b_ns=_b[E1HC_E2HC_E3HC]
			gen se_cst=_se[_cons]
			gen se_ns=_se[E1HC_E2HC_E3HC]
			gen cst=_b[_cons]
		}
		if "`reg'"=="reg_sep" {
			
			gen b_E1HC=_b[E1HC]
			gen b_E2HC=_b[E2HC]
			gen b_E3HC=_b[E3HC]
			gen se_cst=_se[_cons]
			gen se_E1HS=_se[E1HC]
			gen se_E2HS=_se[E2HC]
			gen se_E3HS=_se[E3HC]
			gen cst=_b[_cons]
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




		save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'.dta", replace 
		keep if _n==1
		keep year source R2-cst
		if `year'!=$start_year | "`reg'"!="reg_ns" {
				append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"
		}

		save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta", replace
		restore

	
	}

}



end 

foreach source in  WIOD  {
*foreach source in  WIOD  TIVA {



	if "`source'"=="WIOD" global start_year 2000
	if "`source'"=="TIVA" global start_year 1995


	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	
	
   capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta" 
	foreach type in HC {
		capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"

*		foreach i of numlist 2000  {
		foreach i of numlist $start_year (1) $end_year  {
			etude `i' `source' `type'		
		}
	clear
	}

}

