# Useful SAS code


## Exploratory data analysis

    %let vars=bmi smoking alcohol;
  
    proc means data=alldat n nmiss mean median min p1 q1 q3 p99 max std; 
    	var &vars;
    run;

	proc freq data=alldat;
		tables &vars;
	run;

	proc mi data=alldat nimpute=0;
		var &vars;
		ods select misspattern;
	run;