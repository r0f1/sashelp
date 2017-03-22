* macro for adding medians to already existing groups in the dataset ;
* e.g. these groups can be quantiles created by a proc freq call ;

%macro add_medians(data=, var=, by=, out=);

	%if %length(&out)>0 %then
		%let dsout = &out.;
	%else 
		%let dsout = &data.;

	proc sql noprint;
		create table _tmp_ as
			select &by., median(&var.) as &var._median
			from &data.
			group by &by.;
	quit; run;

	data _tmp_;
		set _tmp_;
		if &by. ne .;
	run;

	proc sort data=&data. out=&dsout.;
		by &by.;
	run;

	data &dsout.;
		merge &dsout.(in=a) _tmp_;
		by &by.;
		if a;
	run;

	proc datasets nolist; 
		delete _tmp_; 
	quit; run;

%mend;
