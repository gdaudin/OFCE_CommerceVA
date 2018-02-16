* à partir des outputs de Etude D+I bouclage mondial, on effectue des régressions secteur par secteur  
clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


	
*définition des secteurs d'intérêt (certains ont des résultats nuls pour prix de conso et sont donc retirés)

 *regression secteur par secteur
foreach source in TIVA  WIOD { 

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'

global sec  = strlower("$sector")
 
foreach i in $sec {
 *foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
 foreach year in 2010 {
   use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_par_sect.dta", clear
   *effet direct repondéré par le choc: le choc correspond à une appréciation de 100% 
*=>on double l'impact pour comparer le ratio de CI importées (comptable, sans doubler) à l'effet direct choqué (effet d'un doublement des prix de CI)
gen choc_dplusi_par_sect=ratio_ci_impt_par_sect/2

keep c sector pays ratio_ci_impt_par_sect  pond_`source'_par_sect choc_dplusi_par_sect

keep if sector=="`i'"


reg pond_`source'_par_sect choc_dplusi_par_sect   
gen R2=e(r2)

matrix COEF = e(b)
gen cst=COEF[1,2]
gen b=COEF[1,1]
gen year=`year'
gen source="`source'"
predict predict
valuesof pays if abs(ln(predict/pond_`source'_par_sect)) > 0.35
gen predict_hors_0_0_35 = "`r(values)'"
valuesof pays if choc_dplusi_par_sect >= pond_`source'_par_sect
gen D_I_trop_grand = "`r(values)'"
corr pond_WIOD_par_sect choc_dplusi_par_sect
gen corr = r(rho)

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`i'.dta", replace 
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta"
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta", replace
}
}
}

foreach source in WIOD TIVA { 
 *création d'une base de données avec le résultat des régressions sur tous les secteurs  
  *foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
 foreach year in 2010 {
 capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta"
 foreach i in  $sec {
 use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`i'.dta", clear
 keep c b sector  ratio_ci_impt_par_sect  pond_WIOD_par_sect R2 cst year source
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta"
sort  b sector
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta", replace
 }
   }
   }
