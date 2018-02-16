clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	

global sec  "a01 a02 a03 b c10-c12 c13-c15 c16 c17 c18 c19 c20 c21 c22 c23 c24 c25 c26 c27 c28 c29 c30 c31_c32 c33 d35 e36 e37-e39 f g45 g46 g47 h49 h50 h51 h52 h53 j58 j59_j60 j61 j62_j63 k64 k65 k66 l68 m69_m70 m71 m72 m73 m74_m75 n o84 p85 q r_s t "

 
 *regression secteur par secteur
 
foreach i in $sec {
 *foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
 foreach year in 2014 {
   use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_par_sect.dta", clear
keep c sector pays ratio_ci_impt_par_sect  pond_WIOD_par_sect
keep if sector=="`i'"
reg pond_WIOD_par_sect ratio_ci_impt_par_sect   
gen R2=e(r2)
matrix COEF = e(b)
gen cst=COEF[1,2]
gen b=COEF[1,1]
gen year=`year'
gen source="WIOD"
predict predict
valuesof pays if abs(ln(predict/pond_WIOD_par_sect)) > 0.35
gen predict_hors_0_0_35 = "`r(values)'"
valuesof pays if ratio_ci_impt_par_sect >= pond_WIOD_par_sect
gen D_I_trop_grand = "`r(values)'"
corr pond_WIOD_par_sect ratio_ci_impt_par_sect
gen corr = r(rho)

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_`i'.dta", replace 
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_reg_sec.dta"
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_reg_sec.dta", replace
}
}


 *création d'une base de données avec tous les secteurs        
 foreach year in 2014 {
 capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_reg_sec.dta"
 foreach i in  $sec {
 use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_`i'.dta", clear
 keep c b sector  ratio_ci_impt_par_sect  pond_WIOD_par_sect R2 cst year source
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_reg_sec.dta"
sort  b sector
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_reg_sec.dta", replace
 }
   }
