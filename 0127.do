*--------------------------------------------------
*ARE 256b W23 -- Section 3
*0127.do
*1/27/2023
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the third week of ARE 256B TA Sections. 
*Here you find codes related to the discussion of limited dependent variables where the 
* we have sample selection, or censored data problem. Tobit model and Heckit model are dicussed. 
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
log using 0127.txt, text replace      // Open log file
*--------------------------------------------------

*set working directory 
cd "C:\Users\mahdi\are256b-w23"

*--------------------------------------------------
* part1: Tobit
*--------------------------------------------------

*** Censored Data Generation (Monte Carlo Method):
clear all
set obs 50
* generating a new var X ranging from 11 to 60
gen X=_n+10
browse
* now we generate the error term assuming normal distribution
* it's good to set seed before generating any random var
set seed 2023
gen U=rnormal(0,10)

browse

gen Ystar=-40+1.2*X+U
browse

gen Y= Ystar*(Ystar>0)
// Stata trick: the term in the parantheses works as a conditional
// any conditional term in Stata is either 0 when false or 1 when true. 
// gen Y= Ystar
// replace Y = 0 if Ystar <= 0



scatter Y X if Y>0 || lfit Y X if Y>0|| lfit Ystar X, ///
legend(label(1 "Y")  label(2 "Truncated Regression")  label(3 "True Regression Relationship") )
regress Y X if Y>0

tobit Y X, ll(0)  robust

help tobit

*vce represents variance-covariance matrix of the estimators
tobit Y X, ll(0)  vce(robust)

*--------------------------------------------------
* part2: Heckit
*--------------------------------------------------

use "http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta", clear
* more info on data http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.des
gen exper2=exper^2

browse

*We want to understand the effect of education and experience on wage
* but we only observe earning for EMPLOYED individuals.
*We don't know who is employed
* but we may be able to model employment statuts (B) based on what we observe
*We suppose B is explained by the total income of hh, age, and number of kids.  
*... and probably they have negative effect on someoene being employed

*method 1: Heckman two stage model

*stage 1: finding the probit model 
gen B=1
replace B=0 if lwage==.
* modeling employment status
probit B nwifeinc age kidslt6 kidsge6


gen z=_b[nwifeinc]*nwifeinc+_b[age]*age+_b[kidslt6]*kidslt6 +_b[kidsge6]*kidsge6 + _b[_cons]
gen lambda_hat=normalden(z)/normal(z)

*stage 2: 
reg lwage educ exper exper2 lambda_hat


*method 2: using heckman command (ML Estimation)
heckman lwage educ exper exper2, select(nwifeinc age kidslt6 kidsge6)

*--------------------------------------------------
* Bonus 1: Drawing CDFs and PDFs
*--------------------------------------------------

*How can we draw CDFs and PDFs in Stata?
gen Z=rnormal(0) 
/* this generates a normal random variable, you could also
generate a uniform using ‘gen Z=runiform(-3,3)’*/

*CDF
* the distribution used for logit is called LOGISTIC
gen Z_cdf_logit=1/(1+exp(-Z)) 
gen Z_cdf_probit=normal(Z) 
sort Z 
line Z_cdf_logit Z||line Z_cdf_probit Z 

*PDF
gen Z_pdf_logit=exp(-Z)/(1+exp(-Z))^2
gen Z_pdf_probit=normalden(Z)
sort Z
line Z_pdf_logit Z||line Z_pdf_probit Z

*--------------------------------------------------
* Bonus 2: Taking Random Subsample
*--------------------------------------------------

*for 1.5
*We are going to take a random sub-sample. To make results replicable, I want to always make
*the exact same random draw. To achieve that, I will set a seed so that the "random" number
*generator always begins with the same draw.
	set seed 01010101
*We make random draws from a uniform distribution (0,1) to assign to each observation
	generate rand_draw = runiform()
*We will sort our observations from smallest to largest and take the first "n". This is
*how I randomize our sample of size "n", in this case n=5. That is, I randomly assign the number
* one to some observations. 
	sort rand_draw
	generate subsample_ = _n <= 5

	*Check https://www.stata.com/support/faqs/statistics/random-samples/ for the procedure


*--------------------------------------------------
log close // Close the log, end the file

exit

/* Lose ends

1. Why not using robust for heckman?

*/
