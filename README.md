# Useful SAS code


## Exploratory data analysis


proc means

    proc means data=alldat n nmiss mean median min p1 q1 q3 p99 max std; 
    	var variable1 variable2;
    run;

