*--------------------------------------------------
*ARE 256b W23 -- Section 7
*0303.do
*Mar/03/2023
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the week 7 of ARE 256B TA Sections. 
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
log using 0303, replace // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\mahdi\are256b-w23"
cd $path


*--------------------------------------------------
* Part 1: Seasonal patterns: Electronic prices
*--------------------------------------------------

import excel "data/APU000072610.xlsx", firstrow clear 

// Average Price: Electricity per Kw-H in U.S. City Average, U.S. Dollars, Monthly
// Not Seasonally Adjusted
// Source: https://fred.stlouisfed.org/series/APU000072610

*rename variables
rename APU000072610 p
rename DATE date
destring p, replace

*time format
format date %td

*extract month and year
gen mth = month(date) 
gen yr = year(date)

*generate a new monthly time index
gen month = ym(yr,mth)
format month %tm
tsset month

*or
//gen mdate = mofd(date)
//format mdate %tm


*seasonal?
tsline p
tsline p if  inrange(yr, 2000, 2003)

*Generate a new variable seasonal that is equal to 1 for t 
*corresponding to January and 0 otherwise. 

gen seasonal = 1 if mth == 1
replace seasonal = 0 if seasonal == .

*Remember: Problem 2 in HW3:
*Compute regression of gcem on L(0/10)seasonal.
*Which months has the largest and the smallest average values for gcem? 

*use December as a base case
reg p L(0/10).seasonal,robust 

*use January as a base case
reg p i.mth, robust
// avg for December (mth==12): 
dis .1008837+.0001877

*Directly calculate the means
reg p L(0/11).seasonal, nocons robust


*--------------------------------------------------
* Part 2: Breusch-Godfrey Test
*--------------------------------------------------

*for simplicity set x as white noise
gen x = rnormal() 

*i) Perform the OLS regression.
reg p x
di e(N)

*ii) Obtain residuals from that regression.
predict resid, residuals

// do we have autocorrelations? 
ac resid

*iii) Generate the lagged residual.
gen resid_lag1 = resid[_n-1]

*iv)Perform the auxiliary regression of the residual on its own lag and the regressor grres.
reg resid x  resid_lag
di e(N)
// the observations is 1 less than reg p x
// because 1 lag + one unobserved data in reg p x 
// which will be 2 times missing in the new sample

reg resid x L(1/1).resid

reg resid x L(1/3).resid
di e(N)

reg resid x L(1/5).resid
di e(N)


esttab, se r2

*v) Compute the Breusch-Godfrey statistic using nR2 from the above regression.	
dis 484 * 0.997 

// other method
estadd scalar nR2 = e(N)*e(r2)
estadd scalar pval = chi2tail(e(df_m) - 1, e(nR2))

/* 
dis chi2(1,3.8414588) will produce .95, 
which means that the probability of obtaining a value of 3.8414588 or less is .95
, or, put differently, that 3.8414588 corresponds to the .95 quantile, 
in the case of a chi-squared distribution with 1 d.f. 
In contrast, dis chi2tail(1,3.8414588) will return .05 
*/

//chisq test -- https://www.wikiwand.com/en/Chi-squared_test

reg resid x
estat bgodfrey, lags(5)

estat bgodfrey, lags(20)

*--------------------------------------------------
* Part 3: Correcting for Serial Correlation
*--------------------------------------------------

*compute the T (or the p?) you need
reg p x, robust
newey p x, lag(6) force


reg L(0/26).p 
estat bgodfrey, lags(26)

*for large sample, we can use p = 0.75*T^(1/3)
* scalar p = floor(0.75*e(N)^(1/3))

*===========================================================
log close 

translate "$path\0303.smcl" ///
          "$path\0303.pdf", translator(smcl2pdf)

/* Loose ends:

1 - 


*/ 
