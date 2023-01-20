*--------------------------------------------------
*Title
*file_name.do
*1/20/2023
*Your name (and email adress)
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
log using file_name.txt, text replace      // Open log file
*--------------------------------------------------

*set working directory 
cd "path"

*open a .dta (Stata) file
*we use clear to reaplce the new dataset with the former one
use "datafile.dta", clear 

*--------------------------------------------------
* Question 1
*--------------------------------------------------

...

*--------------------------------------------------
* Question N
*--------------------------------------------------



*--------------------------------------------------
log close // Close the log, end the file

exit

