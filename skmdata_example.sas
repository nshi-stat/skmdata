option linesize = 100 pagesize = 9999 formdlim = '-' mprint;

%let execpath = " ";
%let Path = " ";
%macro setexecpath;
  %let execpath = %sysfunc(getoption(sysin));
  %if %length(&execpath) = 0 %then
    %let execpath = %sysget(sas_execfilepath);
  data _null_;
    do i = length("&execpath") to 1 by -1;
      if substr("&execpath", i, 1) = "\" then do;
        call symput("Path", substr("&execpath", 1, i));
        stop;
      end;
    end;
  run;
%mend setexecpath;
%setexecpath;

%inc "&Path.skmdata.sas";

proc format;
value fgroup 1 = "Placebo" 2 = "Active";
run;

data example;
  call streaminit(150306);
  length strata $20.;
  tc = 12;  /* time to termination */
  h1 = 0.15; n1 = 100;
  h2 = 0.07; n2 = 100;
  array h[*] h1-h2; array n[*] n1-n2;
  do group = 1 to 2;
    do i = 1 to n[group];
      time = rand('exponential') / h[group]; event = 1;
      /* termination */
      if time > tc then do; time = tc; event = 0; end;
      /* random censoring */
      if rand('Uniform') > 0.9 then do; event = 0; end;
     output;
    end;
  end;
  format group fgroup.;
  keep time event group;
run;



%let timemax = 12;
%let timeby = 2;

%skmdata(
  data         = example,
  time         = time,
  event        = event,
  group        = group,
  censor_value = 0,
  out          = outdat, 
  timemax      = &timemax.,
  timeby       = &timeby.
);

proc template;
define style styles.plotc;
parent = styles.listing;
style graphfonts from graphfonts / 
  'GraphDataFont' = ("Arial Unicode MS, <MTsans-serif>", 9pt)
  'GraphUnicodeFont' = ("<MTsans-serif-unicode>", 11pt)
  'GraphValueFont' = ("Arial Unicode MS, <MTsans-serif>", 11pt)
  'GraphLabel2Font' = ("Arial Unicode MS, <MTsans-serif>", 12pt)
  'GraphLabelFont' = ("Arial Unicode MS, <MTsans-serif>", 12pt)
  'GraphFootnoteFont' = ("Arial Unicode MS, <MTsans-serif>", 12pt)
  'GraphTitleFont' = ("Arial Unicode MS, <MTsans-serif>", 13pt, bold)
  'GraphTitle1Font' = ("Arial Unicode MS, <MTsans-serif>", 16pt, bold)
  'GraphAnnoFont' = ("Arial Unicode MS, <MTsans-serif>", 9pt);
style GraphData1 from GraphData1 /
  color = cxE41A1C contrastcolor = cxE41A1C linestyle = 1;
style GraphData2 from GraphData2 /
  color = cx377EB8 contrastcolor = cx377EB8 linestyle = 1;
end;
run;



ods graphics on / height = 18cm width = 24cm imagename = "skmdata_outside"
  outputfmt = png reset = index;
ods listing gpath = "&Path." image_dpi = 300 style = plotc;
proc sgplot data = outdat;
  step x = time y = est /
    group = strata lineattrs = (thickness = 2 pattern = 1) name = "legend";
  scatter x = time y = ycensor /
    group = strata markerattrs = (symbol = neelde size = 15);
  band x = time lower = lcl upper = ucl /
    group = strata type = step transparency = 0.8;
  symbolchar name = neelde char = '2759'x / voffset = .25;
  xaxistable atrisk /
    x = xatrisk class = strata title = "No. at risk" location = outside;
  keylegend "legend" /
    across = 1 location = inside position = topright opaque;
  xaxis grid label = "Months after randomization" min = 0 max = &timemax.
    values = (0 to &timemax. by &timeby.);
  yaxis grid label = "Overall survival" min = 0 max = 1;
run;



ods graphics on / height = 18cm width = 24cm imagename = "skmdata_inside"
  outputfmt = png reset = index;
ods listing gpath = "&Path." image_dpi = 300 style = plotc;
proc sgplot data = outdat;
  step x = time y = est /
    group = strata lineattrs = (thickness = 2 pattern = 1) name = "legend";
  scatter x = time y = ycensor /
    group = strata markerattrs = (symbol = neelde size = 15);
  band x = time lower = lcl upper = ucl /
    group = strata type = step transparency = 0.8;
  symbolchar name = neelde char = '2759'x / voffset = .25;
  xaxistable atrisk /
    x = xatrisk class = strata title = "No. at risk" location = inside;
  keylegend "legend" /
    across = 1 location = inside position = topright opaque;
  xaxis grid label = "Months after randomization" min = 0 max = &timemax.
    values = (0 to &timemax. by &timeby.);
  yaxis grid label = "Overall survival" min = 0 max = 1;
run;



ods graphics on / height = 18cm width = 24cm imagename = "skmdata_outside_noci"
  outputfmt = png reset = index;
ods listing gpath = "&Path." image_dpi = 300 style = plotc;
proc sgplot data = outdat;
  step x = time y = est /
    group = strata lineattrs = (thickness = 2 pattern = 1) name = "legend";
  scatter x = time y = ycensor /
    group = strata markerattrs = (symbol = neelde size = 15);
  symbolchar name = neelde char = '2759'x / voffset = .25;
  xaxistable atrisk /
    x = xatrisk class = strata title = "No. at risk" location = outside;
  keylegend "legend" /
    across = 1 location = inside position = topright opaque;
  xaxis grid label = "Months after randomization" min = 0 max = &timemax.
    values = (0 to &timemax. by &timeby.);
  yaxis grid label = "Overall survival" min = 0 max = 1;
run;



ods graphics on / height = 18cm width = 24cm imagename = "skmdata_inside_noci"
  outputfmt = png reset = index;
ods listing gpath = "&Path." image_dpi = 300 style = plotc;
proc sgplot data = outdat;
  step x = time y = est /
    group = strata lineattrs = (thickness = 2 pattern = 1) name = "legend";
  scatter x = time y = ycensor /
    group = strata markerattrs = (symbol = neelde size = 15);
  symbolchar name = neelde char = '2759'x / voffset = .25;
  xaxistable atrisk /
    x = xatrisk class = strata title = "No. at risk" location = inside;
  keylegend "legend" /
    across = 1 location = inside position = topright opaque;
  xaxis grid label = "Months after randomization" min = 0 max = &timemax.
    values = (0 to &timemax. by &timeby.);
  yaxis grid label = "Overall survival" min = 0 max = 1;
run;






data example2;
  call streaminit(150306);
  length strata $20.;
  tc = 12;  /* time to termination */
  h1 = 0.15; n1 = 100;
  h2 = 0.07; n2 = 100;
  array h[*] h1-h2; array n[*] n1-n2;
  do group = 1 to 2;
    do i = 1 to n[group];
      time = rand('exponential') / h[group]; event = 1;
      if event = 1 then do;
        if group = 1 & rand('Bernoulli', 0.2) = 1 then event = 2;
        if group = 2 & rand('Bernoulli', 0.5) = 1 then event = 2;
      end;
      /* termination */
      if time > tc then do; time = tc; event = 0; end;
      /* random censoring */
      if rand('Uniform') > 0.9 then do; event = 0; end;
     output;
    end;
  end;
  format group fgroup.;
  keep time event group;
run;


%let timemax = 12;
%let timeby = 2;

%skmdata(
  data         = example2,
  time         = time,
  event        = event,
  group        = group,
  censor_value = 0,
  event_value  = 1,
  out          = outdatcmp, 
  timemax      = &timemax.,
  timeby       = &timeby.
);

proc template;
define style styles.plotc;
parent = styles.listing;
style graphfonts from graphfonts / 
  'GraphDataFont' = ("Arial Unicode MS, <MTsans-serif>", 9pt)
  'GraphUnicodeFont' = ("<MTsans-serif-unicode>", 11pt)
  'GraphValueFont' = ("Arial Unicode MS, <MTsans-serif>", 11pt)
  'GraphLabel2Font' = ("Arial Unicode MS, <MTsans-serif>", 12pt)
  'GraphLabelFont' = ("Arial Unicode MS, <MTsans-serif>", 12pt)
  'GraphFootnoteFont' = ("Arial Unicode MS, <MTsans-serif>", 12pt)
  'GraphTitleFont' = ("Arial Unicode MS, <MTsans-serif>", 13pt, bold)
  'GraphTitle1Font' = ("Arial Unicode MS, <MTsans-serif>", 16pt, bold)
  'GraphAnnoFont' = ("Arial Unicode MS, <MTsans-serif>", 9pt);
style GraphData1 from GraphData1 /
  color = cxE41A1C contrastcolor = cxE41A1C linestyle = 1;
style GraphData2 from GraphData2 /
  color = cx377EB8 contrastcolor = cx377EB8 linestyle = 1;
end;
run;


ods graphics on / height = 18cm width = 24cm imagename = "skmdata_inside_cmprisk"
  outputfmt = png reset = index;
ods listing gpath = "&Path." image_dpi = 300 style = plotc;
proc sgplot data = outdatcmp;
  step x = time y = est /
    group = strata lineattrs = (thickness = 2 pattern = 1) name = "legend";
  scatter x = time y = ycensor /
    group = strata markerattrs = (symbol = neelde size = 15);
  band x = time lower = lcl upper = ucl /
    group = strata type = step transparency = 0.8;
  symbolchar name = neelde char = '2759'x / voffset = .25;
  xaxistable atrisk /
    x = xatrisk class = strata title = "No. at risk" location = outside;
  keylegend "legend" /
    across = 1 location = inside position = topright opaque;
  xaxis grid label = "Months after randomization" min = 0 max = &timemax.
    values = (0 to &timemax. by &timeby.);
  yaxis grid label = "Cumulative incidence function" min = 0 max = 1;
run;



ods graphics on / height = 18cm width = 24cm imagename = "skmdata_inside_adjcmprisk"
  outputfmt = png reset = index;
ods listing gpath = "&Path." image_dpi = 300 style = plotc;
proc sgplot data = outdatcmp;
  step x = time y = est /
    group = strata lineattrs = (thickness = 2 pattern = 1) name = "legend";
  scatter x = time y = ycensor /
    group = strata markerattrs = (symbol = neelde size = 15);
  band x = time lower = lcl upper = ucl /
    group = strata type = step transparency = 0.8;
  symbolchar name = neelde char = '2759'x / voffset = .25;
  xaxistable adjatrisk /
    x = xatrisk class = strata title = "Adjusted no. at risk" location = outside;
  keylegend "legend" /
    across = 1 location = inside position = topright opaque;
  xaxis grid label = "Months after randomization" min = 0 max = &timemax.
    values = (0 to &timemax. by &timeby.);
  yaxis grid label = "Cumulative incidence function" min = 0 max = 1;
run;

