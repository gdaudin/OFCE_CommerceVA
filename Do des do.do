clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"



if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/"
if ("`c(username)'"=="w817186") global dirgit "X:\Agents\FAUBERT\commerce_VA_inflation\"
if ("`c(username)'"=="n818881") global dirgit "X:\Agents\LALLIARD\commerce_VA_inflation\"


capture log using "$dir/$S_DATE.log", replace
set more off


do "$dirgit/1_constr_bases.do"
do "$dirgit/compute_HC.do"
do "$dirgit/compute_X.do"
do "$dirgit/contenu_imp_HC.do"

do "$dirgit/choc_chge.do"
do "$dirgit/pg_inputsimportes.do"

do "$dirgit/Pour graphiques HC.do"
do "$dirgit/Pour graphiques articles OFCE.do"
*do "Pour graphiques change.do"
