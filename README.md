# are256b-w23
ARE 256B Winter 2023 TA Sections

## Week 1 - Jan 13
### Announcements
- Mahdi OHs: Wednesdays from 12h30 to 13h30 at SSH 2143.  
- office: SSH 2158, email: mashams[at]ucdavis[dot]edu
### Access to Stata
- option 1
	- https://stata-support.ucdavis.edu/
  
- option 2
	- https://virtuallab.ucdavis.edu/

### Commands
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
### Commands
- reg // regression (linear model)
- probit, logit // logit and probit (non-linear models)
- margins
- //using RMSE to compare models
- est //making tables and outputting them
	- eststo http://repec.org/bocode/e/estout/eststo.html
	- esttab http://repec.org/bocode/e/estout/esttab.html
- graph export
- log //making log files

## Week 3 -- Jan 27
### Commands
- tobit // censored data
- heckman // sample selection

### Sample Selection? Censored Data? What is the difference?  

From Hansen on censored data
> The idea of censoring is that some data above or below a threshold are mis-reported at the threshold. ... An example of a data collection censoring is top-coding of incomes. In surveys, incomes above a threshold are typically reported at the threshold.

Hansen on sample selection
> The problem of sample selection arises when the sample is non-random selection of potential observations. ... For example, if you ask for volunteers for an experiment, and they wish to extrapolate the effects of the experiment on a general population, you should worry that the people who volunteer may be systematically different from the general population.

[Xiang Ao on the difference between censored data and sample selection](https://www.hbs.edu/research-computing-services/Shared%20Documents/Training/censored_selected_truncated.pdf) 
> ... The problem of sample selection arises when no observations have been systematically excluded but some information has been suppressed, just like censoring. However, in sample selection problems, we have information on how the “selection” happens. In censoring, usually a constant “threshold” is set. Observations on dependent variable for those above (or below) that criteria are missing. Using the income example again, the threshold is set to be $20000, we have no information on exactly how much their income is for those whose income below the limit (only thing we know is that it’s lower than $20,000 per year). When we have a third variable that determines the censoring situation, then we call it sample selection. For example, we have observed only union member’s information on income, but we observe information on education for everybody, including union members or non-members. In this example, union membership is an additional variable that “selects” the sample which are involved in the estimation of effect of education on income.

and this beautiful table from Richard Breen

| Sample           | Y                                                                                                                                               | X                                                                           | Example                                                                                                                                                             |   |
|------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|---|
| Censored         | $y_i$ is known exactly if some criterion defined in terms of y is met.                                                                              | X variables are observed for the entire sample                              | Determinants of income; income is measured exactly only if it is above the poverty line. All other incomes are reported at the poverty line (the lower threshold). |   |
| Sample Selection | $y_i$ is observed only if a criteria defined in terms of some other random variables (B) is met (e.g. In our example, the criteria is employment status). | We observe the determinants of $B_i$ (which we call by Q) for the entire sample.  | Survey data with item or unit non-response                                                                                                                          |   |


## Week 4 - Feb 03

### Commands/coding
- Macros (local, global)
- Loops
- Some bonus hints for HW 2

## Week 5 - Feb 10
MT 2022 Review

## Week 6
MT 2023 Feedback

## Week 7
Intro to time-series

## Week 8
Time-series with a focus on HW3

## Week 9
Time-series with a focus on FE and RE (HW4)

We'll not cover:
- time trend
- random walk
- spurious regression


## Week 10
Final prep