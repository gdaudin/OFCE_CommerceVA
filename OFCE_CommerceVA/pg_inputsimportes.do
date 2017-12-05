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

capture program drop imp_inputs_par_sect // fournit le % dd ci importées/prod par pays*sect
program imp_inputs_par_sect
args yrs source hze


* exemple  hze_not ou hze_yes

*Ouverture de la base contenant le vecteur ligne de production par pays et secteurs

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop if v1 == "VA.TAXSUB" | v1 == "OUT"
	generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
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


append using "$dir/Bases/`source'_`yrs'_OUT.dta"

xpose, clear varname
rename v1 ci_impt
rename v2 prod
generate ratio_ci_impt_prod=ci_impt / prod

if "`source'"=="TIVA" {
	generate pays = strlower(substr(_varname,1,3))
	generate sector = strlower(substr(_varname,strpos(_varname,"_")+1,.))
}


if "`source'"=="WIOD" {
	merge 1:1 _n using "$dir/Bases/csv_WIOD.dta"
	rename c pays
	rename s sector
	replace pays=lower(pays)
	drop p_shock
	drop _merge
 
}
save "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", replace


end










**************************************







capture program drop imp_inputs // fournit le total des inputs importés par chaque pays
program imp_inputs
args yrs source vector hze

* exemple vector X Y HC hze_not ou hze_yes



if "`vector'" == "Y" { 
	use "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", clear

	if "`source'"=="TIVA" {
		gen pays_1 = pays
		replace pays = "chn" if pays_1=="cn1" | pays_1=="cn2" | pays_1=="cn3" | pays_1=="cn4" 
		replace pays = "mex" if pays_1=="mx1" | pays_1=="mx2" | pays_1=="mx3"
		collapse (sum) ci_impt prod, by(pays sector)

	}
	
	collapse (sum) ci_impt prod, by(pays)
	generate ratio_ci_impt_Y = ci_impt/prod
	save "$dir/Bases/imp_inputs_Y_`yrs'_`source'_`hze'.dta", replace
}


if "`vector'" == "HC"  { 

	
	if "`source'"=="TIVA" {
		use  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta", replace
		gen pays_1 = pays
		replace pays = "chn" if pays_1=="cn1" | pays_1=="cn2" | pays_1=="cn3" | pays_1=="cn4" 
		replace pays = "mex" if pays_1=="mx1" | pays_1=="mx2" | pays_1=="mx3"
		collapse (sum) ci_impt prod, by(pays sector)
		generate ratio_ci_impt_prod=ci_impt / prod
		save "$dir/Bases/imp_inputs_par_sect_modif.dta", replace
	}
	

	use "$dir/Bases/HC_`source'.dta", clear
	if "`source'"=="TIVA" {
		replace pays = "chn" if pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4" 
		replace pays = "mex" if pays=="mx1" | pays=="mx2" | pays=="mx3"
		collapse (sum) conso, by(pays pays_conso year sector)
	}
	
	keep if lower(pays)==lower(pays_conso) 
	keep if year==`yrs'
	
	if "`source'"=="WIOD" merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta"
	if "`source'"=="TIVA" merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_modif.dta"
	if "`source'"=="TIVA" erase  "$dir/Bases/imp_inputs_par_sect_modif.dta"
	drop _merge
	
	gen ci_impt_HC = ratio_ci_impt_prod * conso
	
	collapse (sum) ci_impt_HC conso, by(pays)
	generate ratio_ci_impt_HC = ci_impt_HC/conso
	save "$dir/Bases/imp_inputs_HC_`yrs'_`source'_`hze'.dta", replace
}

if "`vector'" == "X"  { 
	
	use "$dir/Bases/X_`source'.dta", clear
 
	keep if year==`yrs'
	
	merge 1:1 pays sector using  "$dir/Bases/imp_inputs_par_sect_`yrs'_`source'_`hze'.dta"
	
	blif
	drop _merge
	
	gen ci_impt_X = ratio_ci_impt_prod * X
	
	if "`source'"=="TIVA" {
		replace pays = "chn" if pays=="cn1" | pays=="cn2" | pays=="cn3" | pays=="cn4" 
		replace pays = "mex" if pays=="mx1" | pays=="mx2" | pays=="mx3"

	}
	
	collapse (sum) ci_impt_X X, by(pays)
	generate ratio_ci_impt_X = ci_impt_X/X
	save "$dir/Bases/imp_inputs_X_`yrs'_`source'_`hze'.dta", replace
}

end

********************************************************************************************

//graphiques avec 
//   - impact choc euro / part des importations en provenance de pays hors zone euro
//   - impact chocs pays / 



**pOUR TEST

Definition_pays_secteur WIOD
imp_inputs_par_sect 2011 WIOD hze_not

imp_inputs 2011 WIOD X hze_not



blif


foreach source in TIVA WIOD {

Definition_pays_secteur `source'

	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	




	foreach i of numlist `start_year' (1)`end_year'  {
		//clear
		imp_inputs `i' `source' HC hze_not
		imp_inputs `i' `source' HC hze_yes
		imp_inputs `i' `source' X hze_yes
	
		clear
	}



}

