clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
capture log using "$dir/$S_DATE.log", replace
set more off






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

	
local nbr_sect=wordcount("$sector")






***************************************************************************************************
*Création des tables  de X

***************************************************************************************************

capture program drop compute_X
program compute_X
	args source yrs

	
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear



if "`source'"=="WIOD" {
egen utilisations = rowtotal(vAUS01-vUSA61)
gen utilisations_dom = .
gen pays = substr("`i'",1,3)

	foreach j of global country {
		local i = "`j'"
		egen blouk = rowtotal(*`i'*)
		display "`i'" "`j'"
		replace utilisations_dom = blouk if Country=="`j'"
*		codebook utilisations_dom if Country=="`j'"
		drop blouk
		
	}
}

if "`source'"=="TIVA" {
drop if v1=="VA+TAXSUB" | v1=="OUT"
egen utilisations = rowtotal(arg_c01t05agr-nps_zaf)
gen utilisations_dom = .
* liste de countrys

gen Country = substr("v1",1,3)
 
	foreach j of global country {
		local i = lower("`j'")
		if  ("`j'"=="cn1" | "`j'"=="cn2" |"`j'"=="cn3"|"`j'"=="cn4" ) local i = "chn" 

		if  ("`j'"=="mx1" | "`j'"=="mx2"| "`j'"=="mx3") local i = "mex"
		
		egen blouk = rowtotal(*`i'*)
		display "`i'" "`j'"
		replace utilisations_dom = blouk if strpos(v1,"`j'")!=0
*		codebook utilisations_dom if 	strpos(v1,"`j'")!=0
		drop blouk
	}

}
generate X = utilisations - utilisations_dom
	
replace Country = strupper(Country)
generate year = `yrs'



if "`source'"=="TIVA" {
	generate pays = strlower(substr(v1,1,3))
	generate sector = strlower(substr(v1,strpos(v1,"_")+1,.))
}


if "`source'"=="WIOD" {
	replace pays =lower(Country)
	rename IndustryCode sector
}

keep pays sector  year X

display "fin compute_X"	
	
end




capture program drop append_X
program append_X
args source
*We create a .dta that includes all vectors of HFCE of all years
if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="WIOD" local first_yr 2000
foreach y of numlist `yr_list' { 
	compute_X `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/X_`source'.dta" 
	}
	save "$dir/Bases/X_`source'.dta", replace
}	
sort year , stable
save "$dir/Bases/X_`source'.dta", replace
 
end



Definition_pays_secteur TIVA
append_X TIVA
Definition_pays_secteur WIOD
append_X WIOD


