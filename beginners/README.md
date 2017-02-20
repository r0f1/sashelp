## Hello World

```SAS
data _null_;
	put "Hello World!";
run;
```

## Anatomy of a Datastep

```SAS
data output-dataset-1 <output-dataset-2 ...>

	*OPTION 1 'set' ;
	set input-dataset;

	*OPTION 2 'merge' ;
	merge input-dataset-1 input-dataset-2 <input-dataset-3 ...>
	by merge-variable;

	* further code *;
	* ... *;

run;

```

## Programming Language

+ You can use upper or lowercase letters. SAS processes names as uppercase regardless of how you type them.
+ All comments will be deleted just before the execution of the program.
+ The number of whitespace (spaces, tabs, newlines) you use, is irrelevant to SAS and will all be reduced to exactly one whitespace. The following programs are equivalent:

```SAS
data alldat; set mydata; run;

DATA ALLDAT;

	* a one-line comment ;
	/*
	multi-line comment
	*/
	set mydata;

RUN;
```


## Datasteps

+ If you do not declare a library, the library `work` will be used. The following code does the same thing:

```SAS
data alldat;
	set mydata;
run;

data work.alldat;
	set work.mydata;
run;
```

+ If you want to do a data step but throw away the result afterwards, use the special dataset name `_null_`

```SAS
data _null_;
	set alldat end=eof;
	* output messages ;
	put "Hello World!";
	put "&my_variable.";
	* create macro variables ;
	if eof then
		call symput("nobs", count);
run;

```
