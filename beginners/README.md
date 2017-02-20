## Hello World

```SAS
data _null_;
	put "Hello World!";
run;
```
+ If you want to do a data step, but do not care for the result, use the special dataset name `_null_`.

## Programming Language

+ You can use upper or lowercase letters. SAS processes names as uppercase regardless of how you type them.
+ All comments will be deleted just before the execution of the program.
+ The number of whitespace (spaces, tabs, newlines) you use, is irrelevant to SAS and will all be reduced to exactly one whitespace. The following programs are equivalent:

```SAS
* this is equivalent ;
data alldat; set mydata; run;

* with this ;
DATA ALLDAT;

	* a one-line comment ;
	/*
	multi-line comment
	*/
	SET mydata;

RUN;
```


## Anatomy of a Datastep

```SAS
data <output-dataset>;

	*OPTION 1: 'set' create a new dataset based on an existing one ;
	set <input-dataset>;

	*OPTION 2 'merge' merge two or more exsiting datasets into one larger dataset ;
	merge <input-dataset-1> <input-dataset-2> <input-dataset-3 ...>;
	by merge-variable;

	* further code *;
	* ... *;

run;
```

+ More than one output dataset can be specified.

## Anatomy of a Procedure Call
```SAS

proc <name> data=<dataset> <options>;
	<keyword> <more-options> / <even-more-options>;
run;

```

+ If you do not specify a dataset, the special variable `_last_` will be used, which contains the name of the dataset that was created last.


## Datasteps

+ If you do not declare a library, the library `work` will be used. The following code does the same thing:

```SAS
* this is equivalent ;
data alldat;
	set mydata;
run;

* with this ;
data work.alldat;
	set work.mydata;
run;
```
