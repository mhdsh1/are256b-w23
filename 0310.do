*--------------------------------------------------
*ARE 256b W23 -- Section 9
*0310.do
*Mar/10/2023
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the Week 9 of ARE 256B TA Sections. 
*--------------------------------------------------

*--------------------------------------------------
*Program Setup
*--------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
log using 0310, replace // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\mahdi\are256b-w23"
cd $path


*--------------------------------------------------
* Part 1: Slides 92 - 93: FE in Stata
*--------------------------------------------------

use data\Guns.dta,clear
		
		
*Declare the dataset as a panel
xtset stateid year, yearly


*Let us look at the data over time
*State 11 has very very large numbers so it looks weird in the same
*graph
//twoway (line vio year), by(stateid)
//twoway (line vio year if stateid!=11), by(stateid)
twoway (line vio year if stateid==11), by(stateid)


*plain-vanilla:
xtreg vio shall, fe


*plain-vanilla with robust standard errors:
*Robust standard errors cluster over cross-sectional units
*allowing for arbitrary heteroskedasticity and serial correlation within cross-sectional units
xtreg vio shall, fe vce(robust)



*Least Squares Dummy Variable Regression
reg vio shall i.stateid


*including time fixed effects:
*i.year creates a dummy variable for each unique value of year
eststo: qui reg vio shall i.stateid i.year
esttab, se 

eststo: qui xtreg vio shall i.year, fe
esttab, se 

eststo: xtreg vio shall i.year, fe vce(robust)
esttab, se 


*including time fixed effects and state-level time trends: 
xtreg vio shall i.year c.year#i.stateid, fe

*c.year deals with year as a continuous variable, whereas i.stateid creates a dummy variable for each unique value of stateid. 
*# interacts each state dummy variable with the continuous year trend.
reg vio shall c.year 
reg vio shall year

reg vio shall c.year#i.stateid
reg vio shall c.year#stateid

reg vio shall year#i.stateid
reg vio shall i.year#i.stateid



*including the time-invariant regressor z:
gen z = 10*sqrt(stateid)
xtreg vio shall i.year#c.z, fe vce(robust)

*The above create year-specific coefficients for z. 
*Of course you can also include the time fixed effects and state-level time trends.

*--------------------------------------------------
* Part 2: HW4 Gun Control 
*--------------------------------------------------

*1a
*Regular regressions
eststo clear
eststo: quietly reg vio shall year avginc pm1029 density pop, robust
esttab, se ar2


*1b
*Random Effect regressions
eststo: quietly xtreg vio shall year avginc pm1029 density pop, re vce(robust)
esttab, se r2


*1c
eststo: quietly xtreg vio shall year avginc pm1029 density pop, fe vce(robust)
esttab, se r2

*1e

*Fixed effects regressions
xtreg vio shall year avginc pm1029 density pop, fe
estimates store fe_vio

*Random effects regressions
xtreg vio shall year avginc pm1029 density pop, re
estimates store re_vio

hausman fe_vio re_vio, sigmamore
*RE assumption is rejected


*--------------------------------------------------
* Part 3: HW4 Seat Belt  
*--------------------------------------------------

use data\SeatBelts.dta,clear


*Declare the dataset as a panel
xtset fips year, yearly

*2a
generate dk_spd=drinkage21*speed70

eststo clear
*first case (without time fixed effects)
eststo:  xtreg fatalityrate sb_useage drinkage21 dk_spd, fe vce(robust)
*second case (include time fixed effects) (+ i.year)

*third case (include time fixed effects & state-level trends) (+ i.year and c.year#fips)


esttab, se r2

***sidenote1***
*another way for interaction term, using # ... almost the same
reg fatalityrate sb_useage drinkage21 drinkage21#speed70
reg fatalityrate sb_useage drinkage21 dk_spd

*why?
br drinkage21 if speed70 ==1
reg  fatalityrate sb_useage  drinkage21#speed70

*drinkage21 and speed70 are treated as categorical values. 
*Although we see a 0 and a 1 STATA reads the zero as a "NO" and the 1 as a "YES". 
*Then, when we ask STATA to do an operation *like YES-YES it doesn't know what to do.
*So we can do a quick workaround:    
gen yy  = (drinkage21==1 & speed70==1)
gen yn  = (drinkage21==1 & speed70==0)
gen ny  = (drinkage21==0 & speed70==1)
gen nn  = (drinkage21==0 & speed70==0)
reg  fatalityrate sb_useage yy yn  
***end of sidenote1***

*2b
*Create a variable that indicates the driver had a higher 
*alcohol content in the blood 
* known as DUI (driving under the influence)
gen dui = 1- ba08


*repeat regressions for 3 cases
			
eststo clear

*first case (without time fixed effects)
eststo:  xtreg fatalityrate speed65#speed70 if dui==1 ,fe vce(robust)
*second case (include time fixed effects)

*third case (include time fixed effects & state-level trends)


esttab, se r2

*double check
br speed65 if speed70==1


*2c 
*year dummies
*why omit 1983?
foreach t of numlist 1984/1997 {
gen  yr`t'=1 if year == `t'
replace yr`t'=0 if yr`t' == .
}

*both with constant, equal to beta_0 + year fixed effect of 1983
reg fatalityrate sb_useage drinkage21 dk_spd yr*
reg fatalityrate sb_useage drinkage21 dk_spd i.year


*omit 1983 since take first difference
*this is for case 2
reg D.(fatalityrate sb_useage drinkage21 dk_spd) i.year ,   vce(cluster fips)
reg D.(fatalityrate sb_useage drinkage21 dk_spd yr*), nocons  vce(cluster fips)

*case 3
reg D.(fatalityrate sb_useage drinkage21 dk_spd) i.year i.fips,   vce(cluster fips)
xtreg D.(fatalityrate sb_useage drinkage21 dk_spd) i.year , fe  vce(cluster fips)





*===========================================================
log close 

translate "$path\0310.smcl" ///
          "$path\0310.pdf", translator(smcl2pdf)

