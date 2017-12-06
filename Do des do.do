clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"



if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(username)'"=="w817186") global dirgit "X:\Agents\FAUBERT\commerce_VA_inflation\"
if ("`c(username)'"=="n818881") global dirgit "X:\Agents\LALLIARD\commerce_VA_inflation\"


capture log using "$dir/$S_DATE.log", replace
set more off


do "1_constr_bases.do"
do "compute_HC.do"
do "compute_X.do"
do "contenu_imp_HC.do"

do "choc_chge.do"
do "pg_inputsimportes.do"

do "Pour graphiques HC.do"
do "Pour graphiques articles OFCE.do"
*do "Pour graphiques change.do"
