
clear

if ("`c(username)'"=="guillaumedaudin") global dir "~/Dropbox/commerce en VA"

if ("`c(username)'"=="L841580") global dir "H:/Agents/Cochard/Papier_chocCVA"

cd "$dir"


set matsize 7000

set more off



capture program drop imp_inputs // fournit le total des inputs importés par chaque pays

program imp_inputs

args yrs

use "$dir/Bases/OECD`yrs'.dta"
drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"

generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace `var' = 0 if pays==pays2
	drop pays2
}


drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh

xpose, clear varname

generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)

rename v1 imp_inputs

save "$dir/Bases/imp_inputs_`yrs'.dta", replace

use "$dir/Bases/prod.dta"

replace pays=lower(pays)

keep if year==`yrs'

merge 1:1 pays using "$dir/Bases/imp_inputs_`yrs'.dta" 

drop _merge

gen input_prod=imp_inputs/prod

keep pays input_prod

save "$dir/Bases/imp_inputs_`yrs'.dta", replace

end

*************************

capture program drop imp_inputs_hze // fournit le total des inputs importés de pays hors ze par chaque pays

program imp_inputs_hze

args yrs


use "$dir/Bases/OECD`yrs'.dta"
drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"
generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

local eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace `var' = 0 if pays==pays2
	replace pays=upper(pays)
	foreach i of local eurozone{
		replace `var' = 0 if pays == "`i'"
		}
	drop pays2
	replace pays=lower(pays)
}


drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh

xpose, clear varname

generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)

rename v1 imp_inputs

save "$dir/Bases/imp_inputs_hze_`yrs'.dta", replace

use "$dir/Bases/prod.dta"

replace pays=lower(pays)

keep if year==`yrs'

merge 1:1 pays using "$dir/Bases/imp_inputs_hze_`yrs'.dta" 

drop _merge

gen input_prod=imp_inputs/prod

keep pays input_prod

save "$dir/Bases/imp_inputs_hze_`yrs'.dta", replace


end

********************

capture program drop loc_inputs // fournit le total des inputs importés par chaque pays
program loc_inputs
args yrs

use "$dir/Bases/OECD`yrs'.dta"
drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"

generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace pays2=lower(pays2)
	replace `var' = 0 if pays!=pays2
	drop pays2
}

drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh
xpose, clear varname
generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)
rename v1 loc_inputs

save "$dir/Bases/loc_inputs_`yrs'.dta", replace

clear
use "$dir/Bases/prod.dta"
keep if year==`yrs'
replace pays=lower(pays)
drop year

merge 1:1 pays using "$dir/Bases/loc_inputs_`yrs'.dta"  //,keep(3)
drop _merge
replace loc_inputs=loc_inputs/prod
drop prod
save "$dir/Bases/loc_inputs_`yrs'.dta", replace

end

************
/////////////////////////////////////////////////////////
capture program drop imp_inputsX // fournit le total des inputs importés par chaque pays
program imp_inputsX
args yrs

use "$dir/Bases/OECD`yrs'.dta"
drop arg_consabr-disc
drop if v1 == "VA.TAXSUB" | v1 == "OUT"

generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))

foreach var of varlist arg_c01t05agr-zaf_c95pvh {
	generate pays2 = substr("`var'",1,strpos("`var'","_")-1)
	replace pays2=lower(pays2)
	replace `var' = 0 if pays==pays2
	drop pays2
}

drop v1
collapse (sum) arg_c01t05agr-zaf_c95pvh
xpose, clear varname
generate pays = strlower(substr(_varname,1,strpos(_varname,"_")-1))
drop _varname
collapse (sum) v1, by (pays)
rename v1 imp_inputs

save "$dir/Bases/imp_inputsX_`yrs'.dta", replace

clear
use "$dir/Bases/exports.dta"
keep if year==`yrs'
replace pays=lower(pays)
drop year

merge 1:1 pays using "$dir/Bases/imp_inputsX_`yrs'.dta"  //,keep(3)
drop _merge
replace imp_inputs=imp_inputs/X
drop X
save "$dir/Bases/imp_inputsX_`yrs'.dta", replace

end



//graphiques avec 
//   - impact choc euro / part des importations en provenance de pays hors zone euro
//   - impact chocs pays / 

foreach i of numlist 1995 2000 2005 2008 2009 2010 2011 {
	//clear
	//imp_inputs `i'
	clear
	imp_inputs_hze `i'
}





imp_inputsX  2011
loc_inputs 2011

