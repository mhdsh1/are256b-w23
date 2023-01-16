# are256b-w23
ARE 256B Winter 2023 TA Sections

## Week 1 - Jan 13
### Announcements
- Mahdi OHs: Wednesdays from 12h30 to 13h30 at SSH 2143.  

### Access to Stata
- option 1
	- https://stata-support.ucdavis.edu/
	- stata-support@ucdavis.edu
- option 2
	- https://virtuallab.ucdavis.edu/

### Coding
- cd // setting working directory
- ??? // importing data
- browse, describe, //
- //operators
- summ, tabulate, … // summary statistics
- gen //generating variable 
	- replace
	- drop
	- keep
	- using functions: log(x)

## Week 2 - Jan 20

On style: https://michaelshill.net/2015/07/31/in-stata-coding-style-is-the-essential/

On margins: https://www.princeton.edu/~otorres/Margins.pdf
### Coding
- reg // regression (linear model)
- probit, logit // logit and probit (non-linear models)
- margins
- //using RMSE to compare models
- tobit // censored data and tobit model
- est //making tables and outputting them
	- eststo http://repec.org/bocode/e/estout/eststo.html
	- esttab http://repec.org/bocode/e/estout/esttab.html
- graph export
- log //making log files
