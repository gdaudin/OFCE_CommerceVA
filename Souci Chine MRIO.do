use "/Users/guillaumedaudin/Documents/Recherche/2017 BDF_Commerce VA/Bases/HC_MRIO.dta", clear
keep if pays_conso=="PRC"
tab year
reshape wide conso, i(pays sector pays_conso) j(year)

br pays sector pays_conso conso2017 conso2018

generate blif = (conso2018-conso2017)/conso2017
summarize blif
br pays sector pays_conso conso2017 conso2018 blif
gsort -  blif
br pays sector pays_conso conso2017 conso2018 blif
generate blouf = (conso2018-conso2017)
summarize blouf
gsort -  blouf
br pays sector pays_conso conso2017 conso2018 blif blouf


*J’ai continué à vérifier ce qui se passait en 2018 et 2019 pour la Chine dans MRIO.  La consommation de C32 (éducation) augmente de 43% entre 2017 et 2018, celle de transport baisse de 43%… Bref, il y a des soucis dans les données MRIO, du côté du vecteur de consommation chinois en 2018 et 2019. Je crois qu’il faudrait le préciser dans le papier.

