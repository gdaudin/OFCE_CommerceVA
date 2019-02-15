
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv269a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'" == "guillaumedaudin") use "$dir/BME.dta", clear
if ("`c(hostname)'" == "widv269a") use  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear
if ("`c(hostname)'" == "FP1376CD") use  "T:\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear

generate pays = upper(c)+"_EUR" if type == "ERT"
replace pays = upper(c) if type == "CXD"

capture program drop compar_bme
program compar_bme
args year source 

merge m:1 pays using "$dir/Results/Devaluations/auto_chocs_HC_`source'_`year'.dta"


 format %14.2f pond_`source'_HC BME_1 /*nombre décimales*/
drop _merge
drop if BME_1== .
replace pond_`source'_HC = 10*pond_`source'_HC

foreach yrs of numlist 2018 2019 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	twoway (scatter BME_1 pond_`source'_HC if year == `yrs' & type == "ERT", mlabel(c)) (lfit BME_1 pond_`source'_HC if year == `yrs' & type == "ERT", range(-1.5 0)) ///
	(lfit pond_`source'_HC pond_`source'_HC, range(-3.5 0)) if year == `yrs', ///
		ytitle(impact en % BMEs "`yrs'" (1ere année)) yscale(range(-3.5 0)) ylabel(-3.5(0.5)0, grid) /// 
		xtitle(impact en % PIWIM "`year'") xscale(range(-3 0)) xlabel(-3.5(0.5)0, grid) legend(off) name(BME_1_vs_`source'_`yrs', replace)
}


graph combine  BME_1_vs_`source'_2018 BME_1_vs_`source'_2019
graph save "$dir/Results/BME_1_vs_`source'.gph",  replace 
graph export "$dir/Results/BME_1_vs_`source'.pdf",  replace 


format %14.2f pond_`source'_HC BME_3
foreach yrs of numlist 2018 2019 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	twoway (scatter BME_3 pond_`source'_HC if year == `yrs' & type == "ERT", mlabel(c)) (lfit BME_3 pond_`source'_HC if year == `yrs' & type == "ERT", range(-1.5 0)) ///
	(lfit pond_`source'_HC pond_`source'_HC, range(-3.5 0)) if year == `yrs', ///
		ytitle(impact en % BMEs "`yrs'" (3e année)) yscale(range(-3.5 0)) ylabel(-3.5(0.5)0, grid) /// 
		xtitle(impact en % PIWIM "`year'") xscale(range(-3.5 0)) xlabel(-3.5(0.5)0, grid) legend(off) name(BME_3_vs_`source'_`yrs', replace)
}

graph combine  BME_3_vs_`source'_2018 BME_3_vs_`source'_2019 
graph save "$dir/Results/BME_3_vs_`source'.gph",  replace 
graph export "$dir/Results/BME_3_vs_`source'.pdf",  replace 

end
compar_bme 2015 TIVA_REV4 
compar_bme 2014 WIOD 
