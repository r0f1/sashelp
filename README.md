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