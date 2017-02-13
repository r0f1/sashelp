%macro lexis_table1(dataset=, out=, var=, by=, period=, prefix=period_);

	%let by2=%sysfunc(tranwrd(&by.,%str( ),%str(,)));
	proc sql noprint;
		create table _tmp_1 as 
			select &by2., &period., sum(&var.) as &var.
			from &dataset. 
			group by &by2., &period.
			order by &by2., &period.; 
	quit; run;

	proc transpose data=_tmp_1 out=&out. prefix=&prefix.;
		var &var.;
		by &by.;
	run;

	data &out;
		set &out;
		drop _name_;
	run;

	proc sort data=&out.; by &by.; run;

	proc datasets nolist; delete _tmp_:; quit; run;
		
%mend;
