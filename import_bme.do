capture program drop essai

program essai
 * *
args yrs

clear


if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

*local year = `yrs'-1
if "`yrs'" == "2017" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2017\Direct_Impact-EEN-11_Oct_2016.xlsx, sheet("CTRY") cellrange(C9:K30) firstrow clear
	rename C pays 
	rename I BME_1
	rename J BME_gr_2
	rename K BME_gr_3
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100
	drop D E F G H   
	drop BME_gr_2
	drop BME_gr_3
	generate year = 2017
	drop if BME_1 ==.

}
if  "`yrs'" == "2016" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2016\Direct_Impact-EEN-08_Jan_2016.xlsx, sheet("Overview") cellrange(B12:F33) firstrow clear
	drop C 
	rename B pays 
	rename D BME_1
	rename E BME_gr_2
	rename F BME_gr_3
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100

	generate year = 2016
	drop BME_gr_2
	drop BME_gr_3
	drop if BME_1 ==.
}	
if  "`yrs'" == "2015" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2015\Direct_Impact-EEN-19_Jan_2015.xlsx, sheet("Overview") cellrange(B12:F33) firstrow clear
	drop C 
	rename B pays 
	rename D BME_1
	rename E BME_gr_2
	rename F BME_gr_3
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100

	generate year = 2015
	drop BME_gr_2
	drop BME_gr_3
	drop if BME_1 ==.
}	

if  "`yrs'" == "2013" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2013\Direct_Impact-EEN-20_Sep_2013.xlsx, sheet("Overview") cellrange(B12:F33) firstrow clear
	drop C 
	rename B pays 
	rename D BME_1
	rename E BME_gr_2
	rename F BME_gr_3
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100

	generate year = 2013
	drop BME_gr_2
	drop BME_gr_3
	drop if BME_1 ==.
}	
 

save "\\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_`yrs'.dta", replace
 
 
end

foreach yrs of numlist 2013 2015 2016 2017 {
essai "`yrs'"

}

use \\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_2017.dta, clear

foreach yrs of numlist 2013 2015 2016 {
append using \\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_`yrs'.dta
	erase \\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_`yrs'.dta
}
	erase \\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_2017.dta
sort year , stable

rename pays c_full_EN

merge m:m c_full_EN using "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA\Bases\pays_FR.dta"

keep if _merge == 3
 
drop _merge

/*replace BME = -0.2*BME
   /* le choc BME est un choc de 5%. 
      20 fois le choc BME pour avoir le choc de 100% du modèle WIOD
	  0.2 = 20/100 pour correspondre au format d'affichage de la source WIOD*/
   
  */ 
label variable BME_1 "BME pour le même choc que le modèle I-O - 1ere année"
label variable BME_3 "BME pour le même choc que le modèle I-O - 3e année"

drop c_full_EN

drop c_full_FR
save \\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA\BME.dta, replace
