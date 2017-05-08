## Hello World

```SAS
data _null_;
    put "Hello World!";
run;
```
+ If you want to do a data step, but do not care for the result, use the special dataset name `_null_`.

## Programming Language

+ You can use upper or lowercase letters. SAS processes names as uppercase regardless of how you type them.
+ Both variable names and dataset names, can contain numbers, but the first character has to be a letter. 
    + `mort90` is a valid variable / dataset name, while `90mort` is not valid.
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
    SET Mydata;
RUN;
```

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

## Working With Datasets

### Filtering, Splitting and Merging of Datasets

```SAS
data male;
    set alldat;
    if sex=1;
run;

* appending, concatenating ;
data alldat;
    set mort90 mort91 mort92 mort93;
run;

* merging ;
data alldat;
    merge inci90 mort90; * the datasets to be merged ;
    by year agegrp gender; * the columns that should be used for merging ;
run;

data alldat;
    set alldat;

    agegrp=min(int((age-30)/5),4);
    bmi=weight/(height**2);

    parity=.;
         if npar=0          then parity=1;
    else if npar in (1,2,3) then parity=2;
    else if npar > 3        then parity=3;
run;
```

+ Note, that the keyword `if` has two purposes. 
  + If you use `if ...` you select the observations, that you want to keep in your dataset. See `if sex=1;` in the first example.
  + If you use `if ... then ...`, you can create some new variables afther the `then` part. See `parity` variable in last example.
+ Note that also `=` has two purposes.
  + If you use a `=` after an `if` or `where` keyword, you will do a comparison: `if npar=0 then ...`. (The `...` will be executed, if the variable `npar` is indeed zero.)
  + If you use a `=` anywhere else, you will do an assignment: `parity=1;` (This assigns the variable parity the value 1.)
+ If you want to execute more than one statement after the `then` keyword, you have to use `do; ... end;`. Notice, that both keywords, have a `;` at the end.


### Another way to split datasets


```SAS
data male female;
    set alldat;
    if sex=1 then output male;
    if sex=2 then output female;
run;

data noinfo light medium heavy;
    set alldat;
    if      weight <= 0   then output noinfo;
    else if weight <= 85  then output light;
    else if weight <= 110 then output medium;
    else                       output heavy;
run;
```

## Anatomy of a Datastep

```SAS
data <output-dataset>;

    *OPTION 1: 'set' create a new dataset based on an existing one ;
    set <input-dataset>;

    *OPTION 2 'merge' merge two or more exsiting datasets into one larger dataset ;
    merge <input-dataset-1> <input-dataset-2> <input-dataset-3 ...>;
    by <merge-variable>;

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

* example ;
proc print data=alldat;
    where bmi > 25;
    var name age gender;
run;

```
+ If you do not specify a dataset, the special variable `_last_` will be used, which contains the name of the dataset that was created last.
+ Generally, SAS has some special keywords that start and end with an underscore `_`. E.g. `_all_`, `_numeric_`, `_character_` for selecting variables in a `proc print` call.
+ Many procedures support the `where` keyword, that lets you select a subset of your data, without creating an entirely new dataset.



### Reading/Writing Datasets

```SAS
libname store '/path/to/my/folder';

* read from .sas7bdat file ;
data alldat; 
    set store.alldat;
run;

* write to .sas7bdat file ;
data store.alldat; 
   set alldat; 
run;
```


## Deriving New Variables

```SAS
proc format; 
    value genderf
        1="male"
        2="female";
    value parityf
        1="no children"
        2="1-3 children"
        3="4 or more children";
run;

data alldat;
    set alldat;

    agegrp=min(int((age-30)/5),4);
    bmi=weight/(height**2);

    parity=.;
         if npar=0          then parity=1;
    else if npar in (1,2,3) then parity=2;
    else if npar > 3        then parity=3;

    label  bmi="Body-Mass-Index";

    format gender genderf.
           parity parityf.;

    keep   id gender agegrp bmi parity;
run;
```


## Traps and Pitfalls

### Always initialize variables

```SAS
data alldat;
    agecat=.; * <-- this statement is important *;
    if       0<=age<10 then agecat=1;
    else if 10<=age<20 then agecat=2;
run;
```

SAS will put *NOTE: Variable ... is uninitialized* into the log otherwise. Never ignore this note.

### Missing values are less than zero
    
```SAS
data alldat;
    * BMI (.=missing/1=normal/2=overweight/3=obese);
    if      bmi<=0  then bmicat=.;
    else if bmi<25  then bmicat=1; 
    else if bmi<30  then bmicat=2;
    else                 bmicat=3;
run;
```

[More on missing values](https://support.sas.com/documentation/cdl/en/lrcon/62955/HTML/default/viewer.htm#a000989180.htm)

### Built-in functions ignore missing values

For example, `sum()` and `avg()` ignore missing values. [SAS doc](http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000245953.htm), [pdf](http://www.lexjansen.com/nesug/nesug06/cc/cc31.pdf)

```SAS
x1=4
x2=9
x3=.

sum(x1,x2)     yields 13   # ok
sum(x1,x2,x3)  yields 13   # missings are not considered
sum(of x1-x3)  yields 13   # passed as a list
sum(of x:)     yields 13   # pass variables by common prefix
sum(x1-x2)     yields -5   # error: forgot 'of' --> subtraction
x1+x2          yields 13   # ok
x1+x2+x3       yields .    # missings are considered
```

### Array variables do not have to exist

```SAS
data alldat;
    merge data90 data91 data92; by id;

    array bmia {*} bmi90 bmi91 bmi92;

    do i=1 to dim(bmia);
        bmi=bmia(i);
        ...
        output;
    end;
run;
```

If the variables `bmi90`, `bmi91`, `bmi92` do not exist in the data sets `data90 data91 data92`, SAS will not issue a warning. SAS will create these temporary names for you and as a result, `bmi` will always be missing.

