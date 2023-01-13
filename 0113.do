*==============================================================================
*ARE 256B W23 -- SECTION 1
*Date: Jan 13th, 2023

*Mahdi Shams (mashams@ucdavis.edu)
* Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*==============================================================================

*********************************************
*****part1:import data & basic commands******
*********************************************
clear all
set more off

*change working directory (use asterix to comment)
cd "C:\Users\ZHIRAN\iCloudDrive\Documents\Stata\256B2022\Discussion2"

*How to open a .xlsx file
import excel "C:\Users\Armando\Box\Thumbdrive\UC Davis\ARE 256B\Datasets\Excel\EAWE01.xlsx", sheet("EAWE01") firstrow
	
*How to open a .dta (Stata) file
use "C:\Users\Armando\Box\Thumbdrive\UC Davis\ARE 256B\Datasets\Stata\EAWE01.dta", clear

*Data Description
*Show all variable names
ds
*Gives info about variable type
describe
*Allows user to see the dataset
browse
*Example
browse ASVABAR if EDUCMAST==1

codebook AGE

*Summary statistcs
sum
sum HEIGHT EDUCMAST AGE MARRIED, detail

tabulate ASVABC

tabulate AGE, summarize(ASVABC) means

*operators:  ==, <, >, <=, >=, !=	
* | is "or".
* & is "and".	

*Example
browse ASVABAR EDUCMAST MALE if EDUCMAST==1
browse ASVABAR EDUCMAST MALE if EDUCMAST==1&MALE==1


*Create a new variable
gen age_today = 2023-BYEAR

//using functions: log()
g ln_EARNINGS = log(EARNINGS)	
	
*Create a binary variable for high-school graduation (Yi ) in Stata
gen grad=0
replace grad=1 if S>11

	
*Eliminate a variable
drop age_today

*Count how many observations satisfy a condition
count if HEIGHT>68


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



//est

*use estout to generate nice tables
*ssc install estout, replace

*To create nice LATEX/Doc tables we can use this command
*If you do not want/need Latex output, just erase the commands.
eststo clear
eststo: quietly regress grad ASVABC, robust
eststo: quietly logit grad ASVABC
*Displays the .tex table in Stata
esttab, se ar2
*Exports the table in .tex format
esttab using "`my_path'q_1_1_reglinresults.tex", se ar2 replace
esttab using "`my_path'q_1_1_reglinresults.rtf", se ar2 replace



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
