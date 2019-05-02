# PSM_sizing_model
Contents of project:
Months_Payable_Outstanding (Google Sheet) (Not in Dropbox)
mpo.csv
Financial_model_09_11.xlsx
IndiaProject_PSM.R
________________________________________

Months_Payable_Outstanding

https://docs.google.com/spreadsheets/d/1CGOaFlrWbCGbLCZHXGyc5MhO3xsVm_LtFbAhn84YHyI/edit#gid=1357456600

The google sheet contains 13 worksheets that primarily serve the purpose of documenting the calculation of Months Payable Outstanding for a given utility. Practically speaking, one must only download the ‘MPO’ tab for the data to evaluate PSM effects.

‘Utilities’ - This worksheet contains a list of all utilities, with links to a fully representative subset of sources used to review annual report statements for a utility. Included are the number of reports used (sample size N) and notes regarding the availability and format of data.

‘PD w/o PSM’ - This is a set of calculations for the probability of default for a given utility across all bond ratings. This assumes a P(cf<x) of 0.0267 as calculated in the document Financial_model_09_11.xlsx and computes P delay as p*(1-p)*P(cf<x) where p is the z-score for a utility and x is the annual debt service. Note that PD w/ PSM analysis is computed in R and therefore not included in the spreadsheet.

‘Z-Score/Ratings’ - This sheet includes the z-scores for all utilities and the probability of default associated with a given bond rating. Sources mentioned in sheet.

‘MPO’ - This is the master sheet containing the MPO for every year of available data for every utility in a single table. This contains the same data and is the cloud source for ‘MPO.csv’.

‘[Utility Name]’ - All remaining sheets are titled by utility and contain the raw inputs for MPO calculation. This includes the year, total current liabilities (accounts payable), cost of goods sold, days payable outstanding, months payable outstanding, frequency buckets (xi-1 < frequency(x) < xi), count (frequency), and corresponding relative frequency or probability. Note that these sheets contain embedded comments that make note of irregularities, inconsistencies or other details related to reporting format.

Mpo.csv

For the purposes of exporting data the mpo.csv is the document that is downloaded from the MPO worksheet in the master Months Payable Outstanding Google Sheet. 

Financial_model_09_11.xlsx

This spreadsheet, specifically “banks” worksheet, contains a financial model for a power producer. It is used to estimate the P(cf<x) due to resource availability. Here we assume that the cash flow (CF) model is a gaussian distribution and take the average cash flow across the 12 years for P(50) to be the mean/median cash flow for the random variable (Row 1, worksheet ‘P(CF<X)’). We use the standard normal inverse CDF of 0.90 to find a Z value, and then work backwards to get sigma for this random variable. Finally, we use sigma and the mean to compute the P(CF<X), with X being the PMT for the debt service, 653.94. The result is 0.0267.

The parameters used for P(50), P(90), etc. scenarios can be found in the first 50 rows of the spreadsheet in ‘banks’. Note that O&M expenses are omitted for the purpose of this exercise. 

IndiaProject_PSM.R

To compute the size of PSM required for a given bond rating for a given utility, one must use this R script. It takes mpo.csv as input (it is important to ensure that the mpo.csv file is in the Downloads folder of your system, unless you would like to change the directory, in which case the R code must be adjusted accordingly to facilitate import) and munges the data to an appropriate format for analysis. This includes performing linear interpolation across the data for a given utility to model a continuously discrete probability distribution (i.e. 1, 2 , 3 , 4 , 5). Note that in this instance the range of interpolation is confined to the minimum and maxim MPO’s reported in the history of a PSM (no buffer). The primary function to produce results is analyze(). The function takes a boolean paramter approxbool that if TRUE, will return the number of months of offtake guarantee required by a PSM, as computed by taking the most proximate probability to the bond rating requirement (e.g. if BBB requires p default of 0.057 and P(MPO=8) is 0.56 and P(MPO=9) is 0.60, the function will select MPO = 8 (delta = 0.1) as the necessary duration for PSM coverage). If approxbool is set to FALSE, the function will return the minimum duration that is greater than or equal to the bond rating p default (in this case 9). 

By running analyze() one will receive a list for each utility and the corresponding size of PSM, (i.e. months of coverage required, multiplied by the monthly debt service size) for each bond rating. Additionally, R will produce a series of barplots for each utility that illustrates the months of coverage required for each utility and each rating. If a bar is not visible that indicates that either the PSM coverage is 0 months, or that there is no ability for PSM to offset the resource availability risk of default, in the context of a large z-score. Overall, there is a high chance that the probability of insufficient resource is too large to meet any credit ratings, and therefore does not lend itself to assessing the benefit of a PSM. 

If one would like to perform individual analyses of probability of default for a given utility, with or without psm, please consult function pdef and pdef_psm. The former takes the utility name as its parameter, and the latter requires, utility name, rating_p (the desired risk of default), and approxbool. Please note that utility name must match the abridged names as listed in parameters: ("West Bengal","Gujarat","Eastern","Chamundeshwari", "Uttarakhand","Southern","Chattisgarh","Northern"). 




