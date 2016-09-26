# Useful SAS code


## Exploratory data analysis

    %let constant_vars = height;
    %let dynamic_vars  = bmi n_cigarettes alc_grams;
  
    proc means nolabels data=alldat n nmiss mean median min p1 q1 q3 p99 max std; 
    	var &constant_vars;
    	where period=1;
    run;

    proc means nolabels data=alldat n nmiss mean median min p1 q1 q3 p99 max std; 
    	var &dynamic_vars;
    	class period;
    run;

	proc freq data=alldat;
		tables &vars;
	run;

	proc mi data=alldat nimpute=0;
		var &vars;
		ods select misspattern;
	run;


## Grouping of variables with zero occurences

    proc freq data=alldat; 
        tables diagnosis*year*gender*agegroup / noprint out=alldat_grouped;
    run;

    data alldat_grouped;
        set alldat_grouped;
        one=1;
    run;

    proc summary data=alldat_grouped nway completetypes;
        class diagnosis year gender agegroup;
        freq count;
        var one;
        output out=final_grouped(drop=_:_) n=n;
    run;

See also [here](http://www.ats.ucla.edu/stat/sas/faq/zero_cell_freq.htm).