capture program drop essai

program essai

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

}
if  "`yrs'" == "2016" {
import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2016\Direct_Impact-EEN-08_Jan_2016.xlsx, sheet("Overview") cellrange(B12:D33) firstrow clear
drop C
rename B pays 
rename D BME
generate year = 2016
}	
if  "`yrs'" == "2015" {
import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2015\Direct_Impact-EEN-19_Jan_2015.xlsx, sheet("Overview") cellrange(B12:D33) firstrow clear
drop C
rename B pays 
rename D BME
generate year = 2015
}	

if  "`yrs'" == "2013" {
import excel using \\intra\partages\au_dcpm\DiagConj\BMEs\BME_2013\Direct_Impact-EEN-20_Sep_2013.xlsx, sheet("Overview") cellrange(B12:D33) firstrow clear
drop C
rename B pays 
rename D BME
generate year = 2013
}	


*save \\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflation\BME_`yrs'.dta

end

essai 2013
