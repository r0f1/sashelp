
%macro export_excel(dataset, keep=, where=, drop=, folder=, filename=, retain_formats=T);

    %local excelpath formatcodes;
    %let excelpath = %sysfunc(catx(/,%sysfunc(dequote(&folder.)),%sysfunc(dequote(&filename.))));

    data _tmp_reduced; 
    	set &dataset;
    	%if %length(&where)>0 %then if    &where%str(;);
    	%if %length(&keep)>0  %then keep  &keep%str(;);
    	%if %length(&drop)>0  %then drop  &drop%str(;);
    run;

    %if %upcase(&retain_formats)=T %then %do;

		proc sql noprint;
			create table _tmp_vars as
			select name, format from dictionary.columns
			where libname="WORK" and memname="_TMP_REDUCED";
		quit;

		data _tmp_vars;
			set _tmp_vars end=last;
			length formatcode $400.;
			if format ^="" then formatcode=catx(" ",cats("put","(",name,",",format,")"), "as",name,",");
			else 				formatcode=cats(name,",");
			if last then 		formatcode=substr(formatcode,1,length(formatcode)-1);
		run;

		%let formatcodes=;
		data _null_;
			set _tmp_vars;
			call symput('formatcodes', trim(resolve('&formatcodes.')||' '|| trim(formatcode)));
		run;

		proc sql noprint;
			create table _tmp_export as select &formatcodes. from _tmp_reduced;
		quit;
	 
	 	data _tmp_reduced; set _tmp_export; run;

 	%end;

    proc export data=_tmp_reduced outfile="&excelpath." dbms=xlsx replace;
    run;

    proc datasets nolist; delete _tmp_:; quit; run;

%mend;
