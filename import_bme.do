*AL, reprise HC
*01/2019
*Importer les données de BMEs cxd/ert
********************************************************************

capture program drop essai

program essai
 * *
args type2 yrs2

clear


if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv269a") global dir  "D:\home\T822289\CommerceVA\rédaction\Rédaction 2019" 
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"



*choc de 1% CXD

if "`type2'_`yrs2'" == "CXD_2019" {
	import excel using D:\home\T822289\CommerceVA\Bases_Sources\BMEs\Direct_Impact-CXD-02_Jan_2019.xlsx, sheet("CTRY") cellrange(C9:N30) firstrow clear
	rename C pays 
	rename K BME_1
	rename L BME_gr_2
	rename M BME_gr_3
	rename N BME_gr_4
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100
	generate BME_4 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))*(1+(BME_gr_4/100))-1)*100
	drop D E F G H I J  
	drop BME_gr_2
	drop BME_gr_3
	drop BME_gr_4
	drop if BME_1 ==.
}
if "`type2'_`yrs2'" == "CXD_2018" {
	import excel using D:\home\T822289\CommerceVA\Bases_Sources\BMEs\Direct_Impact-CXD-03_Jan_2018.xlsx, sheet("CTRY") cellrange(C9:N30) firstrow clear
	rename C pays 
	rename K BME_1
	rename L BME_gr_2
	rename M BME_gr_3
	rename N BME_gr_4
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100
	generate BME_4 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))*(1+(BME_gr_4/100))-1)*100
	drop D E F G H I J  
	drop BME_gr_2
	drop BME_gr_3
	drop BME_gr_4
	drop if BME_1 ==.
*choc de 10% sur le change
}

if  "`type2'_`yrs2'" == "ERT_2019" {
	import excel using D:\home\T822289\CommerceVA\Bases_Sources\BMEs\Direct_Impact-ERT-02_Jan_2019.xlsx, sheet("CTRY") cellrange(C9:N30) firstrow clear
	rename C pays 
	rename K BME_1
	rename L BME_gr_2
	rename M BME_gr_3
	rename N BME_gr_4
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100
	generate BME_4 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))*(1+(BME_gr_4/100))-1)*100
	drop D E F G H I J  
	drop BME_gr_2
	drop BME_gr_3
	drop BME_gr_4
	drop if BME_1 ==.

}
if "`type2'_`yrs2'" == "ERT_2018" {
	import excel using D:\home\T822289\CommerceVA\Bases_Sources\BMEs\Direct_Impact-ERT-03_Jan_2018.xlsx, sheet("CTRY") cellrange(C9:N30) firstrow clear
	rename C pays 
	rename K BME_1
	rename L BME_gr_2
	rename M BME_gr_3
	rename N BME_gr_4
	generate BME_3 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))-1)*100
	generate BME_4 = ((1+(BME_1/100))*(1+(BME_gr_2/100))*(1+(BME_gr_3/100))*(1+(BME_gr_4/100))-1)*100
	drop D E F G H I J  
	drop BME_gr_2
	drop BME_gr_3
	drop BME_gr_4
	drop if BME_1 ==.
}
/*
*Attention !!! choc de 5% sur le change ==> plus très pertinent pour comparaison
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
*/ 

*save "\\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_`yrs'.dta", replace
 *save "D:\home\T822289\CommerceVA\rédaction\Rédaction 2019\BME_`type'_`yrs'.dta", replace
 
 generate year="`yrs2'"
 generate type="`type2'"
 
end


local num_fich=0
foreach type in ERT CXD  {
	foreach yrs of numlist 2018 2019 {
		essai "`type'" "`yrs'"
		local num_fich=`num_fich'+1
		if `num_fich' !=1 append using "D:\home\T822289\CommerceVA\rédaction\Rédaction 2019\BME.dta"
		save "D:\home\T822289\CommerceVA\rédaction\Rédaction 2019\BME.dta", replace
	}
}


rename pays c_full_EN

*Table de correspondance pays BMEs/WIOD
merge m:m c_full_EN using "D:\home\T822289\CommerceVA\Bases\pays_FR.dta"

keep if _merge == 3
drop _merge

/*obsolète
replace BME = -0.2*BME
   /* le choc BME est un choc de 5%. 
      20 fois le choc BME pour avoir le choc de 100% du modèle WIOD
	  0.2 = 20/100 pour correspondre au format d'affichage de la source WIOD*/
   
  */ 
label variable BME_1 "BME pour le même choc que le modèle I-O - 1ere année"
label variable BME_3 "BME pour le même choc que le modèle I-O - 3e année"

drop c_full_EN

drop c_full_FR
save "D:\home\T822289\CommerceVA\rédaction\Rédaction 2019\BME.dta", replace
