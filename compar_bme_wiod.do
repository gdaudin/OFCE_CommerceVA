
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv269a") global dir  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019" 
/*else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"*/

if ("`c(username)'"!="guillaumedaudin") use "$dir/BME.dta", clear
else use "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta", clear  
 
generate pays = lower(c)+"_eur"

merge m:1 pays using "D:\home\T822289\CommerceVA\Results\Étude rapport D+I et Bouclage Mondial\Elast_par_pays_2014_WIOD_HC.dta"

 format %14.2f pond_WIOD_HC BME_1 /*nombre décimales*/
drop _merge
drop if BME_1== .
replace pond_WIOD_HC = -10*pond_WIOD_HC

foreach yrs of numlist 2018 2019 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	twoway (scatter BME_1 pond_WIOD_HC if year == "`yrs'" & type == "ERT", mlabel(c)) (lfit BME_1 pond_WIOD_HC if year == "`yrs'" & type == "ERT", range(-1.5 0)) ///
	(lfit pond_WIOD_HC pond_WIOD_HC, range(-3.5 0)) if year == "`yrs'", ///
		ytitle(impact en % BMEs "`yrs'" (1ere année)) yscale(range(-3.5 0)) ylabel(-3.5(0.5)0, grid) /// 
		xtitle(impact en % PIWIM 2014) xscale(range(-3 0)) xlabel(-3.5(0.5)0, grid) legend(off) name(BME_1_vs_WIOD_`yrs', replace)
}


graph combine  BME_1_vs_WIOD_2018 BME_1_vs_WIOD_2019
graph save "$dir/Results/BME_1_vs_WIOD.gph",  replace 
graph export "$dir/Results/BME_1_vs_WIOD.pdf",  replace 


format %14.2f pond_WIOD_HC BME_3
foreach yrs of numlist 2018 2019 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	twoway (scatter BME_3 pond_WIOD_HC if year == "`yrs'" & type == "ERT", mlabel(c)) (lfit BME_3 pond_WIOD_HC if year == "`yrs'" & type == "ERT", range(-1.5 0)) ///
	(lfit pond_WIOD_HC pond_WIOD_HC, range(-3.5 0)) if year == "`yrs'", ///
		ytitle(impact en % BMEs "`yrs'" (3e année)) yscale(range(-3.5 0)) ylabel(-3.5(0.5)0, grid) /// 
		xtitle(impact en % PIWIM 2014) xscale(range(-3.5 0)) xlabel(-3.5(0.5)0, grid) legend(off) name(BME_3_vs_WIOD_`yrs', replace)
}

graph combine  BME_3_vs_WIOD_2018 BME_3_vs_WIOD_2019 
graph save "$dir/Results/BME_3_vs_WIOD.gph",  replace 
graph export "$dir/Results/BME_3_vs_WIOD.pdf",  replace 
