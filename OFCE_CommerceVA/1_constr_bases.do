clear



if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"




capture log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off


*-------------------------------------------------------------------------------
* SAVE DATABASE FOR EACH YEAR
*-------------------------------------------------------------------------------
capture program drop save_data
program save_data
args source
*ex: save_data TIVA


clear

if "`source'"=="TIVA" {

	*Loop to save data for each year
	set more off
	foreach i of numlist 1995 (1) 2011 {
	insheet using "$dir/Bases_Sources/TIVA/ICIO2016_`i'.csv", clear
	*I sort the ICIO: 
	sort v1 aus_c01t05agr-disc
	order aus_c01t05agr-cn4_c95pvh, alphabetic after (v1)
	*order aus_hc-row_consabr, alphabetic after (zaf_c95pvh)
	order hfce_aus-disc, alphabetic after (zaf_c95pvh)
	
	save "$dir/Bases/TIVA_ICIO_`i'.dta", replace
	}
/*
	*Same with the database for wages
	clear
	set more off
	local tab "WAGE OUT"
	foreach n of local tab{
		foreach i of numlist 1995 2000 2005 {
		clear
		import excel "$dir/Bases/ICIO/WAGE_`i'.xlsx", sheet("`n'") firstrow
		keep A-VNM
		drop if A == ""
		save "$dir/Bases/`n'_`i'.dta", replace
		}

	}

	*/	
}



if "`source'"=="WIOD" {	 
	*Loop to save data for each year
	set more off
	foreach i of numlist 2000 (1) 2014 {
	use "$dir/Bases_Sources/`source'/WIOT`i'_October16_ROW.dta", clear
	foreach j of numlist 1 (1) 9 {
		rename ????`j' ????0`j'
	}
	order vAUS01-vROW61, alphabetic after (TOT)
	save "$dir/Bases/WIOD_ICIO_`i'.dta", replace
	}

	/*
	*Same with the database for wages
	clear
	set more off
	local tab "WAGE OUT"
	foreach n of local tab{
		foreach i of numlist 1995 2000 2005 {
		clear
		import excel "$dir/Bases/ICIO/WAGE_`i'.xlsx", sheet("`n'") firstrow
		keep A-VNM
		drop if A == ""
		save "$dir/Bases/`n'_`i'.dta", replace
		}
	}
	
	*/

}


end

*-------------------------------------------------------------------------------
*TRIMMING THE DATABASE ICIO
*-------------------------------------------------------------------------------
capture program drop prepare_database
program prepare_database
	args yrs source


if "`source'"=="TIVA" {	
		
	*From the ICIO database I keep only the output vector
	use "$dir/Bases/TIVA_ICIO_`yrs'.dta"
	keep if v1 == "OUT"
	drop v1
	drop dirp_arg-nps_zaf
	save "$dir/Bases/TIVA_`yrs'_OUT.dta", replace
	
	*From the ICIO database I keep only the table for inter-industry inter-country trade
	clear
	use "$dir/Bases/TIVA_ICIO_`yrs'.dta"
	drop dirp_arg-nps_zaf
	drop if v1 == "VA+TAXSUB" | v1 == "OUT"
	drop v1
	save "$dir/Bases/TIVA_`yrs'_Z.dta", replace
	   
	*From the ICIO database I keep only the table for final demand
	clear
	use "$dir/Bases/TIVA_ICIO_`yrs'.dta"
	drop if v1 == "VA+TAXSUB" | v1 == "OUT"
	keep dirp_arg-nps_zaf
	save "$dir/Bases/`source’_`year’_finaldemand.dta", replace
}

if "`source'"=="WIOD" {	

*Output vector
	use "$dir/Bases/WIOD_ICIO_`yrs'.dta"
	keep if IndustryCode == "GO"
	drop IndustryCode-TOT
	drop *57 *58 *59 *60 *61
	save "$dir/Bases/WIOD_`yrs'_OUT.dta", replace
	
* Only the I/O table itself
	clear
	use "$dir/Bases/WIOD_ICIO_`yrs'.dta"
	drop if RNr >=65
	drop IndustryCode-TOT
	drop *57 *58 *59 *60 *61
	save "$dir/Bases/WIOD_`yrs'_Z.dta", replace
	
*Only final demand
	*** Je laisse tomber car c'est compliqué et pas sûr que cela soit utile

	
}

end



*-------------------------------------------------------------------------------
*TRIMMING THE DATABASE FOR WAGES
*-------------------------------------------------------------------------------

**Pas mis à jour : nous n'avons pas les salaire WIOD et nous ne trouvons pas les salaire TIVA
capture program drop base_wage
program base_wage
	args yrs n
*yrs = years, n = onglet WAGE or OUT
	clear
	use "$dir/Bases/`n'_`yrs'.dta"

*List of countries for which there is no data available for wages
	global restcountry "ISL BRN COL CRI HKG HRV KHM MEX_GMF MEX_NGM MYS PHL ROW SAU SGP THA TUN "
	global chncountry "CHN_DOM CHN_NPR CHN_PRO"

if "`source'"=="TIVA" {
	global country "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country "$country  CHN CN1 CN2 CN3 CN4 COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country "$country  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country "$country  LTU LUX LVA MAR MEX MLT MX1 MX2 MX3 MYS NLD NOR NZL PER PHL POL PRT"
	global country "$country  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
	
	global sector "C01T05 C10T14 C15T16 C17T19 C20 C21T22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37 C40T41 C45"
	global sector "$sector C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"
	
}
				
				
if "`source'"=="WIOD" {
	global country "   AUS AUT BEL BGR BRA     CAN CHE" 
	global country "$country CHN                             CYP CZE DEU DNK ESP EST FIN"
	global country "$country FRA GBR GRC     HRV HUN IDN IND IRL       ITA JPN     KOR"
	global country "$country LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
	global country "$country ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	
	
	global sector "A01 A02 A03 B C10-C12 C13-C15 C16 C17 C18 C19 C20 C21 C22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C31_C32 C33 C35 E35 E36 E37-E39"
	global sector "$sector F G45 G46 G47 H49 H50 H51 H52 H53 I J58 J59_J60"
	global sector "$sector J61 J62_J63 K64 K65 K66 L68 M69_M70 M71 M72 M73"
	global sector "$sector M74_M75 N O84 O85 Q R_S T U"
}


	foreach i of global chncountry {
			gen `i'=CHN
									}

	
	foreach i of global restcountry {
			gen `i'=0
									}
									
	order AUS-TUN, alphabetic after (A)

*We reshape the database as a column-vector with a variable WAGE for wages and OUT for output

	foreach i of global country {
			rename `i' country_`i'
	}	

	reshape long country_, i(A) j(country) string
	
	sort country  in 1/2278, stable
	rename country_ `n'
	
*We delete observations for CHN and MEX that do not exist in the ICIO

	foreach i of global sector2 {
	drop if (country=="CHN" & A=="`i'")
	}


	foreach i of global sector3 {
		foreach j in CHN_DOM CHN_NPR CHN_PRO {
			drop if (country=="`j'" & A=="`i'")
		}
	}
	drop if (country=="CHN_PRO" & A=="C01T05")

	*MEXICO 
  
	foreach i of global sector4 { 
	drop if (country == "MEX" & A == "`i'") 
	} 

 
	foreach i of global sector5 { 
		foreach j in MEX_GMF MEX_NGM { 
			drop if (country == "`j'" & A == "`i'") 
		} 
	} 
	
save "$dir/Bases/`n'_`yrs'.dta", replace
	
end


*----------------------------------------------------------------------------------
*BUILDING A DATABASE WITH VECTORS OF COUNTRIES AND SECTORS AND VECTOR CONTAINING 0
*----------------------------------------------------------------------------------
capture program drop database_csv
program database_csv
args source

*Exemple : database_csv TIVA

clear
set more off
if "`source'"=="TIVA" {
	global country "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country "$country  CHN CN1 CN2 CN3 CN4 COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country "$country  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country "$country  LTU LUX LVA MAR MEX MLT MX1 MX2 MX3 MYS NLD NOR NZL PER PHL POL PRT"
	global country "$country  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
	
	global sector "C01T05 C10T14 C15T16 C17T19 C20 C21T22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37 C40T41 C45"
	global sector "$sector C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"
	
}
				
				
if "`source'"=="WIOD" {
	global country "   AUS AUT BEL BGR BRA     CAN CHE" 
	global country "$country CHN                             CYP CZE DEU DNK ESP EST FIN"
	global country "$country FRA GBR GRC     HRV HUN IDN IND IRL        ITA JPN     KOR"
	global country "$country LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
	global country "$country ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	
	
	global sector "A01 A02 A03 B C10-C12 C13-C15 C16 C17 C18 C19 C20 C21 C22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C31_C32 C33 C35 E35 E36 E37-E39"
	global sector "$sector F G45 G46 G47 H49 H50 H51 H52 H53 I J58 J59_J60"
	global sector "$sector J61 J62_J63 K64 K65 K66 L68 M69_M70 M71 M72 M73"
	global sector "$sector M74_M75 N O84 O85 Q R_S T U"
}


				
local nbr_sect=wordcount("$sector")	
local nbr_ctry=wordcount("$country")
local nbr_lig= `nbr_ctry'*`nbr_sect'
				
				
generate c = ""
local num_pays 0
foreach i of global country {
	foreach j of numlist 1/`nbr_sect' {
		local new = _N + 1
		set obs `new'
		local ligne = `j' + `nbr_sect'*`num_pays'
		replace c = "`i'" in `ligne'
	}
	local num_pays = `num_pays'+1
}



generate s =""
local num_sector 0
foreach i of global sector {
	forvalues j = 1(`nbr_sect')`nbr_lig' {
		local ligne = `j' + 1*`num_sector'
		replace s = "`i'" in `ligne'
	}
	local num_sector = `num_sector'+1
}

gen v1=0


/*
****This is obsolete in the 2016 version
*I withdraw the industries for different types of CHN and MEX that are not in the dataset from v1


if "`source'"=="TIVA" {



*CHINA
global sector2 "C01T05 C10T14 C15T16 C17T19 C20 C21T22 C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37"

foreach i of global sector2 {
drop if (c == "CHN" & s == "`i'")
}

global sector3 "C40T41 C45 C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"

foreach i of global sector3 {
	foreach j in CHNDOM CHNNPR CHNPRO {
		drop if (c == "`j'" & s == "`i'")
	}
}

drop if (c == "CHNPRO" & s == "C01T05")

*MEXICO
global sector4 "C15T16 C17T19 C20 C21T22 C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37"

foreach i of global sector4 {
drop if (c == "MEX" & s == "`i'")
}


global sector5 "C01T05 C10T14 C40T41 C45 C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"

foreach i of global sector5 {
	foreach j in MEXGMF MEXNGM {
		drop if (c == "`j'" & s == "`i'")
	}
}
}


*/
rename v1 p_shock

save "$dir/Bases/csv_`source'.dta", replace

collapse (sum) p_shock, by(c)

save "$dir/Bases/pays_en_ligne_`source'.dta", replace


end




***************************************************************************************************
* 1- Création des tables Y de production : on crée le vecteur 1*67 des productions totales de chaque pays
***************************************************************************************************

capture program drop compute_y
program compute_y
args source yrs

/*Y vecteur de production*/ 
clear
use "$dir/Bases/`source'_`yrs'_OUT.dta"
*drop arg_consabr-disc
rename * prod*
generate year = `yrs'
reshape long prod, i(year) j(pays_sect) string


blif
if `source'=="TIVA" generate pays = strupper(substr(pays_sect,1,strpos(pays_sect,"_")-1))
if `source'=="WIOD" generate pays = substr(pays_sect,2,3)


collapse (sum) prod, by(pays year)


end 

capture program drop append_y
program append_y
args source

if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="WIOD" local first_yr 2000

foreach y of numlist `yr_list' { 
	compute_y `source' `y'
	if `y'!=`first_yr' {
		append using "$dir/Bases/`source'_prod.dta"
				}
	save "$dir/Bases/`source'_prod.dta", replace
	}
sort year , stable
end

***************************************************************************************************
* 2- Création des tables X d'exportations : on crée le vecteur 1*67 des productions totales de chauqe pays
***************************************************************************************************

*Creation of the vector of export X
capture program drop compute_X
program compute_X
	args source yrs

use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear

if "`source'"=="TIVA" {
	global country2 "arg aus aut bel bgr bra brn can che chl"
	global country2 "$country2  chn cn1 cn2 cn3 cn4 col cri cyp cze deu dnk esp est fin"
	global country2 "$country2  fra gbr grc hkg hrv hun idn ind irl isl isr ita jpn khm kor"
	global country2 "$country2  ltu lux lva mar mex mlt mx1 mx2 mx3 mys nld nor nzl per phl pol prt"
	global country2 "$country2  rou row rus sau sgp svk svn swe tha tun tur twn usa vnm zaf"	
}
				
				
if "`source'"=="WIOD" {
	global country2 "aus aut bel bgr bra can che" 
	global country2 "$country2 chn cyp cze deu dnk esp est fin"
	global country2 "$country2 fra gbr grc hrv hum idn ind irl   ita jpn kor"
	global country2 "$country2 ltu lux lva mex mlt nld nor pol prt"
	global country2 "$country2 rou row rus svk svn swe tur twn usa"
	
}


	
generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
drop if pays==""

if "`source'"=="TIVA"  egen utilisations = rowtotal(arg_c01t05agr-nps_zaf)


gen utilisations_dom = .

foreach j of global country2 {
	local i = "`j'"
	if  ("`j'"=="cn1" | "`j'"=="cn2" |"`j'"=="cn3" |"`j'"=="cn4" ) {
		local i = "cn" 
	}
	if  ("`j'"=="mx1" | "`j'"=="mx2" | "`j'"=="mx3" ) {
			local i = "mx"
	}
	egen blouk = rowtotal(*`i'*)
	display "`i'" "`j'"
	replace utilisations_dom = blouk if pays=="`j'"
	codebook utilisations_dom if pays=="`j'"
	drop blouk


	
	*** cn = cn1 + cn2 + cn3 + cn4
	*** mx = mx1 + mx2 + mx3
}

generate X = utilisations - utilisations_dom
	
replace pays = strupper(pays)
generate year = `yrs'
keep year pays X
collapse (sum) X, by(pays year)

end


capture program drop append_X
program append_X
args source
*We create a .dta that includes all vectors of export of all years



if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="WIOD" local first_yr 2000

foreach y of numlist `yr_list' { 
	compute_X `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/exports_`source'.dta" 
	}
	save "$dir/Bases/exports_`source'.dta", replace
}	

replace pays = "CHNNPR" if pays == "CHN.NPR"
replace pays = "CHNPRO" if pays == "CHN.PRO"
replace pays = "CHNDOM" if pays == "CHN.DOM"
replace pays = "MEXNGM" if pays == "MEX.NGM"
replace pays = "MEXGMF" if pays == "MEX.GMF"
 
sort year , stable
save "$dir/Bases/exports_`source'.dta", replace
 

end


**** Lancement des programmes ****************


save_data WIOD

save_data TIVA


foreach i of numlist 1995(1)2011 {
	clear
	prepare_database `i' TIVA
}





foreach i of numlist 2000(1)2014 {
	clear
	prepare_database `i' WIOD
}



/*
foreach i of numlist 1995 2000 2005 {
	foreach n in WAGE OUT {
		clear
		base_wage  `i'  `n'
		}
}

*/




database_csv TIVA
database_csv WIOD
/*
set more off



append_y TIVA


append_X TIVA
*/




*append_y WIOD

/*
append_X WIOD

*/

log close


