args yrs

clear


cd "\\intra\partages\au_dcpm\DiagConj\BMEs\BME_2017"

import excel using Total_Impact--EEN-11_Oct_2016.xlsx, sheet("CTRY") cellrange(C9:I30) firstrow clear


rename C pays 
rename I BME
drop D E F G H  
generate year = 2016

save \\intra\partages\ua1383_data\Agents\Lalliard\Commerce_VA_inflataion\BME_2016.dta

