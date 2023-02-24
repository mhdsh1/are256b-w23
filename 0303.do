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

import delimited "APU000072610.csv",clear

*rename variables
rename apu000072610 p

*time format
generate date1 = date(date, "YMD")
gen date2 = date1
format date2 %td

*extract month and year
gen mth = month(date2) 
gen yr = year(date2)

*generate a new monthly time index
gen month = ym(yr,mth)
format month %tm
tsset month

*or
gen mdate = mofd(date2)
format mdate %tm


*seasonal?
tsline p
tsline p if  inrange(yr, 2000, 2003)

*(a)Seasonal dummies
*Generate a new variable seasonal that is equal to 1 for t 
*corresponding to January and 0 otherwise. 

gen seasonal = 1 if mth == 1
replace seasonal = 0 if seasonal == .

*Compute regression of gcem on L(0=10)seasonal.
*Which months has the largest and the smallest average values for gcem? 

*use December as a base case
reg p L(0/10).seasonal,robust

*use January as a base case
reg p i.mth, robust
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
*ii) Obtain residuals from that regression.
predict resid, residuals
ac resid
*iii) Generate the lagged residual.
gen resid_lag1 = resid[_n-1]
*iv)Perform the auxiliary regression of the residual on its own lag and the regressor grres.
reg resid x  resid_lag
reg resid x L(1/1).resid
reg L(0/1).resid x


reg resid x L(1/3).resid
reg resid x L(1/5).resid

esttab, se r2

*v) Compute the Breusch-Godfrey statistic using nR2 from the above regression.	
dis 484 * 0.997 


reg resid x
estat bgodfrey, lags(5)

estat bgodfrey, lags(20)

*(c)Correcting for Serial Correlation.
*compute the T you need
reg p x, robust
newey p x, lag(6) force


reg L(0/26).p 
estat bgodfrey, lags(26)

*===========================================================
log close 

translate "$path\0303.smcl" ///
          "$path\0303.pdf", translator(smcl2pdf)

