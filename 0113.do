*==============================================================================
*ARE 256B W23 -- SECTION 1
*Date: Jan 13th, 2023

*Mahdi Shams (mashams@ucdavis.edu)
* Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*==============================================================================

*********************************************
*****part1:import data & basic commands******
*********************************************

// use doedit in order to open the dofile editor

clear all
set more off

*change working directory (use asterix to comment)
cd "C:\Users\mahdi\are256b-w23"

*How to open a .xlsx file
import excel "data\EAWE01.xlsx", sheet("EAWE01") firstrow 
//firstrow option:  treat first row of Excel data as variable names

browse // taking a look at data!
	
*How to open a .dta (Stata) file
use "data\EAWE01.dta", clear //we use clear to reaplce the new dataset with the former one

browse

*Data Description
*Show all variable names
ds
*Gives info about variable type
describe
*Allows user to see the dataset
browse
*Example
browse ASVABAR if EDUCMAST==1

codebook
codebook AGE

*Summary statistcs
sum
sum HEIGHT
sum HEIGHT EDUCMAST AGE MARRIED, detail

tabulate AGE
tabulate AGE, summarize(ASVABC) means

*operators:  ==, <, >, <=, >=, !=	
* | is "or".
* & is "and".	

sum ASVABC if AGE == 28
sum ASVABC if AGE != 28
sum ASVABC if AGE < 28


*Example
browse ASVABAR EDUCMAST MALE if EDUCMAST==1
browse ASVABAR EDUCMAST MALE if EDUCMAST==1&MALE==1


*Create a new variable
gen age_today = 2023-BYEAR
browse age_today

*using functions: log()
g ln_EARNINGS = log(EARNINGS)	
browse ln_EARNINGS EARNINGS
	
*Create a binary variable for high-school graduation (Yi ) in Stata
gen grad=0
replace grad=1 if S>11

browse S grad
	
*Eliminate a variable
drop age_today

*Count how many observations satisfy a condition
count if HEIGHT>68


*==============================================================================


*******************************
*****part2: Graphs ************
*******************************

//take a look at https://www.stata.com/support/faqs/graphics/gph/stata-graphs/

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


*main takeaway: use stata help to learn about command syntaxes, examples, and options as much as you can!
* either run (help "the command") or google (help "the command" stata)
