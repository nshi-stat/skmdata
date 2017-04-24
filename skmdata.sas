/********************************************************
 The %skmdata macro

 A SAS macro for the Kaplan-Meier plot with SGPLOT
 Procedure


 Copyright (c) 2016-2017 Kengo NAGASHIMA

 This software is released under the MIT License,
 see <http://opensource.org/licenses/mit-license.php>.
********************************************************/

/********************************************************
 Author: Kengo NAGASHIMA
 Version: 1.1.2
 Last Updated Date: Mar. 23, 2017
 System Requirements: SAS 9.4 or later, base SAS,
                      SAS/STAT 14.1 or later

 v1.1.2: fixed a bug: wrong no at risk of the last time
         point may be produced, if data is sparse
 v1.1.1: fixed a bug: caused by tie data
         (thanks to Masashi Mikami)
 v1.1.0: extended for competing risk
 v1.0.2: fixed a bug: missing at risk sizes
 v1.0.1: fixed a bug: caused by censored observations
 v1.0.0: first release
********************************************************/

/********************************************************
 Arguments
  data: input dataset name
  time: time variable
  event: event variable
  group: group variable
  censor_value: code value of censored observations
  out: output dataset name
  timemax: maximum time for no. at risk order
  timeby: increment of the sequence for no. at risk order

  * If you want to analyze competing risk data
  event_value: code value of competing risk events
********************************************************/

/********************************************************
 Variables in the output data
  time: time
  strata: group
  est: estimated survival function or cif
  lcl: lower confidence limit
  ucl: upper confidence limit
  left: raw no at risk
  atrisk: no. at risk table
  xatrisk: x-axis variable for no. at risk table

  * if argument 'event_value' is specified.
  adjleft: raw adjusted no at risk
  adjatrisk: variable of adjusted no at risk table
********************************************************/

%macro skmdata(data, time, event, group,
  censor_value, out, timemax, timeby, event_value =);
%if "&group." = "" %then %do;
data _adata_;
  set &data.;
  _grp_ = 1;
%let group = _grp_;
%end;
%else %do;
data _adata_;
  set &data.;
%end;
run;

%if "&event_value." = "" %then %do;
ods graphics off;
proc lifetest data = _adata_ outsurv = _sdata_;
  time &time.*&event.(&censor_value.);
  strata &group.;
  ods output ProductLimitEstimates = _ple_;
run;
ods graphics on;
proc sort data = _sdata_; by stratum &time.;
proc sort data = _ple_; by stratum &time.;
data _sdata_;
  merge _sdata_ _ple_;
  by stratum &time.;
data _sdata_;
  set _sdata_;
  by stratum &time.;
  retain est lcl ucl .;
  if survival ^= . then est = survival;
  else survival = est;
  if sdf_lcl ^= . then lcl = sdf_lcl;
  else sdf_lcl = lcl;
  if sdf_ucl ^= . then ucl = sdf_ucl;
  else sdf_ucl = ucl;
  if _censor_ = 1 then ycensor = survival;
  else ycensor = .;
  if last.stratum then do;
    output;
    est = .; lcl = .; ucl = .;
  end;
  else output;
  rename &time. = time &group. = strata;
  keep &time. &group. stratum est lcl ucl ycensor left;
proc datasets lib = work;
  delete _ple_;
run; quit;
%end;
%else %do;
ods graphics off;
proc lifetest data = _adata_ outcif = _sdata_;
  time &time.*&event.(&censor_value.) / eventcode = &event_value.;
  strata &group.;
run;
ods graphics on;
proc sort data = _sdata_; by stratum &time.;
data _sdata_;
  merge _sdata_;
  by stratum &time.;
  retain left adjleft .;
  if censored > 0 then ycensor = cif;
  else ycensor = .;
  if first.stratum then do;
    left = atrisk;
    adjleft = atrisk;
  end;
  else do;
    left = left - alleventtypes - censored;
    adjleft = adjleft - event - censored;
  end;
  rename &time. = time &group. = strata cif = est
    cif_lcl = lcl cif_ucl = ucl;
  keep &time. &group. stratum cif cif_lcl cif_ucl
    ycensor left adjleft;
run;
%end;
proc sort data = _sdata_; by stratum time;
data _atrisk_;
  set _sdata_;
  by stratum time;
  retain tmax 0;
  do _x_ = 0 to &timemax. by &timeby.;
    if time = 0 then do; output; leave; end;
    else if time < _x_ then do; output; leave; end;
    else if time >= &timemax. & tmax = 0 then do;
      _x_ = &timemax. + 1; tmax = 1; output; leave;
    end;
  end;
  if last.stratum then tmax = 0;
data _atrisk_;
  set _atrisk_; by stratum _x_;
  if last._x_ then output;
data _atriskd_;
  set _atrisk_; by stratum;
  if first.stratum then do;
    do _x_ = 0 to &timemax. by &timeby.;
      output;
    end;
  end;
  keep stratum _x_ strata;
data _atrisk_;
  merge _atrisk_ _atriskd_;
  by stratum _x_;
proc sort data = _atrisk_; by stratum descending _x_;
data _atrisk_;
  set _atrisk_;
  by stratum;
  retain tleft .;
  if left = . & tleft = . then left = 0;
  else if left ^= . then tleft = left;
  if last.stratum then tleft = .;
  drop tleft;
proc sort data = _atrisk_; by stratum _x_;
data _atrisk_;
  merge _atrisk_ _atriskd_;
  by stratum _x_;
  retain tleft adjtleft .;
  if left ^= . then tleft = left;
  else if left = . then left = tleft;
  if last.stratum then tleft = .;
  if _x_ <= &timemax. then output;
  %if "&event_value." = "" %then %do;
    keep _x_ left strata;
    rename _x_ = xatrisk left = atrisk;
    label left = "No. at risk";
  %end;
  %else %do;
    if adjleft ^= . then adjtleft = adjleft;
    else if adjleft = . then adjleft = adjtleft;
    if last.stratum then adjtleft = .;
    keep _x_ left adjleft strata;
    rename _x_ = xatrisk left = atrisk adjleft = adjatrisk;
    label left = "No. at risk" adjleft = "Adjusted no. at risk";
  %end;
data &out.;
  set _sdata_ _atrisk_;
  drop stratum;
proc datasets lib = work;
  delete _adata_ _sdata_ _atrisk_ _atriskd_;
run; quit;
%mend;
