/*
 * Verify a table exists and has the expected columns.
 * The first parameter is a space separated list of table names.
 * The second parameter is a space separated list of columns.
 * All the tables are expected to have the same columns.
 *
 * Example call: %verify_tables(alldat alldat2, firstname lastname state zipcode);
 *
 */

%macro verify_tables(tableList, expectedColumns);

	%let i = 1;
	%do %while(%scan(&tableList, &i) ne %str());
		%let table = %scan(&tableList, &i);

		%if %sysfunc(exist(&table))	%then %do;

			%let dsid=%sysfunc(open(&table,i));

			%if (&dsid = 0)	%then
				%put ERROR: opening &table: %sysfunc(sysmsg());

			%else %do;
				%let any=%sysfunc(attrn(&dsid, ANY));
				%if &any = -1 %then 
					%put ERROR: &table has no rows or columns.;

				%else %do;
					%if &any = 0 %then 
						%put WARNING: &table has 0 rows.;

					%let nrows = %sysfunc(attrn(&dsid, NOBS));

					%let problem = N;
					%let c = 1;
										
					%do %while(%scan(&expectedColumns, &c) ne %str());
						%let column = %scan(&expectedColumns, &c);
						%let varnum = %sysfunc(varnum(&dsid,&column));
						%if &varnum <= 0 %then %do;
							%put ERROR: Expected column &column in &table but it was not found.;
							%let problem = Y;
						%end;
						%let c = %eval(&c+1);
					%end;
					%if &problem = N %then 
						%put NOTE: &table exists, has the expected variables and &nrows rows.;
				%end;
			%end;
		%end;
		%else 
			%put ERROR: &table does not exist.;

		%let i = %eval(&i+1);
		
	%end;

	%put NOTE: Done verifying tables.;
	%let rc= %sysfunc(close(&dsid.));

%mend;