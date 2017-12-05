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
args yrs source vector hze

* exemple vector X Y HC hze_not ou hze_yes

*Ouverture de la base contenant le vecteur ligne de production par pays et secteurs
clear
use "$dir/Bases/`source'_`yrs'_OUT.dta"
mkmat $var_entree_sortie, matrix(Y)
collapse (sum) $var_entree_sortie, by(pays)



use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop if v1 == "VA.TAXSUB" | v1 == "OUT"
	generate pays_1 = strlower(substr(v1,1,strpos(v1,"_")-1))
	gen pays = pays_1
	foreach sector of global sector {
		local sector=lower("`sector'")
		replace chn_`sector'=chn_`sector'+cn1_`sector'+cn2_`sector'+cn3_`sector'+cn4_`sector'
		replace mex_`sector'=mex_`sector'+mx1_`sector'+mx2_`sector'+mx3_`sector'
	}
	drop cn* mx*
	replace pays = "chn" if pays_1=="ch1" | pays_1=="ch2" | pays_1=="ch3" | pays_1=="ch4" 
	replace pays = "mex" if pays_1=="mx1" | pays_1=="mx2" | pays_1=="mx3"
	collapse (sum) $var_entree_sortie, by(pays)

}

if "`source'"=="WIOD" {
	 
	drop *57 *58 *59 *60 *61
	rename Country pays
	 
}

keep pays $var_entree_sortie




foreach var of varlist $var_entree_sortie {
*	On cherche à enlever les auto-consommations intermédiaires
	if "`source'" == "TIVA" local pays_colonne = substr("`var'",1,3)
	if "`source'" == "WIOD" local pays_colonne = substr("`var'",2,3)
	replace `var' = 0 if pays=="`pays_colonne'"
	local pays_colonne = upper("`pays_colonne'")
	
	if "`hze'"=="hze_yes" & strpos("$eurozone","`pays_colonne'")!=0 {
		*display "turf"
	
	*Et les internes dans la zone euro
		foreach i of global eurozone {	
			replace `var' = 0 if pays == lower("`i'")
		}
	}
}



collapse (sum) $var_entree_sortie
display "after collapse"


xpose, clear varname



if "`source'" == "TIVA" ///
		generate pays = substr(_varname,1,3)
if "`source'" == "WIOD" ///
		generate pays = substr(_varname,2,3)
		
drop _varname
collapse (sum) v1, by (pays)


rename v1 imp_inputs

save "$dir/Bases/imp_inputs_`vector'_`source'_`yrs'_`hze'.dta", replace

use "$dir/Bases/`vector'_`source'.dta"

replace pays=lower(pays)

keep if year==`yrs'
if "`vector'"=="HC" local var_interet = "conso"
if "`vector'"=="X" local var_interet = "export"
collapse (sum) `var_interet', by(pays)

merge 1:1 pays using "$dir/Bases/imp_inputs_`vector'_`source'_`yrs'_`hze'.dta" 


gen pays_1 = pays
replace pays = "chn" if pays_1=="cn1" | pays_1=="cn2" | pays_1=="cn3" | pays_1=="cn4" 
replace pays = "mex" if pays_1=="mx1" | pays_1=="mx2" | pays_1=="mx3"
collapse (sum) `var_interet' imp_inputs, by(pays)


gen input_`var_interet'=(imp_inputs/Yt)*`var_interet'

*gen input_`var_interet'=imp_inputs/`var_interet'


*keep pays input_`var_interet'

*Pondération des inputs importés par 




save "$dir/Bases/imp_inputs_`vector'_`source'_`yrs'_`hze'.dta", replace

end

********************************************************************************************

//graphiques avec 
//   - impact choc euro / part des importations en provenance de pays hors zone euro
//   - impact chocs pays / 

foreach source in TIVA WIOD {

	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	
	Definition_pays_secteur `source'



	foreach i of numlist `start_year' (1)`end_year'  {
		//clear
		imp_inputs `i' `source' HC hze_not
		imp_inputs `i' `source' HC hze_yes
		imp_inputs `i' `source' X hze_yes
	
		clear
	}



}

