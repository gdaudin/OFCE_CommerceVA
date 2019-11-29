
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


import excel "$dir/Bases_Sources/UN_comtrade_biens_de_conso_95_2018.xlsx", /*
	*/sheet("UN_comtrade_biens_de_conso") firstrow clear
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_conso
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta",keep(3)
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
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta",keep(3)
drop _merge

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


foreach y of num 1995(1)2015 {
	if `y'<=2011 merge 1:1 year pays using /*
		'*/ "~/Documents/Recherche/2017 BDF_Commerce VA/Results/Devaluations/auto_chocs_HC_TIVA_`y'.dta"
	capture drop _merge
	if `y'>=2000 & `y'<=2014 merge 1:1 year pays using /*
		'*/ "~/Documents/Recherche/2017 BDF_Commerce VA/Results/Devaluations/auto_chocs_HC_WIOD_`y'.dta"
	capture drop _merge
	if `y'>=2005 & `y'<=2015 merge 1:1 year pays using /*
		'*/ "~/Documents/Recherche/2017 BDF_Commerce VA/Results/Devaluations/auto_chocs_HC_TIVA_REV4_`y'.dta"
	capture drop _merge
}

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace			
	



