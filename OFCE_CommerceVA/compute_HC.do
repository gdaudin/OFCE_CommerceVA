clear
set trace on
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/OFCE Commerce VA/2017 Bdf"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
capture log using "$dir/$S_DATE $S_TIME.log", replace
set more off
***************************************************************************************************
*Création des tables  de consommation finale des ménages (HFCE) : on crée le vecteur 1*67 des hfce de chaque pays

***************************************************************************************************
*Creation of the vector of households final consumption H
capture program drop compute_HC
program compute_HC
	args source yrs

use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear

*je retire cn1 cn2 cn3 cn4 et mx1 mx2 mx3 car il existe un vecteur colonne national: hfce_chn et hfce_mex
if "`source'"=="TIVA" {
	global country2 "arg aus aut bel bgr bra brn can che chl"
	global country2 "$country2  chn col cri cyp cze deu dnk esp est fin"
	global country2 "$country2  fra gbr grc hkg hrv hun idn ind irl isl isr ita jpn khm kor"
	global country2 "$country2  ltu lux lva mar mex mlt  mys nld nor nzl per phl pol prt"
	global country2 "$country2  rou row rus sau sgp svk svn swe tha tun tur twn usa vnm zaf"	
}			
				
if "`source'"=="WIOD" {
	global country2 "aus aut bel bgr bra can che" 
	global country2 "$country2 chn cyp cze deu dnk esp est fin"
	global country2 "$country2 fra gbr grc hrv hum idn ind irl isl ita jpn kor"
	global country2 "$country2 ltu lux lva mex mlt nld nor pol prt"
	global country2 "$country2 rou row rus svk svn swe tur twn usa"	
}


if "`source'"=="TIVA" {
*v1: pays_secteur

	use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear
	keep v1 hfce*
	reshape long hfce_, i(v1) j(pays_conso) string

	generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
	generate sector = strlower(substr(v1,strpos(v1,"_")+1,.))
	rename hfce_ conso
	generate year = `yrs'
*egen HC = rowtotal(hfce_arg-hfce_zaf)
}


if "`source'"=="WIOD" {
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear

*foreach i of global country2 
*use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear
keep IndustryCode Country Year v*59
reshape long v, i(IndustryCode Country Year) j(pays_conso) string
rename  Country pays
rename  IndustryCode sector 
rename v conso		
rename Year year	

*egen HC = rowtotal(vARG59-vZAF59)


replace pays = strupper(pays)
}
*keep year pays HC
*collapse (sum) HC, by(pays year)
end

capture program drop append_HC
program append_HC
args source
*We create a .dta that includes all vectors of HFCE of all years
if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="WIOD" local first_yr 2000
foreach y of numlist `yr_list' { 
	compute_HC `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/HC_`source'.dta" 
	}
	save "$dir/Bases/HC_`source'.dta", replace
}	
sort year , stable
save "$dir/Bases/HC_`source'.dta", replace
 
end
append_HC TIVA
append_HC WIOD


