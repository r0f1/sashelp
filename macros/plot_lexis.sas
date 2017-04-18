/*
Plots a series plot, based on one x axis and several y axes.

%plot_lexis(
	dataset=alldat,
	where=agegrp ge 3,
	y_columns=mort_rate_men inc_rate_men,
	x_column=cohort, by=agegrp,
	legend=Mortality Incidence,
	datalabel=period_midpoint,
	xlabel="Year of Birth",
	ylabel="Age-Adjusted Rate per 100.000",
	title="Austria", 
	title2="Age-Adjusted Rates by Birth Cohorts",
	folder=&outpath.,
	filename="cancer_rates_men", 
	height=720px,
	greyscale=F,
	log=1
);		

*/

%macro plot_lexis(
	dataset=, where=, keep=, drop=,
	x_column=, y_columns=,
	by=, datalabel=,
	xlabel=, ylabel=, ymin=, ymax=,
	legend=, title=, title2=, 
	folder=, filename=, height=720px, greyscale=F,
	log=1);



    data _tmp_1; 
    	set &dataset;
    	%if %length(&where)>0 %then if    &where%str(;);
    	%if %length(&keep)>0  %then keep  &keep%str(;);
    	%if %length(&drop)>0  %then drop  &drop%str(;);
    run;

    proc sql noprint;
    	select count(distinct(&by.)) into :n from _tmp_1;
    quit; run;

	%if &greyscale.=T %then %do; 
		%if &n.=1 %then %do; %let colors = GRAY00; %end;
		%if &n.=2 %then %do; %let colors = GRAY00 GRAY20; %end;
		%if &n.=3 %then %do; %let colors = GRAY00 GRAY20 GRAY40; %end;
		%if &n.=4 %then %do; %let colors = GRAY00 GRAY20 GRAY40 GRAY60; %end;
		%if &n.=5 %then %do; %let colors = GRAY00 GRAY20 GRAY40 GRAY60 GRAY80; %end;
		%if &n.=6 %then %do; %let colors = GRAY00 GRAY20 GRAY40 GRAY60 GRAY80 GRAYA0; %end;
		%if &n.=7 %then %do; %let colors = GRAY00 GRAY20 GRAY40 GRAY60 GRAY80 GRAYA0 GRAYC0; %end;
		%if &n.=8 %then %do; %let colors = GRAY00 GRAY20 GRAY40 GRAY60 GRAY80 GRAYA0 GRAYC0 GRAYE0; %end;
		%if &n.=9 %then %do; %let colors = GRAY00 GRAY20 GRAY40 GRAY60 GRAY80 GRAYA0 GRAYC0 GRAYE0 GRAYF0; %end;
	%end;
	%else %do;
		%if &n.=1 %then %do; %let colors = CXE41A1C; %end;
		%if &n.=2 %then %do; %let colors = CXE41A1C CX377EB8; %end;
		%if &n.=3 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A; %end;
		%if &n.=4 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A CX984EA3; %end;
		%if &n.=5 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A CX984EA3 CXFF7F00; %end;
		%if &n.=6 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A CX984EA3 CXFF7F00 CXFFFF33; %end;
		%if &n.=7 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A CX984EA3 CXFF7F00 CXFFFF33 CXA65628; %end;
		%if &n.=8 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A CX984EA3 CXFF7F00 CXFFFF33 CXA65628 CXF781BF; %end;
		%if &n.=9 %then %do; %let colors = CXE41A1C CX377EB8 CX4DAF4A CX984EA3 CXFF7F00 CXFFFF33 CXA65628 CXF781BF CX999999; %end;
	%end;

	title &title.;
	title2 &title2.;

	ods listing style=statistical gpath=&folder.; 
	ods graphics on / reset=all border=off 
				      imagename=&filename. 
					  height=&height.
					  attrpriority=color;

	proc sgplot data=_tmp_1 noautolegend; 
		xaxis grid type=discrete fitpolicy=thin label=&xlabel.;

		yaxis grid minor label=&ylabel. 
			%if %length(&ymin.)>0 %then %do; min=&ymin. %end;
			%if %length(&ymax.)>0 %then %do; max=&ymax. %end;

			%if &log.>0 %then %do; 
				type=log logbase=10 logstyle=logexpand 
			%end;
		;
		
		styleattrs 
			datacontrastcolors=(&colors) datalinepatterns=(solid dash);
	
		%let c=1;
		%do %while(%scan(&y_columns, &c) ne %str());
			%let column = %scan(&y_columns, &c);
			%let name   = %scan(&legend, &c);

			series x=&x_column. y=&column. / 
					group=&by.
					markers markerattrs=(symbol=circlefilled size=7) 
					lineattrs=(thickness=3)
					name="&name."
				%if %length(&datalabel.)>0 and &c.=1 %then %do; 
					datalabel=&datalabel.
				%end;
			;
			keylegend "&name." / title="&name." down=10 position=right;

			%let c = %eval(&c+1);
		%end;
	run;

	ods _all_ close;

	title "";
	title2 "";

	
	proc datasets nolist nowarn nodetails; 
		delete _tmp_1;
	quit; run;
	

%mend;
