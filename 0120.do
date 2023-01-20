*--------------------------------------------------
*ARE 256B W23 -- SECTION 2
*0120.do
*1/20/2023
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the second week of ARE 256B. Here codes related to
* linear models, nonliniear models (probit), the way to compare models based on
* rmse is reviewed. Also, there is a discussion of how to make logfiles, exporting
* graphs, and outputting regression tables with estout package. 
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
log using 0120.txt, text replace      // Open log file
*--------------------------------------------------

*set working directory 
cd "C:\Users\mahdi\are256b-w23"

*open a .dta (Stata) file
*we use clear to reaplce the new dataset with the former one
use "data\EAWE01.dta", clear 

*--------------------------------------------------
*linear model
*--------------------------------------------------
*let us work with some linear probability models
*P(Y_i=1|X_i) = \beta X_i + \epsilon_i 
*Prob of finishing a bachelor's degree vs composite cognitive ability test

reg EDUCBA  ASVABC, robust

* calcualting the \hat{Y}_i = \hat{\beta}X_i for some values of X_i

sum ASVABC, detail

display 0.2566+0.1746*0.3341
display 0.2566+0.1746*1.9718
display 0.2566+0.1746*(-2.2188)

* alternative way to calculate the predicted probability
display _b[_cons]+_b[ASVABC]*0.3341
display _b[_cons]+_b[ASVABC]*1.9718
display _b[_cons]+_b[ASVABC]*(-2.2188)

*Does the last predicted probability make sense? No, it yields a negative probability

*let's find the fitted values for all the observations
*\hat{Y}_i = \hat{\beta}X_i
*command predict yields the fitted values for all the observations based on the "latest" model ran 
help predict
predict EDUCBA_hat, xb	

browse EDUCBA EDUCBA_hat

count if EDUCBA_hat>1
count if EDUCBA_hat<0
count if missing(EDUCBA_hat)

*Show the predicted probability graphically
twoway scatter EDUCBA_hat ASVABC
graph export outputs/linear.png

*--------------------------------------------------
*nonlinear model
*--------------------------------------------------

*let us move to non-linear probability models
*Non-linear probability models map the dependent variables using a function
*whose range lies between zero and one.

*PROBIT: The function used for mapping is the cumulative distribution
*of a normal.
*P(Y_i=1|X_i) = \Phi(\beta X_i + \epsilon_i) 

probit EDUCBA  ASVABC, robust 
*Compare results with Linear Probability Model

*--------------------------------------------------
	
*Computing marginal effects
*Look at Slides 68-69 for definitions
*Average Margnal Effect
margins, dydx(ASVABC)

*Marginal effects evaluated at the mean 
margins, dydx(ASVABC) atmeans
// alternative: mfx compute, dydx

*Marginal effects evaluated at a different point
margins, dydx(ASVABC) at(ASVABC=0.1)
margins, dydx(ASVABC) at(ASVABC=0.6)

*Predict Probability
*\hat{Y}_i = \Phi{\hat{\beta}X_i}

*calculating the predicted probability
h nlcom
h norm
*At 75 percentile
nlcom norm(_b[ASVABC]*0.8584 + _b[ _cons])
*At 1 percentile
nlcom norm(_b[ASVABC]*-2.2188 + _b[ _cons])

*Generate variable that predicts for every observation
predict EDUCBA_probit_hat
browse EDUCBA EDUCBA_hat EDUCBA_probit_hat
twoway (scatter EDUCBA_probit_hat ASVABC)

*--------------------------------------------------
*model comparison based on rmse
*--------------------------------------------------
*How do the models compare? (linear vs probit)
twoway (scatter EDUCBA_probit_hat ASVABC) (scatter EDUCBA_hat ASVABC) (scatter EDUCBA ASVABC)

*We use root mean squared error (rmse) concept to compare 
*rmse = sqrt{((1/n)*(\Sigma{(Y_i - \hat{Y_i})^2})}
* look at slide 65

gen sqerror        = (EDUCBA - EDUCBA_hat)^2
gen sqerror_probit = (EDUCBA - EDUCBA_probit_hat)^2


qui summarize sqerror 
di r(mean)^0.5

qui summarize sqerror_probit
di r(mean)^0.5

*--------------------------------------------------
*Cenosred data and the Tobit model
*--------------------------------------------------

*Censored Data Generation (Monte Carlo Method):
clear all
set obs 50
gen X=_n+10
gen U=rnormal(0,10)
gen Ystar=-40+1.2*X+U
gen Y= Ystar*(Ystar>0)

scatter Y X if Y>0 || lfit Y X if Y>0|| lfit Ystar X, ///
legend(label(1 "Y")  label(2 "Truncated Regression")  label(3 "True Regression Relationship") )

regress Y X if Y>0

*the truncated regression slope is biased (slide 77)
*one soltion is Tobit model
*ll() argument isleft-censoring limit i.e. we only observe Y_i > 0 in this regression. 
tobit Y X, ll(0)  robust


*--------------------------------------------------
*exporting tables
*--------------------------------------------------

*use estout to generate nice tables
ssc install estout, replace

*To create nice LATEX/Doc tables we can use this command
*If you do not want/need Latex output, just erase the commands.
eststo clear
eststo model_l: quietly regress EDUCBA  ASVABC, robust 
eststo model_p: quietly probit EDUCBA  ASVABC, robust 

esttab model_l


esttab model_l using outputs/model_l.rtf, replace ///
se onecell width(\hsize) ///
addnote() ///
label title(Estimation Reslt of Linear Model)

*--------------------------------------------------
 
log close // Close the log, end the file

exit

/*Loose Ends:
- drawing CDFs and PDFs in Stata? (Slide 41)
*/