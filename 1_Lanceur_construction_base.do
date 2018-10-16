***Ce lanceur prend 10 mn pour faire tourner les programmes****

clear



if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"



capture log using "$dir/Temporaire/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off


cd $dir 
do GIT/commerce_va_inflation/1_constr_bases.do


******Définition des Pays et des secteurs ********************

do GIT/commerce_va_inflation/Definition_pays_secteur.do   


**** Lancement des programmes ****************


*/
/*
foreach i of numlist 1995(1)2011 {
	clear
	save_data `i' TIVA
	prepare_database `i' TIVA
}




foreach i of numlist 2000(1)2014 {
	clear
	save_data `i' WIOD
	prepare_database `i' WIOD
}

*/

*/

database_csv TIVA
database_csv WIOD

set more off



*append_y TIVA


*append_X TIVA





*append_y WIOD


*append_X WIOD



log close


