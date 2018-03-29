capture program drop essai

program essai
 * *
args yrs

clear


if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

*local year = `yrs'-1
if "`yrs'" == "2017" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2017\Direct_Impact-EEN-11_Oct_2016.xlsx, sheet("CTRY") cellrange(C9:I30) firstrow clear
	rename C pays 
	rename I BME
	drop D E F G H  
	generate year = 2017
	drop if BME ==.

}
if  "`yrs'" == "2016" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2016\Direct_Impact-EEN-08_Jan_2016.xlsx, sheet("Overview") cellrange(B12:D33) firstrow clear
	drop C
	rename B pays 
	rename D BME
	generate year = 2016
	drop if BME ==.
}	
if  "`yrs'" == "2015" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2015\Direct_Impact-EEN-19_Jan_2015.xlsx, sheet("Overview") cellrange(B12:D33) firstrow clear
	drop C
	rename B pays 
	rename D BME
	generate year = 2015
	drop if BME ==.
}	

if  "`yrs'" == "2013" {
	import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2013\Direct_Impact-EEN-20_Sep_2013.xlsx, sheet("Overview") cellrange(B12:D33) firstrow clear
	drop C
	rename B pays 
	rename D BME
	generate year = 2013
	drop if BME ==.
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
label variable BME "BME pour le même choc que le modèle I-O"

drop c_full_EN
blif
drop c_full_FR
save \\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA\BME.dta, replace
