Helpful code pieces for common programming tasks.

### Preamples

```SAS
* delete entire work library to get a fresh start ;
proc datasets library=work kill nolist; 
quit; run;


* declare all the needed external file references *;
* include all macros and formats, set linesize, pagesize *;
filename scripts  '/path/to/my/scripts';
libname formats '/path/to/my/formats';

options mautosource sasautos=(scripts);
options fmtsearch=(formats);
options linesize=max pagesize=max nocenter replace;

libname vault '/path/to/my/filestorage';
filename tabl1 '/path/to/my/output/table1.sasoutput';
filename tabl2 '/path/to/my/output/table2.sasoutput';
```

### Macros

```SAS
* macro template: filter incoming dataset based on certain criteria ;
%macro my_macro(dataset=, where=, keep=, drop=);

	data _tmp_; 
		set &dataset;
		%if %length(&where)>0 %then if    &where%str(;);
		%if %length(&keep)>0  %then keep  &keep%str(;);
		%if %length(&drop)>0  %then drop  &drop%str(;);
	run;

	* more code goes here ;

	proc datasets nolist; 
		delete _tmp_:; 
	quit; run;

%mend;



* looping over values stored in macro variable separated by spaces ;
%let c = 1;
%do %while(%scan(&columns, &c) ne %str());
	%let column = %scan(&columns, &c);

	%put &column;

	%let c = %eval(&c+1);
%end;
```



