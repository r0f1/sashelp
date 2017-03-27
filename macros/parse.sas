/*************************************************************************************
SOURCE: http://www2.sas.com/proceedings/forum2008/104-2008.pdf

MACRO FUNCTION: %parse
AUTHOR: Jimmy Z. Zou
CREATED: 7/1/2003
REVISED: 5/30/2006 to make it work with Perl regular expressions.
DESCRIPTION:
This macro function is used to parse a variable list for any given SAS data set. The
variable list is either a conventional SAS variable list (like those used in data
steps and proc steps) or a Perl regular expression. The function returns a complete
list of variable names corresponding to the variable list. If an error occurs, the
function returns a missing value (null character). Optionally, the function saves the
number of variables in the list to a global variable specified by the user.
SYNTAX:
%Parse(dsn, varlist<,nvars>)
dsn - a SAS data set name.
varlist - a variable list to be parsed, in either one of the following two forms:
 (1) A conventional SAS variable list such as
 varlist = cd b03-b50 t -- f xy: _NUMERIC_ r-character-z
(2) A SAS Perl regular expression using / / as delimiter such as /^xy/.
nvars - optional parameter to specify the name of a global variable to hold the number
of variables returned.

EXAMPLES:
	data Example;
		length name $10 sex $1;
		length ID age month1-month5 b001-b020 8.;
		length State region ck1-ck5 $2;
	run;

	* Parse conventional variable lists;
	%let varlist=month3-month5 b006-b010 name region--ck2 s:;
	%put The variable names in varlist are: %parse(Example, &varlist);
	%put All variables in the data set are: %parse(Example, _ALL_);
	%put Char vars between age and region: %parse(Example, age-character-region);

	* Parse Perl regular expressions;
	%put The vars starting with s (case insensitive) are: %parse(Example, /^s/i);
	%put The variables ending with e are: %parse(Example, /e$/);
	%put The variables containing a digit 2 are: %parse(Example, /2/);
	%put The variables with two consecutive digits are: %parse(Example, /\d\d/);
	%put Variable names with length of 3 are: %parse(Example, /^.{3}$/); 

*************************************************************************************/ 


%macro parse(dsn, varlist, nvars);
	%local i j k _n_ word upword count d p p1 p2 name name1 name2 suffix1 suffix2 prefix namelist;
	%let dsid=%sysfunc(open(&dsn));
	%if not &dsid %then %do;
		%put %sysfunc(sysmsg());
		%goto Exit;
	%end;
	/* Get the total number of variables in dsn */
	%let _n_=%sysfunc(attrn(&dsid, nvars));
	%let count=0;
	/* If varlist is not a Perl regular expression... */
	%if not %index(&varlist, /) %then %do;
		/*
			Standardize the varlist:
			Removing extra blanks in varlist and group the variables into words.
		*/
		/* %let varlist=%cmpres(&varlist);*/
		%let varlist=%sysfunc(compbl(&varlist));
		%let varlist=%sysfunc(tranwrd(&varlist, %str( )-, -));
		%let varlist=%sysfunc(tranwrd(&varlist, -%str( ), -));
		/*
			Divide and Conquer:
			Set up a loop to extract the words in varlist one by one.
			Then parse each word to get the variable names.
		 */
		%let i=1;
		%do %until (%qscan(&varlist, &i, %str( ))=%str());
			%let word=%qscan(&varlist, &i, %str( )); 

			%let upword=%upcase(&word);
			%let p=%index(&word, --);
			/* Parse a word like t--f (name range variable list):
				1. Extract the beginning and ending variable names (name1 and name2 in
				the code below).
				2. Get the position numbers for name1 and name2 (p1 and p2 in the code
				below).
				3. Check errors.
				4. Update the counter (count)
				5. Get the names of the variables between name1 and name2:
				%sysfunc(varname(&dsid, j)) p1<= j <=p2
				6. Add the names to the namelist using a loop.
			*/
			%if &p %then %do;
				%let name1=%substr(&word, 1, &p-1);
				%let name2=%substr(&word, &p+2);
				%let p1=%sysfunc(varnum(&dsid,&name1));
				%let p2=%sysfunc(varnum(&dsid,&name2));
				%if &p1=0 | &p2=0 | (&p1 > &p2) %then %do;
					%put ERROR: Invalid variable list &word;
					%goto Exit;
				%end;
				%let count=%eval(&count+&p2-&p1+1);
				%do j=&p1 %to &p2;
					%let namelist=&namelist %sysfunc(varname(&dsid, &j));
				%end;
			%end;
			 /* Parse a word like ab: (name prefix variable list):
				1. Extract the prefix.
				2. Using a loop to compare the prefix with each variable name in the data
				set.
				3. If a name matches the prefix, add it to the namelist.
			 */
			 %else %if %index(&word, :) %then %do;
				%let prefix=%sysfunc(compress(&word, :));
				%do j=1 %to &_n_;
					%let name=%sysfunc(varname(&dsid, &j));
					%if (%length(&name) >= %length(&prefix)) & (%sysfunc(compare(&prefix, &name,:i))=0) %then %do;
						%let count=%eval(&count + 1);
						%let namelist=&namelist &name;
					%end;
				%end;
			 %end;
			 /* Parse special SAS Name lists: _ALL_, _NUMERIC_, or _CHARACTER_ */
			%else %if %sysfunc(indexw(_ALL_ _NUMERIC_ _CHARACTER_, &upword)) %then %do;
				%do j=1 %to &_n_;
				%if &upword=_ALL_ %then %do;
					%let namelist=&namelist %sysfunc(varname(&dsid, &j));
					%let count=%eval(&count + 1);
					%end;
					%else %if %sysfunc(vartype(&dsid, &j))=%substr(&upword,2,1)
					%then %do;
						%let namelist=&namelist %sysfunc(varname(&dsid, &j));
						%let count=%eval(&count + 1);
					%end;
				%end;
			%end;

			/* Parse a word like x-numeric-b or x-character-b */
			%else %if %index(&upword, -NUMERIC-) | %index(&upword, -CHARACTER-) %then %do;
				%let p=%index(&upword, -NUMERIC-);
				%let q=%index(&upword, -CHARACTER-);
				%if &p %then %do;
				%let name1=%substr(&upword, 1, &p-1);
				%let name2=%substr(&upword, &p+9);
				%let type=N;
			%end;
			%else %do;
				%let name1=%substr(&upword, 1, &q-1);
				%let name2=%substr(&upword, &q+11);
				%let type=C;
			%end;


			%let p1=%sysfunc(varnum(&dsid,&name1));
			%let p2=%sysfunc(varnum(&dsid,&name2));
			%if &p1=0 | &p2=0 | (&p1 > &P2) %then %do;
				%put ERROR: Invalid variable list &word;
				%goto Exit;
			%end;
			%do j=&p1 %to &p2;
				%if %sysfunc(vartype(&dsid, &j))=&type %then %do;
					%let namelist=&namelist %sysfunc(varname(&dsid, &j));
					%let count=%eval(&count + 1);
				%end;
			%end;
		%end;
		/* Parse a word like a1-a20 or b003-b152 (numbered range variables)*/
		%else %if %index(&word, -) %then %do;
			%let p=%index(&word, -);
			%let name1=%substr(&word, 1, &p-1);
			%let name2=%substr(&word, &p+1);
			%let k=%eval(%sysfunc(notdigit(&name1, -%length(&name1))) + 1);
			%let prefix=%substr(&name1,1, &k-1);
			%let suffix1=%substr(&name1,&k);
			%let suffix2=%substr(&name2,&k);

			%if %sysfunc(varnum(&dsid,&name1))=0 |
				%sysfunc(varnum(&dsid,&name2))=0 | (&suffix1>&suffix2) %then %do;
				%put ERROR: Invalid variable list &word;
				%goto Exit;
			%end;

			%let len=%length(&suffix1);
			%do j=&suffix1 %to &suffix2;
				%let d=%eval(&len-%length(&j));
				%if &d <=0 & %sysfunc(varnum(&dsid,&prefix&j)) %then %do;
					%let namelist=&namelist &prefix&j;
					%let count=%eval(&count + 1);
				%end;
				/* if &d>0 pad j with d leading 0s and save as jj */
				%else %do;
					%let jj=&j;
					%do k=1 %to &d;
						%let jj=0&jj;
					%end; 
					%if %sysfunc(varnum(&dsid,&prefix&jj)) %then %do;
						%let namelist=&namelist &prefix&jj;
						%let count=%eval(&count + 1);
					%end;
				%end;
			%end;
		%end;
		/* Parse a word like cd - just add it to the namelist */
		%else %if %sysfunc(varnum(&dsid,&word)) %then %do;
			%let count = %eval(&count + 1);
			%let namelist=&namelist &word;
		%end;
		/* An unrecognized word */
		%else %do;
			%put ERROR: Invalid variable name or list &word;
			%goto Exit;
		%end;

		%let i=%eval(&i+1);
		%end;
	%end;
	/* Parse a Perl regular expression */
	%else %do;
		%local pid;
		%let pid =%sysfunc(prxparse(&varlist));
		%if &pid=. %then %goto Exit;
		%else %if &pid %then %do j=1 %to &_n_;
			%let name=%sysfunc(varname(&dsid, &j));
			%if %sysfunc(prxmatch(&pid, &name)) %then %do;
				%let namelist=&namelist &name;
				%let count=%eval(&count + 1);
			%end;
		%end;
		%syscall prxfree(pid);
	%end;

	%let rc= %sysfunc(close(&dsid));

	%if &nvars ^= %then %do;
		%global &nvars;
		%let &nvars = &count;
	%end;

	&namelist
	%Exit:
%mend;