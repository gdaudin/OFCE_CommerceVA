clear
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/OFCE Commerce VA/2017 Bdf"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
capture log using "$dir/$S_DATE $S_TIME.log", replace
set more off
***************************************************************************************************
*Création des tables  de consommation finale des ménages (HFCE) : on crée le vecteur 1*67 des hfce de chaque pays

***************************************************************************************************
*Creation of the vector of households final consumption H
capture program drop compute_H
program compute_H
	args source yrs

	
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear

if "`source'"=="TIVA" {
	global country2 "arg aus aut bel bgr bra brn can che chl"
	global country2 "$country2  chn chndom chnnpr chnpro col cri cyp cze deu dnk esp est fin"
	global country2 "$country2  fra gbr grc hkg hrv hun idn ind irl isl ita jpn khm kor"
	global country2 "$country2  ltu lux lva mex mexgmf mexngm mlt mys nld nor nzl phl pol prt"
	global country2 "$country2  rou row rus sau sgp svk svn swe tha tun tur twn usa vnm zaf"	
}
				
				
if "`source'"=="WIOD" {
	global country2 "aus aut bel bgr bra can che" 
	global country2 "$country2 chn cyp cze deu dnk esp est fin"
	global country2 "$country2 fra gbr grc hrv hum idn ind irl isl ita jpn kor"
	global country2 "$country2 ltu lux lva mex mlt nld nor pol prt"
	global country2 "$country2 rou row rus svk svn swe tur twn usa"
	
}


	
generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
drop if pays==""
