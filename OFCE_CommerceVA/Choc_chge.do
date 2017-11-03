*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs à vérifier

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


capture log close
log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off
global test 1
*Mettre test=1 pour sauver les tableaux un par un et test=0 pour ne pas encombrer le DD.

capture program drop Definition_pays_secteur
program Definition_pays_secteur
args source
*Definition_pays_secteur TIVA 

if "`source'"=="TIVA" {
global country "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country "$country  CHN CN1 CN2 CN3 CN4 COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country "$country  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country "$country  LTU LUX LVA MAR MEX MLT MX1 MX2 MX3 MYS NLD NOR NZL PER PHL POL PRT"
	global country "$country  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
global country_hc "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country_hc "$country_hc  CHN          COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country_hc "$country_hc  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country_hc "$country_hc  LTU LUX LVA MAR MEX MLT      MYS NLD NOR NZL PER PHL POL PRT"
	global country_hc "$country_hc  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
	
	global sector "C01T05 C10T14 C15T16 C17T19 C20 C21T22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37 C40T41 C45"
	global sector "$sector C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"
	
	global noneuro "ARG AUS BGR BRA BRN CAN CHE CHL CHN COL CRI CZE DNK GBR HKG HRV HUN IDN IND ISL ISR JPN KHM KOR MEX MX1 MX2 MX3 MYS NOR NZL PHL POL ROU ROW RUS SAU SGP SWE THA TUN TUR TWN USA VNM ZAF"
	global china "CHN CN1 CN2 CN3 CN4"
	global mexique "MEX MX1 MX2 MX3"
	
	global var_entree_sortie arg_c01t05agr-zaf_c95pvh
	
	}

if "`source'"=="WIOD" {
	global country "   AUS AUT BEL BGR BRA     CAN CHE" 
	global country "$country CHN                             CYP CZE DEU DNK ESP EST FIN"
	global country "$country FRA GBR GRC     HRV HUN IDN IND IRL        ITA JPN     KOR"
	global country "$country LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
	global country "$country ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	
	global country_hc $country
	
	global sector "A01 A02 A03 B C10-C12 C13-C15 C16 C17 C18 C19 C20 C21 C22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C31_C32 C33 C35 E35 E36 E37-E39"
	global sector "$sector F G45 G46 G47 H49 H50 H51 H52 H53 I J58 J59_J60"
	global sector "$sector J61 J62_J63 K64 K65 K66 L68 M69_M70 M71 M72 M73"
	global sector "$sector M74_M75 N O84 O85 Q R_S T U"
	
	
	global noneuro "BGR BRA CAN CHE CHN CZE DNK  GBR HRV HUN IDN IND  JPN KOR MEX NOR  POL ROU ROW RUS SWE TUR TWN USA"    
	global china "CHN"
	global mexique "MEX"
	
	global var_entree_sortie vAUS01-vUSA56
}

global nbr_pays = wordcount("$country")
global nbr_secteurs = wordcount("$sector")
global dim_matrice = $nbr_pays*$nbr_secteurs

*agrégats couverts identiquement par les 2 sources
global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
global eastern "BGR CZE HRV HUN POL ROU"

end

	
local nbr_sect=wordcount("$sector")	
*-------------------------------------------------------------------------------
*COMPUTING LEONTIEF INVERSE MATRIX  : matrix L1
*-------------------------------------------------------------------------------

set more off
*set matsize 7000
capture program drop compute_leontief
program compute_leontief
args yrs source

Definition_pays_secteur `source'
	
*Create vector Y of output from troncated database
clear
use "$dir/Bases/`source'_`yrs'_OUT.dta", clear
mkmat $var_entree_sortie, matrix(Y)

*Create matrix Z of inter-industry inter-country trade
use "$dir/Bases/`source'_`yrs'_Z.dta"



mkmat $var_entree_sortie, matrix (Z)

*From vector Y create a diagonal matrix Yd which contains all elements of vector Y on the diagonal
matrix Yd=diag(Y)

*Take the inverse of Yd (with invsym instead of inv for more accurateness and to avoid errors)
matrix Yd1=invsym(Yd)

*Then multiply Yd1 by Z 
matrix A_`yrs'=Z*Yd1

clear
svmat A_`yrs', names(col)
save "$dir/Bases/A_`source'_`yrs'.dta", replace



*Create identity matrix at the size we want. 
mat I=I($dim_matrice)

*I-A
matrix L=(I-A_`yrs')

*Leontief inverse
matrix L1_`yrs'=inv(L)

clear
svmat L1_`yrs', names(col)
save "$dir/Bases/`source'_L1_`yrs'.dta", replace


display "fin de compute_leontieff" `yrs'

end

*-------------------------------------------------------------------------------
* On construit la matrice ZB avec des matrices B diagonales
*-------------------------------------------------------------------------------



set more off
*set matsize 7000
capture program drop compute_leontief_chocnom
program compute_leontief_chocnom
	args yrs groupeduchoc source
*ex : compute_leontief_chocnom 2005 ARG	
*Create vector Y of output from troncated database

display "`groupeduchoc'"

*use "H:\Agents\Cochard\Papier_chocCVA/Bases/OECD_`yrs'_OUT.dta"
*mkmat $var_entree_sortie, matrix(Y)

*Create matrix Z of inter-industry inter-country trade

use "$dir/Bases/A_`source'_`yrs'.dta", clear


merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
drop _merge
rename c pays_choqué

***----  On construit la matrice B avec des 0 partout sauf pour les CI étrangères en provenance du pays choqué ------*

gen grchoc_ligne = 0

foreach p of local groupeduchoc {
	replace grchoc_ligne = 1 if pays_choqué == "`p'" 

	if ("`p'"=="MEX")  {
		replace grchoc_ligne = 1 if  strpos("$mexique", pays_choqué)!=0
	}
	if ("`p'"=="CHN") {
		replace grchoc_ligne = 1 if  strpos("$china", pays_choqué)!=0
	}
	if ("`p'"=="EUR") {
		replace grchoc_ligne = 1 if strpos("$eurozone", pays_choqué)!=0
	}
	if ("`p'"=="EAS") {
		replace grchoc_ligne = 1 if strpos("$eastern", pays_choqué)!=0
	}
		
		
		
}
 


gen pays_origine=""
gen grchoc2=0


foreach var of varlist $var_entree_sortie {
	replace `var'=0 if grchoc_ligne==0
	
	
	if "`source'"=="TIVA" replace pays_origine = strupper(substr("`var'",1,strpos("`var'","_")-1))
	if "`source'"=="WIOD" replace pays_origine = strupper(substr("`var'",2,4))
	foreach p of local groupeduchoc {
	
		replace grchoc2 = 1 if pays_origine == "`p'" 
		

		if ("`p'"=="MEX") {
			replace grchoc2 = 1 if  strpos("$mexique", pays_origine)!=0
	
		}
		if ("`p'"=="CHN") {
			replace grchoc2 = 1 if  strpos("$china", pays_origine)!=0
		} 
	
		
		if ("`p'"=="EUR") {
			replace grchoc2 = 1 if strpos("$eurozone", pays_origine)!=0
		}
		if ("`p'"=="EAS") {
		replace grchoc2 = 1 if strpos("$eastern", pays_origine)!=0
	}
		
		

	}
	

	replace `var'=0 if grchoc_ligne==1  & grchoc2==1 
*	if strmatch("`var'","*aut*")==1 blif
	

replace grchoc2=0


}
*drop grchoc grchoc2
mkmat $var_entree_sortie, matrix (B)
order pays_choqué s
if $test==1 save "$dir/Bases/`source'_B_`yrs'_`groupeduchoc'.dta", replace
***----  On construit la matrice B2 avec des 0 partout sauf pour les CI étrangères du pays choqué ------*

use "$dir/Bases/A_`source'_`yrs'.dta", clear

merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
drop _merge

gen grchoc_ligne = 0

foreach p of local groupeduchoc {
	replace grchoc_ligne = 1 if c == "`p'" 

	if ("`p'"=="MEX") {
		replace grchoc_ligne = 1 if strpos("$mexique", c)!=0

		}
	if ("`p'"=="CHN") {
		replace grchoc_ligne = 1 if strpos("$china", c)!=0

		}
	if ("`p'"=="EUR") {
		replace grchoc_ligne = 1 if strpos("$eurozone", c)!=0
	}
	if ("`p'"=="EAS") {
		replace grchoc_ligne = 1 if strpos("$eastern", c)!=0
	}
		
		
}
 

gen pays_origine=""
gen grchoc2=0

foreach var of varlist $var_entree_sortie {
if "`source'"=="TIVA" replace pays_origine = strupper(substr("`var'",1,strpos("`var'","_")-1))
if "`source'"=="WIOD" replace pays_origine = strupper(substr("`var'",2,4))
		

	
	foreach p of local groupeduchoc {
	
		replace grchoc2 = 1 if pays_origine == "`p'" 

		if ("`p'"=="MEX") {
			replace grchoc2 = 1 if strpos("$mexique", pays_origine)!=0

		}
		if ("`p'"=="CHN") {
			replace grchoc2 = 1 if strpos("$china", pays_origine)!=0
		}
		if ("`p'"=="EUR") {
		replace grchoc2 = 1 if strpos("$eurozone", pays_origine)!=0
		}
		if ("`p'"=="EAS") {
		replace grchoc2 = 1 if strpos("$eastern", pays_origine)!=0
		}
		

	}

	
		replace `var'=0 if grchoc2==0
	replace `var'=0 if (grchoc_ligne==1 & grchoc2==1)
replace grchoc2=0


}
*drop grchoc_ligne grchoc2 pays
mkmat $var_entree_sortie, matrix (B2)

display "fin de compute_leontief_chocnom`groupeduchoc'" `yrs'
order c s 

if $test==1 save "$dir/Bases/`source'_B2_`yrs'_`groupeduchoc'.dta", replace

end

   
*---------------------------------------------------------------------------------------------
*COMPUTING THE EFFECT OF A SHOCK ON EXCHANGE RATE IN ONE COUNTRY  : matrix C`cty'
*---------------------------------------------------------------------------------------------
capture program drop vector_shock_exch
program vector_shock_exch
		args shk groupeduchoc source
		***exepl : vector_shock_exch 1 ARG TIVA

*set matsize 7000
set more off

use "$dir/Bases/csv_`source'.dta", clear

* On construit le vecteur c, avec le choc c pour le pays choqué, 0 sinon

foreach p of local groupeduchoc {

	replace p_shock = `shk' if c == "`p'"
	
	
	if ("`p'"=="MEX") {
			replace p_shock = `shk' if strpos("$mexique", c)!=0

		}
	if ("`p'"=="CHN") {
			replace p_shock = `shk' if strpos("$china", c)!=0

		}	
		
	if ("`p'"=="EUR") {
		replace p_shock = `shk' if strpos("$eurozone", c)!=0
	}
	if ("`p'"=="EAS") {
		replace p_shock = `shk' if strpos("$eastern", c)!=0
	}
		
	

	
}


*I extract vector p_shock from database with mkmat
mkmat p_shock
matrix p_shockt=p_shock'


* On construit le vecteur c tilde, avec le choc -c pour les pays non choqués, 0 sinon


generate p_shock2=-`shk'
foreach p of local groupeduchoc {

	replace p_shock2 = 0 if c == "`p'"
	
	if ("`p'"=="MEX") {
			replace p_shock2 = 0 if strpos("$mexique", c)!=0
	
	}
	if ("`p'"=="CHN") {
			replace p_shock2 = 0 if strpos("$china", c)!=0

	}	
	if ("`p'"=="EUR") {
		replace p_shock2 = 0 if strpos("$eurozone", c)!=0
	}
	if ("`p'"=="EAS") {
		replace p_shock2 = 0 if strpos("$eastern", c)!=0
	}
	
	
}
*I extract vector p_shock from database with mkmat
mkmat p_shock2
matrix p_shock2t=p_shock2'

*Example: p_shock = 0.05 if (c = "ARG" & s == "C01T05")

*I extract vector p_shock from database with mkmat
mkmat p_shock
matrix p_shockt=p_shock'
*The transpose of p_shock will be necessary for further computations


end


capture program drop shock_exch
program shock_exch
	args yrs groupeduchoc source
	****expl : shock_exch 2005 ARG TIVA
	
	


use "$dir/Bases/`source'_L1_`yrs'.dta", clear
mkmat r1-r$dim_matrice, matrix (L1)


*Multiplying the transpose of vector shock `v'_shockt by L1 to get the impact of a shock on the output price vector
matrix C`groupeduchoc' = p_shockt+(p_shockt*B+p_shock2t*B2)*L1
*Result example: using p_shock = 0.05 if c == "ARG" & s == "C01T05": if prices in agriculture increase by 5% in Argentina, output prices in the sector of agriculture in Argentina increase by 5.8%


matrix C`groupeduchoc't=C`groupeduchoc''
svmat C`groupeduchoc't
keep C`groupeduchoc't1


if $test==1 save "$dir/Bases/`source'_C_`yrs'_`groupeduchoc'.dta", replace

end


*----------------------------------------------------------------------------------
*CREATION OF A VECTOR CONTAINING MEAN EFFECTS OF A SHOCK ON EXCHANGE RATE FOR EACH COUNTRY
*----------------------------------------------------------------------------------
*Creation of the vector Y is required before table_adjst : matrix Yt
capture program drop create_y
program create_y
args yrs
clear

use "$dir/Bases/OECD_`yrs'_OUT.dta"


mkmat $var_entree_sortie, matrix(Y)
matrix Yt = Y'

end

*Creation of the vector of export X : matrix X
* 2017-10-17 redondant avec le programme 1!!!
capture program drop compute_X
program compute_X
	args yrs

use "$dir/Bases/OECD`yrs'.dta", clear


global country2 "arg aus aut bel bgr bra brn can che chl chn chn.npr chn.pro chn.dom col cri cyp cze deu dnk esp est fin fra gbr grc hkg hrv hun idn ind irl isl isr ita jpn khm kor ltu lux lva mex mex.ngm mex.gmf mlt mys nld nor nzl phl pol prt rou row rus sau sgp svk svn swe tha tun tur twn usa vnm zaf"

generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
drop if pays==""

egen utilisations = rowtotal(arg_c01t05agr-disc)
gen utilisations_dom = .

foreach j of global country2 {
	local i = "`j'"
	if  ("`j'"=="chn.npr" | "`j'"=="chn.pro" |"`j'"=="chn.dom" ) {
		local i = "chn" 
	}
	if  ("`j'"=="mex.ngm" | "`j'"=="mex.gmf") {
			local i = "mex"
	}
	egen blouk = rowtotal(`i'*)
	display "`i'" "`j'"
	replace utilisations_dom = blouk if pays=="`j'"
	codebook utilisations_dom if pays=="`j'"
	drop blouk
}
generate X = utilisations - utilisations_dom
	
replace pays = strupper(pays)
generate year = `yrs'

keep year pays X
mkmat X

end

*Creation of the vector of value-added VA : matrices Y, X, VA

capture program drop compute_VA
program compute_VA
	args yrs
clear
use "$dir/Bases/OECD`yrs'.dta", clear
keep if v1 == "VA.TAXSUB"
drop v1
mkmat $var_entree_sortie, matrix(VA)
matrix VAt = VA'
end

capture program drop compute_HC
program  compute_HC
	args yrs source 
	
	use "$dir/Bases/HC_`source'.dta", clear
	keep if year == `yrs'
	foreach pays_conso of global country_hc {
		preserve
		keep if pays_conso==strlower("`pays_conso'")
		mkmat conso, matrix(HC_`pays_conso')
		restore
	}
	
end
*===============================================================

capture program drop compute_mean    // matrix shock`cty'
program compute_mean
	args cty wgt source 
clear
*set matsize 7000
set more off
clear
use "$dir/Bases/csv_`source'.dta"

*I decide whether I use the production or export or value-added vector as weight modifying the argument "wgt" : Yt or X or VAt
*Compute the vector of mean effects :

if ("`wgt'" == "Yt")  {
	matrix Yt = Y'
	svmat Yt 
	

}
if ("`wgt'" == "X")  {
	svmat X
}
if ("`wgt'" == "X") | ("`wgt'" == "Yt") {
	matrix C`cty't= C`cty''
	svmat C`cty't
	generate Bt = C`cty't1* `wgt'
	bys c : egen tot_`wgt' = total(`wgt')
	generate sector_shock = Bt/tot_`wgt'
	bys c : egen shock`cty' = total(sector_shock)

}



local blink 0
matrix C`cty't= C`cty''
svmat C`cty't, name(C`cty')	
if ("`wgt'" == "HC")  {
	foreach pays_conso of global country_hc {
	svmat HC_`pays_conso', name(HC_`pays_conso')
	generate Bt_`pays_conso' = C`cty'* HC_`pays_conso'
	egen tot_HC_`pays_conso' = total(HC_`pays_conso')
	generate sector_shock_`pays_conso' = Bt_`pays_conso'/tot_`wgt'_`pays_conso'
	egen shock`cty'_`pays_conso' = total(sector_shock_`pays_conso')
*	keep if _n==1
	mkmat shock`cty'_`pays_conso'

	if `blink'== 0 matrix shock`cty' = shock`cty'_`pays_conso'[1,1]
	if `blink'!= 0 matrix shock`cty' = shock`cty' \ shock`cty'_`pays_conso'[1,1]
	matrix drop shock`cty'_`pays_conso'
	local blink=`blink'+1	
	drop Bt* tot* sector_shock* HC*  shock*
	}
}



//svmat VAt

set more off


*Vector shock`cty' contains the mean effects of a shock on exchange rate (coming from the country `cty') on overall prices for each country

end


*----------------------------------------------------------------------------------------------------
*CREATION OF THE TABLE CONTAINING THE MEAN EFFECT OF A EXCHANGE RATE SHOCK FROM EACH COUNTRY TO ALL COUNTRIES
*----------------------------------------------------------------------------------------------------
capture program drop table_mean
program table_mean
	args yrs wgt shk source
*yrs = years, wgt = Yt (output) or X (export) or VAt (value-added) or HC (household consumption)
clear
*set matsize 7000
* set trace on
set more off

*compute_leontieff `yrs'
if ("`wgt'" == "Yt")  {
	create_y `yrs' 
	}
if ("`wgt'" == "X")  {
	compute_X `yrs'
	}
//compute_VA `yrs'

	
if "`source'"=="TIVA" {
*	global ori_choc "CHN"
	global ori_choc "EUR EAS"
	global ori_choc "$ori_choc ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL CHN COL CRI CYP CZE DEU DNK ESP EST FIN"
	global ori_choc "$ori_choc FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR LTU LUX LVA MAR MEX MLT MYS NLD NOR NZL PER "
	global ori_choc "$ori_choc PHL POL PRT ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
}

if "`source'"=="WIOD" {
	global ori_choc "EUR EAS AUS"
	*global ori_choc "$ori_choc AUS AUT BEL BGR BRA     CAN CHE CHN                             CYP CZE DEU DNK ESP EST FIN " 
	*global ori_choc "$ori_choc FRA GBR GRC     HRV HUN IDN IND IRL       ITA JPN     KOR LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
	*global ori_choc "$ori_choc ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
}

foreach i of global ori_choc {
	compute_leontief_chocnom `yrs' `i' `source'
	vector_shock_exch `shk' `i'  `source'  //
	shock_exch `yrs' `i'  `source'
	compute_mean `i' `wgt' `source'
}


use "$dir/Bases/pays_en_ligne_`source'.dta", clear
drop if c=="MX1" | c=="MX2" |  c=="MX3" |  c=="CN1"  |  c=="CN2"  |  c=="CN3"  |  c=="CN4" 
set more off

foreach i of global ori_choc {
		svmat shock`i'
		
}



* shockARG1 represents the mean effect of a price shock coming from Argentina for each country
save "$dir/Results/Devaluations/mean_chg_`source'_`wgt'_`yrs'.dta", replace
*We obtain a table of mean effect of a price shock from each country to all countries

export excel using "$dir/Results/Devaluations/mean_chg_`source'_`wgt'_`yrs'.xls", firstrow(variables) replace

* set trace off
set more on

end


*-------------------------------------------------------------------------------
*DEVALUATION OF THE EURO What happens when the euro is devaluated? To know that, we do a shock of 1 on all countries but the eurozone.
*-------------------------------------------------------------------------------

capture program drop shock_deval
program shock_deval
	args yrs shk wgt zone
*yrs = years,shk = 1, wgt = Yt (output) or X (export) or VAt (value-added), zone = noneuro (for a shock corresponding to a devaluation of the euro), china or eastern

set matsize 7000
*set trace on
set more off
clear

//compute_leontieff `yrs'
if ("`wgt'" == "Yt")  {
	create_y `yrs' 
	}
if ("`wgt'" == "X")  {
	compute_X `yrs'
	}

compute_leontief_chocnom `yrs' `zone' 
vector_shock_exch `shk' `zone'
shock_exch `yrs' `zone'
compute_mean `zone' `wgt'

clear
svmat shock`zone'

* shockARG1 represents the mean effect of a price shock coming from Argentina for each country
save "$dir/Results/Devaluations/mean_`zone'_`wgt'_`yrs'.dta", replace
*We obtain a table of mean effect of a price shock from each country to all countries

export excel using "$dir/Results/Devaluations/mean_`zone'_`wgt'_`yrs'.xls", firstrow(variables)

*set trace off
*set more on

end

*/




*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM
*--------------------------------------------------------------------------------




clear
set more off

foreach source in WIOD /*  TIVA */{ 

if "`source'"=="WIOD" local start_year 2000
if "`source'"=="TIVA" local start_year 1995

if "`source'"=="WIOD" local end_year 2014
if "`source'"=="TIVA" local end_year 2011
Definition_pays_secteur `source'

// Fabrication des fichiers d'effets moyens des chocs de change
// pour le choc CPI, faire tourner compute_HC et compute_leontief, les autres ne sont pas indispensables
 *2005 2009 2010 2011
foreach i of numlist `start_year' /* (1)`end_year'*/  {
	clear
	set more off
	compute_leontief `i' `source'
*	compute_X `i' `source'
*	create_y `i' `source'
*	compute_VA `i' `source'
    compute_HC `i' `source'
	
}

foreach i of numlist `start_year'/*(1)`end_year'*/{
*foreach j in Yt X 
		foreach j in HC {
		table_mean `i' `j' 1 `source'
	}
}

* shock_deval 2011 1 Yt noneuro   
*/


log close
/*

// dévaluation de l'euro par rapport à toutes les monnaies
compute_leontieff 2011
 
*create_y 2011
*compute_X 2011
*compute_mean_deval 2011 noneuro


set more on
*/

}


