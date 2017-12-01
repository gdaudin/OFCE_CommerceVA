clear
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

capture log close
log using "$dir/$S_DATE.log", replace
set matsize 7000

capture program drop Definition_pays_secteur
program Definition_pays_secteur
args source
*Definition_pays_secteur TIVA 

if "`source'"=="TIVA" {
global country "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country "$country  CHN CN1 CN2 CN3 CN4 COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country "$country  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country "$country  LTU LUX LVA MAR MEX MLT MX1 MX2 MX3 MYS NLD NOR NZL PER PHL POL PRT"
	global country "$country  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
global country_hc "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country_hc "$country_hc  CHN          COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country_hc "$country_hc  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country_hc "$country_hc  LTU LUX LVA MAR MEX MLT      MYS NLD NOR NZL PER PHL POL PRT"
	global country_hc "$country_hc  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
	
	global sector "C01T05 C10T14 C15T16 C17T19 C20 C21T22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37 C40T41 C45"
	global sector "$sector C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"
	
	global noneuro "ARG AUS BGR BRA BRN CAN CHE CHL CHN COL CRI CZE DNK GBR HKG HRV HUN IDN IND ISL ISR JPN KHM KOR MEX MX1 MX2 MX3 MYS NOR NZL PHL POL ROU ROW RUS SAU SGP SWE THA TUN TUR TWN USA VNM ZAF"
	global china "CHN CN1 CN2 CN3 CN4"
	global mexique "MEX MX1 MX2 MX3"
	
	global var_entree_sortie arg_c01t05agr-zaf_c95pvh
	
	}

if "`source'"=="WIOD" {
	global country "   AUS AUT BEL BGR BRA     CAN CHE" 
	global country "$country CHN                             CYP CZE DEU DNK ESP EST FIN"
	global country "$country FRA GBR GRC     HRV HUN IDN IND IRL        ITA JPN     KOR"
	global country "$country LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
	global country "$country ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	
	global country_hc $country
	
	global sector "A01 A02 A03 B C10-C12 C13-C15 C16 C17 C18 C19 C20 C21 C22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C31_C32 C33 C35 E35 E36 E37-E39"
	global sector "$sector F G45 G46 G47 H49 H50 H51 H52 H53 I J58 J59_J60"
	global sector "$sector J61 J62_J63 K64 K65 K66 L68 M69_M70 M71 M72 M73"
	global sector "$sector M74_M75 N O84 O85 Q R_S T U"
	
	
	global noneuro "BGR BRA CAN CHE CHN CZE DNK  GBR HRV HUN IDN IND  JPN KOR MEX NOR  POL ROU ROW RUS SWE TUR TWN USA"    
	global china "CHN"
	global mexique "MEX"
	
	global var_entree_sortie vAUS01-vUSA56
}

global nbr_pays = wordcount("$country")
global nbr_secteurs = wordcount("$sector")
global dim_matrice = $nbr_pays*$nbr_secteurs

*agrégats couverts identiquement par les 2 sources
global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
global eastern "BGR CZE HRV HUN POL ROU"

end



capture program drop imp_inputs // fournit le total des inputs importés par chaque pays
program imp_inputs
args yrs source vector

* exemple vector X Y HC


use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop hfce_aus-disc
	drop if v1 == "VA.TAXSUB" | v1 == "OUT"
	generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
}

if "`source'"=="WIOD" {
	 
	drop *57 *58 *59 *60 *61
	rename Country pays
	 
}





foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace `var' = 0 if pays==pays2
	drop pays2
}


drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh

xpose, clear varname

generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)

rename v1 imp_inputs

save "$dir/Bases/imp_inputs_`yrs'.dta", replace

use "$dir/Bases/prod.dta"

replace pays=lower(pays)

keep if year==`yrs'

merge 1:1 pays using "$dir/Bases/imp_inputs_`yrs'.dta" 

drop _merge

gen input_prod=imp_inputs/prod

keep pays input_prod

save "$dir/Bases/imp_inputs_`yrs'.dta", replace

end

*************************

capture program drop imp_inputs_hze // fournit le total des inputs importés de pays hors ze par chaque pays

program imp_inputs_hze

args yrs source


use "$dir/Bases/`source'_ICIO_`yrs'.dta"

drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"
generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

local eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace `var' = 0 if pays==pays2
	replace pays=upper(pays)
	foreach i of local eurozone{
		replace `var' = 0 if pays == "`i'"
		}
	drop pays2
	replace pays=lower(pays)
}


drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh

xpose, clear varname

generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)

rename v1 imp_inputs

save "$dir/Bases/imp_inputs_hze_`yrs'.dta", replace

use "$dir/Bases/prod.dta"

replace pays=lower(pays)

keep if year==`yrs'

merge 1:1 pays using "$dir/Bases/imp_inputs_hze_`yrs'.dta" 

drop _merge

gen input_prod=imp_inputs/prod

keep pays input_prod

save "$dir/Bases/imp_inputs_hze_`yrs'.dta", replace


end

********************

capture program drop loc_inputs // fournit le total des inputs importés par chaque pays
program loc_inputs
args yrs source

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"

generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace pays2=lower(pays2)
	replace `var' = 0 if pays!=pays2
	drop pays2
}

drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh
xpose, clear varname
generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)
rename v1 loc_inputs

save "$dir/Bases/loc_inputs_`yrs'.dta", replace

clear
use "$dir/Bases/prod.dta"
keep if year==`yrs'
replace pays=lower(pays)
drop year

merge 1:1 pays using "$dir/Bases/loc_inputs_`yrs'.dta"  //,keep(3)
drop _merge
replace loc_inputs=loc_inputs/prod
drop prod
save "$dir/Bases/loc_inputs_`yrs'.dta", replace

end

************
/////////////////////////////////////////////////////////
capture program drop imp_inputsX // fournit le total des inputs importés par chaque pays
program imp_inputsX
args yrs source

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"

generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace pays2=lower(pays2)
	replace `var' = 0 if pays==pays2
	drop pays2
}

drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh
xpose, clear varname
generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)
rename v1 imp_inputs

save "$dir/Bases/imp_inputsX_`yrs'.dta", replace

clear
use "$dir/Bases/exports.dta"
keep if year==`yrs'
replace pays=lower(pays)
drop year

merge 1:1 pays using "$dir/Bases/imp_inputsX_`yrs'.dta"  //,keep(3)
drop _merge
replace imp_inputs=imp_inputs/X
drop X
save "$dir/Bases/imp_inputsX_`yrs'.dta", replace

end

********************************************************************************************

//graphiques avec 
//   - impact choc euro / part des importations en provenance de pays hors zone euro
//   - impact chocs pays / 

foreach source in WIOD {

	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	Definition_pays_secteur `source'



	foreach i of numlist `start_year' (1)`end_year'  {
		//clear
		imp_inputs `i' `source' HC
		clear
		imp_inputs_hze `i' `source' Y
	}





	imp_inputsX  2011
	loc_inputs 2011

}

