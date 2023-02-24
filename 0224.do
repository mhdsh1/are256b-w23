*--------------------------------------------------
*ARE 256b W23 -- Section 6
*0224.do
*Feb/24/2023
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the week 6 of ARE 256B TA Sections. 
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
log using 0224, replace // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\mahdi\are256b-w23"
cd $path

*--------------------------------------------------
* Part 1: White noise, MA(1), AR(1)  
*--------------------------------------------------

*Generate White noise, MA(1), AR(1) processes using the codes from the slides. 
*Make *autocorrelation plots  for T=100 and 1000 to illustrate consistency.

clear all
set more off

set obs 1050

gen t=[_n]

tsset t

*White Noise
gen e=rnormal() 

*Plot the constructed time series
tsline e if t<100

*Create an autocorrelogram (95% confidence interval by default)
ac e
*90% Confidence interval
ac e, level(90)
*T=1000 (40 lags by default)
ac e,lags(1000)


*MA1

gen elag=e[_n-1]

gen yma=0.25+e+elag*.5
tsline yma if t<100
ac yma
*T=1000
ac yma,lags(1000)


*AR1
gen yar=e in 1

replace yar=0.25+0.9*yar[_n-1]+e in 2/1050
tsline yar
ac yar
*T=1000
ac yar,lags(500)

*AR1 with diff para  
*Plot AR(1) process with rho = 0, 0.4, 0.9 for T=100.

*rho=0
gen yar_00=e in 1
replace yar_00=0.25+0*yar_00[_n-1]+e in 2/1050
*rho=0.4
gen yar_04=e in 1
replace yar_04=0.25+0.4*yar_04[_n-1]+e in 2/1050
*rho=0.9
gen yar_09=yar

tsline yar_00 yar_04 yar_09

*--------------------------------------------------
* Bonus 1:  S&P 500  
*--------------------------------------------------


*Download S&P 500 daily stock returns for recent 5 years
*https://fred.stlouisfed.org/series/SP500*
*Make a plot of the time series  and autocorrelation. 
*It should be like white noise, i.e. no autocorrelation.

import excel "data/SP500.xls", firstrow clear 

destring SP500, replace

*time format
*Date and time functions :   https://www.stata.com/manuals13/u24.pdf
format DATE %td

tsset DATE
tsline SP500
ac SP500, lag(100)

*daily stock returns rate
gen returns = (SP500 - SP500[_n-1])/  SP500[_n-1]
tsline returns 


*like white noise
ac returns,lags(100)


*first differences
gen dSP500 = SP500 - SP500[_n-1]
tsline dSP500
ac dSP500, lag(100)

*--------------------------------------------------
* Bonus 2: CPI monthly
*--------------------------------------------------

*Download CPI monthly  inflation (both index, Y,  and percentage changes, d log Y)  
*1970-2022 https://fred.stlouisfed.org/series/CPILFESL . 
*Note that Index is trending upwards, but after doing percentage changes, it wiggles around the mean.

import delimited "/Users/c/Documents/Stata/256B2022/Discussion6/CPILFESL.csv",clear

*time format
generate date1 = date(DATE, "YMD")
gen date2 = date1
format date2 %td
tsset date2

rename cpilfesl y
ac y, lags(200)

*two ways to calculate percentage change
gen logy = log(y)
gen dlogy = logy - logy[_n-1]
gen pcy = (y-y[_n-1])/y[_n-1]
tsline dlogy pcy

tsline y

ac logy, lags(200)

*For CPI percentage changes compute mean  and AC function. How many AC lags are *statistically significant?

sum dlogy
ac dlogy, lag(70)


*Compute differences in CPI percentage changes, dd log Y, make TS plot. How many AC lags are statistically for dd log Y ?

gen ddlogy = dlogy - dlogy[_n-1]
tsline ddlogy
ac ddlogy, lag(500)

*Computing first differences to try to get a stationary process
gen dy = y - y[_n-1]	
tsline dy
ac dy
	
gen ddy = dy - dy[_n-1]	
tsline ddy
ac ddy
			*For an insight of why we would want a stationary process, please check
			*your textbook and
			* https://www.tylervigen.com/spurious-correlations

*===========================================================
log close 

translate "$path\0224.smcl" ///
          "$path\0224.pdf", translator(smcl2pdf)

/*
Loose ends:
- Why we need confidence intervals for autocorrelogram?
*/
