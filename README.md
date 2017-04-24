
# %skmdata macro


## Brief description

A SAS macro for the Kaplan-Meier plot with SGPLOT Procedure.

This software is released under the MIT License, see <http://opensource.org/licenses/mit-license.php>.


## Software information
- Author: Kengo NAGASHIMA
- Version: 1.1.2
- Last Updated Date: Mar. 23, 2017
- System Requirements: SAS 9.4 or later, base SAS, SAS/STAT 14.1 or may be later


## Version history
- v1.1.2: fixed a bug: wrong no at risk of the last time point may be produced, if data is sparse
- v1.1.1: fixed a bug: caused by tie data (thanks to Masashi Mikami)
- v1.1.0: extended for competing risk
- v1.0.2: fixed a bug: missing at risk sizes
- v1.0.1: fixed a bug: caused by censored observations
- v1.0.0: first release


## Example

![Kaplan-Meier; confidence interval + risk set (outside)](https://raw.githubusercontent.com/nshi-stat/skmdata/master/skmdata_outside.png)

![Kaplan-Meier; confidence interval + risk set (inside)](https://raw.githubusercontent.com/nshi-stat/skmdata/master/skmdata_inside.png)

![Kaplan-Meier; risk set (outside)](https://raw.githubusercontent.com/nshi-stat/skmdata/master/skmdata_outside_noci.png)

![Kaplan-Meier; risk set (inside)](https://raw.githubusercontent.com/nshi-stat/skmdata/master/skmdata_inside_noci.png)

![CIF plot; confidence interval + risk set (outside)](https://raw.githubusercontent.com/nshi-stat/skmdata/master/skmdata_inside_cmprisk.png)


## Usage
### Arguments
- data: input dataset name
- time: time variable
- event: event variable
- group: group variable
- censor_value: code value of censored observations
- out: output dataset name
- timemax: maximum time for no. at risk order
- timeby: increment of the sequence for no. at risk order

* If you want to analyze competing risk data

- event_value: code value of competing risk events

### Variables in the output data
- time: time
- strata: group
- est: estimated survival function or cif
- lcl: lower confidence limit
- ucl: upper confidence limit
- left: raw no at risk
- atrisk: no. at risk table
- xatrisk: x-axis variable for no. at risk table

* if argument 'event_value' is specified

- adjleft: raw adjusted no at risk
- adjatrisk: variable of adjusted no at risk table

