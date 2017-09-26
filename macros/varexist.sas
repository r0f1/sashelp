/* Usage 

	%if %varexist(alldat,NAME)
	  %then %put input data set contains variable NAME;

*/
%macro varexist(ds,var);

	%local dsid rc ;

	%let dsid = %sysfunc(open(&ds));

	%if (&dsid) %then %do;
		%if %sysfunc(varnum(&dsid,&var)) %then 1;
		%else 0;
		%let rc = %sysfunc(close(&dsid));
	%end;
	%else 0;

%mend;