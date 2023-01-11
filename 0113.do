*==============================================================================
*ARE 256B SECTION 1
*Date: Jan 7th, 2022

*Stata Warm up by Zhiran
*==============================================================================

*********************************************
*****part1:import data & basic commands******
*********************************************
clear all
set more off

*change working directory (use asterix to comment)
*cd "C:\Users\ZHIRAN\iCloudDrive\Documents\Stata\256B2022\Discussion1"
*cd "\\tsclient\Documents\Stata\256B2022\Discussion1"

cd "\\tsclient\Documents\Stata\256B2022\Discussion1"


cd "/Users/c/Documents/Stata/256B2022/Discussion1/"

/*import data from dta or xls files
show how to use the menu bar (foward slash & asterix)*/
use EAWE01.dta, clear
import excel "EAWE01.xlsx", sheet("EAWE01") firstrow clear

save EAWE.dta
*Gives info about variable type
describe
help describe
d

*browse the dataset
browse
br ASVABAR
sort ASVABAR

*operators:  ==, <, >, <=, >=, !=	
* | is "or".
* & is "and".	
*Example
browse ASVABAR EDUCMAST MALE if EDUCMAST==1
browse ASVABAR EDUCMAST MALE if EDUCMAST==1&MALE==1

*Count how many observations satisfy a condition
count if ASVABAR>0

*Summary statistcs
sum
sum HEIGHT EDUCMAST AGE MARRIED, detail
tabulate ASVABC

*Create a binary variable for high-school graduation (Yi ) in Stata
gen grad=0
replace grad=1 if S>11


*Eliminate a variable
drop MALE
keep grad ASVABC


*==============================================================================


*********************************************
*****part2: Regression & Scatter ************
*********************************************

*Perform a linear regression of grad (Yi ) on ASVABC (Xi )
reg grad ASVABC
reg grad ASVABC,robust

*Create a scatter plot in Stata
scatter grad ASVABC
plot grad ASVABC

*Create a Scatter Plot with Linear Regression
help scatter

/*Being a plottype, scatter may be combined with other plottypes in the 
 twoway family, as in, 
        . twoway (scatter ...) (line ...) (lfit ...) ...
    which can equivalently be written as
        . scatter ... || line ... || lfit ... || ...
*/
scatter grad ASVABC || lfit grad ASVABC
twoway lfit grad ASVABC


*==============================================================================


*********************************************
*****part3: Logit & Probit ************
*********************************************


*How can we draw CDFs and PDFs in Stata?
gen Z=rnormal(0) 
/* this generates a normal random variable, you could also
generate a uniform using ‘gen Z=runiform(-3,3)’*/

*CDF
gen Z_cdf_logit=1/(1+exp(-Z)) 
gen Z_cdf_probit=normal(Z) 
sort Z 
line Z_cdf_logit Z||line Z_cdf_probit Z 

*PDF
gen Z_pdf_logit=exp(-Z)/(1+exp(-Z))^2
gen Z_pdf_probit=normalden(Z)
sort Z
line Z_pdf_logit Z||line Z_pdf_probit Z

*models
logit grad ASVABC
probit grad ASVABC
