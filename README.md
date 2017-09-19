SAS code snippets

### Investigating N, Distribution

```SAS
* print all names of available variables ;
proc contents data=alldat nodetails varnum;
run;

* print all names of available variables with custom macro %parse(dataset, regex) ;
%put All available variables: %parse(alldat, /.*/); 


* print distribution ;
proc means data=alldat maxdec=2 nolabels missing n nmiss mean std;
    var age;
    class exposure;
run;

* print more detailed information about distribution ;
proc means data=alldat nolabels missing n nmiss mean median min max p1 p5 q1 q3 p95 p99 std;
    var bmi n_cigarettes alc_grams;
    class period exposure;
run;

* cross-tabulating ;
proc freq data=alldat noprint;
    where gender=1;
    tables (age height bmi)*year / missing out=result;
run;
```


### Investigating Interesting Observations

```SAS
* print all observations satisfying certain criteria ;
proc print data=alldat;
    where bmi > 25;
    var name gender smoking;
run;

* print the first 20 observations ;
proc print data=alldat(obs=20);
run;

* print the observations 50 through 70 ;
proc print data=alldat(firstobs=50 obs=70);
run;

* print a random subset of the data ;
proc surveyselect data=alldat method=srs rep=1 sampsize=50 seed=1 out=random_sample;
run;
proc print data=random_sample;
run;

* print to a specific output file ;
proc printto print='path/to/my/file.sasoutput' new; run;
    * call proc freq, proc means, etc.;
proc printto; run;
```


### Importing/Exporting Datasets

```SAS
* import ;
* read from csv file separated by commas ;
proc import datafile="/path/to/data.csv" out=alldat dbms=csv replace;
    getnames=yes;
run;

* read from csv file separated by other separator ;
options locale=de_AT dflang=locale; 
proc import datafile="/path/to/data.csv" out=alldat dbms=dlm replace;
    getnames=yes;
    delimiter=";"; /* use delimiter="|" for pipe separated files */
    guessingrows=max;
run;
options locale=en_US dflang=locale; 

* export ;
* write to excel spreadsheet ;
%include "export_excel.sas";
%export_excel(alldat, keep=year gender age, where=bmi le 30,
                folder="/path/to/folder", filename="filename.xlsx");
```

### Renaming / Deleting

```SAS
* delete libnames, filenames ;
libname  mylib  clear;
filename myfile clear;

* rename a dataset ;
proc datasets nolist;
    change myoldname = newname;
quit; run;

* delete datasets by enumeration or by common prefix (here _tmp_) ;
proc datasets nolist nowarn nodetails;
    delete olddata _tmp_: ;
quit; run;

* delete entire library ;
proc datasets library=work kill nolist; 
quit; run;
```

### Just some test data

```SAS
data testdata;
    y=1;
    do i=1 to 30;
        x=i+1;
        y=y+x;
        z=y+4;
        output;
    end;
run;
```

### Graphs and Figures

```SAS
* preamble ;
ods listing style=statistical gpath="/path/to/my/folder"; 
ods graphics on / reset=all imagename="my_filename" height=720px;

* proc sgplot, univariate, etc. ;

ods _all_ close;


* histogram ;
proc univariate data=alldat;
    histogram height / normal; * normal causes a normal distribution to be plotted ;
run;
* cumulative density function ;
proc univariate data=alldat;
    cdfplot height / normal noecdf; * noecdf leaves only the normal density function ;
run;
* barchart (grouped) where you want to hide a fake observation that has obsweight=0 ;
proc sgplot data=&dataset. pctlevel=group;
    vbar year / group=subtype stat=percent legendlabel="" name="a" legendlabel="" weight=obsweight;
    keylegend "a";
run;
```

### Proc SQL

Deriving new datasets

```SAS
* summing/grouping over all age groups ;
proc sql noprint;
	create table autpop as 
		select year, gender, sum(population) as population
		from austrian_population 
		group by year, gender
		order by year, gender;
quit; run;



* left joining ;
proc sql noprint;
    create table alldat as
        select * 
        from rate_by_agegroup e left join population_by_agegroup a 
            on e.gender=a.gender and e.year=a.year and e.ag=a.ag;
quit; run;

```

Deriving macro variables

```SAS

* select minimum, maximum into a macro variable ;
proc sql noprint;
    select min(rate), max(rate) into :min_y, :max_y 
    from alldat; 
quit; run;

* select distinct values into a macro variable ;
proc sql noprint;
    select distinct(stage) into :stages separated by " "
    from alldat;
quit;

* select number of different values into a macro variable ;
proc sql noprint;
	select count(distinct(group)) into :n
	from alldat;
quit; run;



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

```
### proc sort - Sort Dataset

```SAS
* out= option is optional ;
* here: sort by lighest to heaviest ppl and oldest to youngest ppl ;
proc sort data=alldat out=alldat_sorted;
    by weight descending age;
run;

* keep only the first id, that is in the physical file ;
proc sort data=alldat nodupkey;
    by id;
run;

* use nodup, if you only want to throw out exact tuple duplicates instead ;
```

### proc rank - Creating Quantiles

Create tertiles, quartiles, quintiles, deciles, etc.

```SAS
* out= option is important ;
proc rank data=alldat out=alldat groups=4;
    var bmi;
    ranks bmi_q;
run;
```


### proc mi - Missingness Patterns

Investigate missing values

```SAS
proc mi data=alldat nimpute=0;
    var age height bmi;
    ods select misspattern;
run;
```

### proc transpose - Transposing a Dataset

```SAS
proc sort data=pop; by agegrp gender; run;

* prefix= and id are optional, cause the columns to have names ;
proc transpose data=pop out=lexis_pop prefix=period_;
    id period;
    var population;
    by agegrp gender;
run;

```
<details>
<summary>Tables before and after transposing (click to expand)</summary>

**before**

|agegrp|gender|period|population|
|---|---|---|---|
|1|1|2000|1|
|1|1|2001|2|
|1|1|2002|3|
|1|1|2003|4|
|1|2|2000|5|
|1|2|2001|6|
|1|2|2002|7|
|1|2|2003|8|
|2|1|2000|9|
|2|1|2001|10|
|2|1|2002|11|
|2|1|2003|12|
|2|2|2000|13|
|2|2|2001|14|
|2|2|2002|15|
|2|2|2003|16|
  
**after**

|agegrp|gender|\_name\_|period_2000|period_2001|period_2002|period_2003|
|---|---|---|---|---|---|---|
|1|1|population|1|2|3|4|
|2|1|population|5|6|7|8|
|1|2|population|9|10|11|12|
|2|2|population|13|14|15|16|
</details>


### proc stdrate - Age Adjusting

```SAS
ods _all_ close;

proc stdrate data=alldat
			 refdata=eustd
			 method=direct
			 stat=rate effect
			 plots=none;
		by year;
		population group=gender event=cancer total=population;
		reference  total=eu_population;
		strata     agegrp / stats effect;
		ods output strataeffect=inc_std stdrate=inc_std2;
run;
```

### proc loess - Scatter Plot Smoothing

```SAS
proc sort data=breast_stage; by stage year; run;

proc loess data=breast_stage plots=none;
    model rate=year;
    by stage;
    output out=breast_stage_pred;
run;
```

### proc reg - Linear Regression

```SAS
proc sort data=alldat; by gender yeargrp; run;

ods _all_ close;

proc reg data=alldat tableout outest=test_est;
    model stdrate = year graph inter;
    by gender yeargrp;
run;
```

### proc genmod - Generalized Linear Models

The class of generalized linear models is an extension of traditional linear models that allows the mean of a population to depend on a linear predictor through a nonlinear link function and allows the response probability distribution to be any member of an exponential family of distributions. Many widely used statistical models are generalized linear models. These include classical linear models with normal errors, logistic and probit models for binary data, and log-linear models for multinomial data.

```SAS
* reslik represents the likelihood residual for identifying poorly fitted observations;

proc genmod data=alldat;
    model score = calories;
    output out=alldat reslik=resscore;
run;
```

