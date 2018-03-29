
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dirgit "X:\Agents\LALLIARD\commerce_VA_inflation\"

use $dir/BME.dta, clear
 
generate pays = lower(c)+"_eur"

merge m:1 pays using "Y:\DiagConj\Commun\CommerceVA\Results\Étude rapport D+I et Bouclage Mondial\Elast_par_pays_2014_WIOD_HC.dta"
 format %14.2f pond_WIOD_HC
drop _merge
drop if BME == .
replace pond_WIOD_HC = -5*pond_WIOD_HC

foreach yrs of numlist 2013 2015 2016 2017 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC, range(-1 0)) (lfit pond_WIOD_HC pond_WIOD_HC, range(-1 0)) if year == `yrs', ///
		ytitle(élasticité BMEs `yrs') yscale(range(-1 0)) ylabel(-1(0.2)0, grid) /// 
		xtitle(élasticité modèle PIWIM 2014) xscale(range(-1 0)) xlabel(-1(0.2)0, grid) legend(off) name(BME_vs_WIOD_`yrs', replace)
}


graph combine BME_vs_WIOD_2013 BME_vs_WIOD_2015 BME_vs_WIOD_2016 BME_vs_WIOD_2017
graph save "$dir/Graphiques/BME_vs_WIOD.gph",  replace 

