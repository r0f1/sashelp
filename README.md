# SAS

## Investigating

### Investigating N, Distribution, Missing Values

```SAS
* Print all names of available variables ;
proc contents data=alldat;
run;

* Print distribution ;
proc means data=alldat maxdec=2 nolabels missing n nmiss mean std;
    var age;
    class exposure;
run;

* Print more detailed information about distribution ;
proc means data=alldat nolabels missing n nmiss mean median min max p1 p5 q1 q3 p95 p99 std;
    var bmi n_cigarettes alc_grams;
    class period exposure;
run;
```

### Cross-Tabulating
```SAS
proc freq data=alldat noprint;
    tables (age height bmi)*year / missing out=result;
run;
```

### Missingness Patterns
```SAS
proc mi data=alldat nimpute=0;
    var age height bmi;
    ods select misspattern;
run;
```

### Investigating Interesting Observations
```SAS
* Print the first 20 observations ;
proc print data=alldat(obs=20);
run;

* Print the observations 50 through 70 ;
proc print data=alldat(firstobs=50 obs=70);
run;

* Print a specific observation ;
proc print data=alldat;
    where id=1234; 
run;

* Print all observations satisfying certain criteria ;
proc print data=alldat;
    where bmi > 25;
    var name gender smoking;
run;

* Print a random subset of the data *;
proc surveyselect data=alldat method=srs rep=1 sampsize=50 seed=1 out=random_sample;
run;
proc print data=random_sample;
run;

* Print to a specific output file *;
proc printto print='path/to/my/file.sasoutput' new; run;
    * call proc freq, proc means, etc.;
proc printto run;
```

## Deriving New Datasets

### Filtering and Splitting of Datasets

```SAS
data male;
    set alldat;
    if sex=1;
run;

data male;
    set alldat(where=(sex=1));
run;

data male(where=(sex=1)) female(where=(sex=2));
    set alldat;
run;

data noinfo light medium heavy;
    set alldat;
    if      weight <= 0   then output noinfo;
    else if weight <= 85  then output light;
    else if weight <= 110 then output medium;
    else                       output heavy;
run;
```

### Transposing

```SAS
proc sort data=population;
    by year gender postal_code;
run;

proc transpose data=population out=population_t;
    by year gender postal_code;
run;
```
<details>
<summary>Tables before and after (click to expand)</summary>
  
**have**

|gender|postal_code|year|ag1|ag2|ag3|ag4|
|---|---|---|---|---|---|---|
|1|1234|2017|35|47|99|17|
|2|1234|2017|34|42|102|20|

**want**

|gender|postal_code|year|ag|count|
|---|---|---|---|---|
|1|1234|2017|ag1|35|
|1|1234|2017|ag2|47|
|1|1234|2017|ag3|99|
|1|1234|2017|ag4|17|
|2|1234|2017|ag1|34|
|2|1234|2017|ag2|42|
|2|1234|2017|ag3|102|
|2|1234|2017|ag4|20|
</details>


### Reading/Writing Datasets

```SAS
libname store '/path/to/my/folder';

* Read from .sas7bdat file ;
data alldat; 
    set store.alldat;
run;

* Write to .sas7bdat file ;
data store.alldat; 
   set alldat; 
run;

* Read from csv file separated by semicolons *;
proc import datafile="/path/to/data.csv" out=alldat dbms=csv replace;
    getnames=yes;
run;

* Read from csv file separated by other separator *;
proc import datafile="/path/to/data.csv" out=alldat dbms=dlm replace;
    delimiter="|";
    getnames=yes;
run;

* Write to Excel*;
%include "export_excel.sas";
%export_excel(alldat, keep=year gender age, where=bmi le 30,
                folder="/path/to/folder", filename="filename.xlsx");
```


### Deleting

```SAS
* delete all labels and formats from a dataset ;
proc datasets nolist;
    modify alldat;
    attrib _all_ label='';
    attrib _all_ format=;
    attrib _all_ informat=;
run;

* delete libnames, filenames;
libname oldlib clear;

* delete datasets by enumeration;
proc datasets nolist;
    delete olddata1 olddata2;
quit; run;

* delete datasets by common prefix (here _tmp_);
proc datasets nolist;
    delete _tmp_: ;
quit; run;

* delete entire library ;
proc datasets library=work kill nolist; 
quit; run;
```


## Deriving New Variables

### Based on Functions and Cutoffs

```SAS
* create a format *;
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

### Creating Quartiles

```SAS
proc rank data=alldat out=alldat groups=4;
    var bmi;
    ranks bmi_q;
run;
```

## Further Data Processing Techniques

### Arrays: Creation and Iterating 

Arrays in the SAS language are different from arrays in many other languages. A SAS array is simply a convenient way of temporarily identifying a group of variables. It is not a data structure, and the array name is not a variable.

```SAS
*Functions*;
array incomea  {*} income08 income09 income10 income11 income12;

sum_income  = sum(of incomea);
mean_income = mean(of incomea);
min_income  = min(of incomea);
max_income  = max(of incomea);


*Looping*;
array wtkga   {5} wtkg1-wtkg5;
array heighta {5} htm1-htm5;
array bmia    {5} bmi1-bmi5; /*derived*/

do i=1 to dim(bmia);
    bmia(i)=wtkga(i)/(heighta(i)**2);
end;


*Initial values*;
array sizesa {*} petite small medium large extra_large (2, 4, 6, 8, 10); 
array citiesa {*} $ ('New York' 'Los Angeles' 'Dallas' 'Chicago'); 


* Defining your own subscript range*;
array tempa {6:18} temp6 – temp18;
```

<details>
<summary>Sources and more material (click to expand)</summary>
+ [More Examples -> SAS Doc](http://support.sas.com/documentation/cdl/en/lestmtsref/68024/HTML/default/viewer.htm#p08do6szetrxe2n136ush727sbuo.htm)
+ [More Array Definitions + Loops over arrays](http://support.sas.com/resources/papers/proceedings10/158-2010.pdf)
+ [Functions on Arrays](https://support.sas.com/resources/papers/97529_Using_Arrays_in_SAS_Programming.pdf)
+ [Two dimensional and temporary arrays](http://www.lexjansen.com/nesug/nesug05/pm/pm8.pdf)
+ [Defining your own subscript range](http://www2.sas.com/proceedings/sugi30/242-30.pdf)
</details>


### Proc SQL


```SAS
* select minimum, maximum into a macro variable ;
proc sql noprint;
    select min(rate), max(rate) into :min_y, :max_y 
    from alldat; 
quit; run;




* select distinct values into a macro variable then iterate/loop over it;
proc sql noprint;
    select distinct(stage) into :stages separated by " "
    from alldat;
quit;   

%let n = %sysfunc(countw(&stages));
%do i=1 %to &n;
    %let val = %scan(&stages,&i);

    data alldat2;
       set alldat;
       if stage=&val.;
       *put the label of a variable in a macro variable*;
       call symput("fmtval", vvalue(stage)); 
    run;




* select variables of a dataset into a macro variable in alphabetical order then print the dataset ;
proc sql noprint;                               
    select distinct name into :varlist separated by ','              
    from dictionary.columns                      
    where libname='WORK' and memname='ALLDAT'
    order by name;
quit; run;
proc sql noprint;                               
    create table printme as select &varlist from alldat;
quit; run;
proc print data=printme; 
    var &varlist;
run;




* create a new dataset, left joining ;
proc sql noprint;
    create table alldat as
        select * 
        from rate_by_agegroup e left join population_by_agegroup a 
            on e.gender=a.gender and e.year=a.year and e.ag=a.ag;
quit; run;




* taking the median of 5 year groups, starting 1990 ;

* create indicator variable to distinguish groups ;
data alldat;
    set alldat;
    year5 = ceil(max(0, year-1990)/5);
run;

* calculate medians of groups by gender and agegroup ;
proc sql noprint;
    create table alldat_f as 
        select *, median(n) as m from alldat group by year5, gender, ag7_id;
quit; run;

* delete unnecessary groups ;
data alldat_f;
    set alldat_f;
    if mod(year, 5) = 0;
    keep year gender ag7_id m;
run;

```

[%do_over()](http://www2.sas.com/proceedings/sugi31/040-31.pdf)
See [print_library_info.sas](https://github.com/r0f1/sashelp/blob/master/macros/plot_series_scatter_by.sas) for more examples.



## Graphs and Figures

### Outputting to a Specifiy Directory

```SAS
title &title.;
title2 &title2.;
ods listing style=statistical gpath=&folder.; 
ods graphics on / reset=all imagename=&filename. height=&height. border=off;

proc sgplot data=alldat; 
...;
run;

ods _all_ close;
title "";
title2 "";
```

### proc loess

```SAS
proc sort data=breast_stage; by stage year; run;

proc loess data=breast_stage plots=none;
    model rate=year;
    by stage;
    output out=breast_stage_pred;
run;
```
Data set needs to be sorted by `by` variables first.

## Misc

<details>
<summary>Grouping of variables = "GROUP BY" (click to expand)</summary>
### Grouping of variables = "GROUP BY"

```SAS
proc summary data=alldat nway completetypes;
    class county year gender;
    var n;
    output out=alldat_g(drop=_freq_ _type_) sum=;
run;
```
</details>

<details>

<summary>Grouping of variables with zero occurences (click to expand)</summary>
### Grouping of variables with zero occurences


```SAS
proc freq data=alldat;
    tables diagnosis*year*gender*agegroup / noprint out=alldat_grouped;
run;

data alldat_grouped;
    set alldat_grouped;
    one=1;
run;

proc summary data=alldat_grouped nway completetypes;
    class diagnosis year gender agegroup;
    freq count;
    var one;
    output out=final_grouped(drop=_freq_ _type_) n=n;
run;

proc final_grouped; 
    set final_grouped;
    if n=0 then n=0.0001;
run;
```

See also [here](http://www.ats.ucla.edu/stat/sas/faq/zero_cell_freq.htm).
</details>



## Macros that I have written


### %plot_series_scatter_by()

Scatter + series plot in one figure.

```SAS
%plot_series_scatter_by(alldat, 
    scatter_x=year, scatter_y=orig, series_x=year, series_y=predicted,
    group=group, log=0, label_x="Year", label_y="Rate",
    title="My title", title2="My subtitle", folder="/path/to/folder", filename="image", height=900px);
```

### %export_excel()

Export SAS data set as Excel spreadsheet, while (optionally) retaining the assigned format names.

```SAS
%export_excel(alldat, keep=year rate, folder="/path/to/folder", filename="rates.xlsx", retain_formats=T);
```

### %print_library_info()

Print variable names, number of observations and the first 20 observations (of the first 10 variables) of each data set in a specified folder.

```SAS
%print_library_info("/path/to/folder");
```


## Traps and Pitfalls

### Always initialize variables

```SAS
data alldat;
    agecat=.; * <-- this statement is important *;
    if      0<=age<10 then agecat=1;
    else if    age<20 then agecat=2;
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
sum(of x1-x3)  yields 13   # pass a list
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


## Find the bug

<details><summary>Filling up arrays (click to expand)</summary>

### Filling up arrays

```SAS
data alldat;

    * duration of medication use, months: missing is coded as 999*;
    array durmeda          {*} durmed76 durmed78 durmed80;

    * duration of medication use, months (derived): missing will be coded as . *;
    * and values will be caried forward from 1980 onwards*;
    array durmedua         {*} durmedu76 durmedu78 durmedu80 durmedu84 durmedu86 durmedu88;

    do i=1 to dim(durmedua);
        if i<=3 then do;
            if durmeda(i)=999 then 
                durmedua(i)=.;
            else
                durmedua(i)=durmeda(i);
        end;
        else    durmedua(i)=durmeda(3);

        durmed=durmedua(i);
    end;

run;
```

A proc freq of `durmed` reveals that there are some missing values and some values are still 999.
I thought I have overwritten all 999 values. How is it possible that there are still some 999 values?

</details>