
clear
capture log using "/Users/sandrafronteau/Documents/Stage_OFCE/Stata/results/$S_DATE $S_TIME.log", replace
*---------------------------------------------------------------------------------------
*REGRESSION TO BETTER UNDERSTAND THE RELATIONSHIP BETWEEN YEARS, REGION AND SHOCK EFFECT
*---------------------------------------------------------------------------------------
capture program drop regress_effect
program regress_effect

clear all
set maxvar 30000
set matsize 11000
set more off
set trace on 
use "/Users/sandrafronteau/Documents/Stage_OFCE/Stata/data/ocde/mean_effect/mean_all.dta"


gen ln_shock = log(shock)

gen type_cause = cause+"_"+shock_type+"_"+weight+"_"+cor

gen type_effect = effect+"_"+shock_type+"_"+weight+"_"+cor

gen region = ""
global eurozone "AUT BEL DEU CYP ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
global restEU "BGR CZE DNK GBR HRV HUN NOR POL ROU SWE"
global rest "ARG AUS BRA BRN CAN CHL CHN CHNDOM CHNNPRE CHNPRO COL CRI HKG IDN IND ISR JPN KHM KOR MEX MEXGMF MEXNGM MYS NZL PHL ROW RUS SAU SGP THA TUN TUR TWN USA VNM ZAF"


set more off
foreach m of global rest{
	foreach n of global rest{
		replace region = "rest" if cause == "`m'" & effect =="`n'"
	}
}


foreach k of global restEU{
	foreach l of global restEU{
		replace region = "restEU" if cause == "`k'" & effect == "`l'"
	}
}

foreach i of global eurozone{
	foreach j of global eurozone{
		replace region = "eurozone" if cause == "`i'" & effect == "`j'"
	}
}

set more off
foreach i of global eurozone{
	foreach j of global restEU{
		replace region = "eurozone_restEU" if cause == "`i'" & effect == "`j'"
		replace region = "eurozone_restEU" if cause == "`j'" & effect == "`i'"
	}
}

replace region = "no" if region == ""

gen yearregion = region+"_"+year

drop if shock==0

xi i.type_cause i.type_effect i.yearregion

reg ln_shock _Itype_caus_2-_Itype_caus_4 _Itype_caus_13-_Itype_effe_536 _Iyearregio_3-_Iyearregio_35


outreg2 using /Users/sandrafronteau/Documents/Stage_OFCE/Stata/results/result_with_region.xls, replace label 
set more off
testparm _Iyearregio_*, equal

set trace off

end

regress_effect

log close
