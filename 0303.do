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

// look at: https://sscc.wisc.edu/sscc/pubs/stata_dates/stata_dates

*we use "format" to make date readable
format date %td

*extract month and year
// The year() function will extract the year from a date as a simple number:

gen mth = month(date) 
gen yr = year(date)

*generate a new monthly time index
gen month = ym(yr,mth)

*let's format it to make it readable
format month %td
format month %tm


*let's set month as our time-series periods
tsset month


*Do we have seasonality? Visual test: 
tsline p
tsline p if  inrange(yr, 2000, 2003)
tsline p if  yr == 2000


*Now let's find the average price for each month:

*One way we can do it is by regressing price (p) on the dummy variable for each month (D_month).

*model 1: p = \beta_jan*D_jan + \beta_feb*D_feb + ... + \beta_dec*D_dec + e
*where D_feb is 1 if month == feb and 0 otherwise

*or if we have a constant in the regression:
*model 2: p = \beta_0 + \beta_feb*D_feb + ... + \beta_dec*D_dec + e

*let's see, as an example, what would be the average price in september, based on model 2:
* E(p|month=sep) = \beta_0 + \beta_feb*0+ ...+\b_sep*1+ \beta_oct*0 + ...
* E(p|month=sep) = \beta_0 + \b_sep

*There are several ways where we can regress model 1 and 2 in Stata:

*** Method1: 
*the first way to make these set if dummy variables is using "i.month" in Stata 

reg p i.mth, robust
*This is exaclty model 2 above, where January is a base case


*** Method2:
*In the second method, we make a dummy variable for one month, 
*and use lag(s) of that dummy, to make dummy variable for the other months.

*let's make seasonal as a dummy for January.	
gen seasonal = 1 if mth == 1
replace seasonal = 0 if seasonal == .

*now note that the the first lag of seasonal works as a dummy for February:
g lseasonal = seasonal[_n-1]

*so another way of regressing model 2 is regressing price on seasonal and its lags
*then the lag1 is a dummy for feb, lag2 a dummy for mar, ..., and lag11 a dummy for December

*Lag operator L(p) in Stata allows us to do this kind of regression easier. 
*for example, this two regressions are the same:

reg p lseasonal, robust
reg p L(1).seasonal, robust

* these two are also the same:
reg p seasonal lseasonal, robust
reg p L(0/1).seasonal, robust

*So in order to regress price on sesonal and its lags (model 2) I can do the regression:
reg p L(0/10).seasonal,robust 

*notice that here the L0 coefficient is for Jan, L1 is for Feb, ..., and L10 for Nov.
*the constant works as a coefficient for Dec.  
* you can again report the average price for each months using this model
* for example, for september we have:
* E(p|month=sep) = constant + \b_L8


*Ypu can also directly calculate the means, ny making model without constant
reg p L(0/11).seasonal, nocons robust


*notice that the sample size in method 1 and 2 are different.
*so in general we don't expect the results to match

*--------------------------------------------------
* Part 2: Breusch-Godfrey Test
*--------------------------------------------------

*--- Part 2_1: manual derivation

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
*v) Compute the Breusch-Godfrey statistic using nR2 from the above regression.	

// method 1 
// for p = 1

reg resid x  resid_lag
esttab, se r2

// method 2
// for p =1
reg resid x L(1/1).resid
esttab, se r2

// for p=3
reg resid x L(1/3).resid
// number of observation
di e(N)
esttab, se r2

// for p=5
reg resid x L(1/5).resid
di e(N)
esttab, se r2



// other method (not covered)
estadd scalar nR2 = e(N)*e(r2)
estadd scalar pval = chi2tail(e(df_m) - 1, e(nR2))

/* 
dis chi2(1,3.8414588) will produce .95, 
which means that the probability of obtaining a value of 3.8414588 or less is .95
, or, put differently, that 3.8414588 corresponds to the .95 quantile, 
in the case of a chi-squared distribution with 1 d.f. 
In contrast, dis chi2tail(1,3.8414588) will return .05 
chisq test -- https://www.wikiwand.com/en/Chi-squared_test
*/

*--- Part 2_2: using Stata command bgodfrey

reg resid x

estat bgodfrey, lags(1)

estat bgodfrey, lags(3)

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

