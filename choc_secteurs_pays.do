
   
*---------------------------------------------------------------------------------------------
*COMPUTING THE EFFECT OF A SHOCK   : matrix C`cty'
*---------------------------------------------------------------------------------------------
capture program drop vector_shock_secteurs_pays
program vector_shock_secteurs_pays
		args shk source
		***exepl : vector_shock_secteurs_pays 1  TIVA

*set matsize 7000
set more off

use "$dir/Bases/csv_`source'.dta", clear

* On construit le vecteur c$, avec le choc c$ pour le pays choqué, 0 sinon (cf. équation 3)

	if "`source'"=="WIOD" replace p_shock = `shk' if s == "B"
	if "`source'"=="TIVA" replace p_shock = `shk' if s == "C10T14"
	if "`source'"=="TIVA_REV4" replace p_shock = `shk' if s == "05T06"

	
	*I extract vector p_shock from database with mkmat (Ci)
mkmat p_shock, matrix(cit)
matrix ci=cit'  /* transposé*/
matrix list ci


end


capture program drop shock_secteurs_pays
program shock_secteurs_pays
	args yrs source
	****expl : shock_pays_secteurs 2005  TIVA
	use "$dir/Bases/`source'_L1_`yrs'.dta", clear
	mkmat r1-r$dim_matrice, matrix (L1)


*Multiplying the transpose of vector shock `v'_shockt by L1 to get the impact of a shock on the output price vector 
*Il s'agit du choc en dollar (équation 6)
matrix S`groupeduchoc' = ci*L1


matrix S`groupeduchoc't=S`groupeduchoc''
svmat S`groupeduchoc't
keep S`groupeduchoc't1


if $test==1 save "$dir/Results/secteurs_pays/`source'_`yrs'_secteurs_pays.dta", replace






end


