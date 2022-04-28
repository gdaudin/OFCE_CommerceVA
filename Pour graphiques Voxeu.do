


*gr0034.pkg
*from:  http://www.stata-journal.com/software/sj8-2/

*search labutil




clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/OFCE_CommerceVA"

*capture log close
*log using "$dir/$S_DATE.log", replace


do  "$dirgit/Definition_pays_secteur.do" `source'
global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"

/*
*******Pour graphique de sensibilité aux chocs de change
use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear


*drop if strpos(pays,"_EUR")!=0
replace ratio_impt_conso=impt_conso/GDP
replace ratio_impt_interm = impt_interm/GDP
drop if ratio_impt_conso==.
drop if ratio_impt_interm==.






foreach source in WIOD /*TIVA TIVA_REV4 MRIO*/ {
	*reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num
	reg pond_`source'_HC ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean i.pays_num
	predict x_`source' /*if year >= 2010  & pond_`source'_HC ==. */
}

keep if year==2019
graph hbar x_WIOD, over(pays, sort(1) label(labsize(tiny))) scheme(s1color) ytitle("Elasticity of the consumer prices" "to a shock in domestic currency, WIOD, 2019") note("Each country is assumed to have is own currency" "Except for countries suffixed by _EUR: the shock is then on the Euro")

graph export "$dirgit/Article VoxEU/Elasticity change WIOD 2019.png", replace


*******Pour graphique de sensibilité aux prix des hydrocarbure

use "$dir/Results/secteurs_pays/mean_chg_WIOD_HC_2014_RUS.dta", clear
rename shock1 RUS
merge 1:1 c using "$dir/Results/secteurs_pays/mean_chg_WIOD_HC_2014.dta"
drop _merge
gen ratio = RUS/shock1
sort ratio
drop if c=="RUS"

graph hbar shock1 ratio , over(c, sort(2) label(labsize(tiny))) scheme(s1color) legend(label(1 "Elasticity to a shock on hydrocarbon prices") label(2  "Share attributable to Russian hydrocarbon prices") rows(2))

graph export "$dirgit/Article VoxEU/Elasticity hydrocarbon WIOD 2019.png", replace

*/

********Pour graphique de la distribution des shares

foreach source in  WIOD /*TIVA TIVA_REV4 */{

	if "`source'"=="WIOD" global start_year 2014	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2015



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015
	
	foreach i of numlist 2014  {
		graph drop _all
*	foreach i of numlist $start_year (1) $end_year  {
		use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`i'_`source'_HC.dta", clear 
		replace pond_WIOD_HC=-pond_WIOD_HC
		gen E4HC = pond_WIOD_HC - E1HC - E2HC - E3HC
		gen blouf = 0
		gen mylabel= pays if strpos("FRA DEU DEU_EUR ITA ITA_EUR GBR CHN USA CAN JPN ",pays)!=0
			

	sort E1HC
	gen E1_order = _n
	labmask E1_order,values(pays)
	
	gen sample=1
	Definition_pays_secteur `source'
	replace sample=0 if strpos("$eurozone",pays)!=0
	
	graph hbar (asis) E1HC E2HC E3HC E4HC if sample==1,  stack over(E1_order, ///
		label(labsize(tiny))) ///
		marker(1, ms(O) mfcolor(gs1) mlcolor(gs1) msize(tiny) ) ///
		marker(2, ms(+) mfcolor(gs5) mlcolor(gs5) msize(small) ) ///
		marker(3, ms(O) mfcolor(gs9) mlcolor(gs9) msize(tiny) ) ///
		marker(4, ms(O) mfcolor(gs13) mlcolor(gs13) msize(small)) ///
		xsize(9)  ysize(7) ///
		name(distr_components_`source'_`i', replace) ///
		legend(position(3) cols(1)  size(vsmall) label(1 "E1.HC: Direct effect" "through imported" "consumption goods") ///
		label(2 "E2.HC: Effect on domestic" "consumption goods" "through imported inputs") ///
		label(3 "E3.HC: Effect on imported" "consumption goods" "through domestic inputs") ///
		label(4 "E4.HC: Residual")) ///
		scheme(s1color)
		
	graph export "$dirgit/Article VoxEU/distribution_components_`source'_`i'.png", replace	
		
			
		}
	
	
	
}
