# Useful SAS code


## Exploratory data analysis

### Finding out n, distribution and missing values

    %let vars  = bmi n_cigarettes alc_grams;

    proc means data=alldat nolabels missing n nmiss mean median min max p1 p5 q1 q3 p95 p99 std;
        var &vars;
        class period exposure;
    run;

[proc means arguments](http://www2.sas.com/proceedings/sugi29/240-29.pdf)

### Cross-Tabulating

    proc freq data=alldat; 
        tables age height bmi;
    run;
    proc freq data=alldat;
        tables year*(age height bmi);
    run;
    proc freq data=alldat;
        tables A / missprint;
    run;
    proc freq data=alldat;
        tables A / missing;
    run;

    <details>
    <summary>Missprint/Missing difference (click to expand)</summary>
**Missprint** produces:

A|Frequency|Percent|Cumulative Frequency|Cumulative Percent
---|---|---|---|---
.|2|.|.|.
1|2|50.00|2|50.00
2|2|50.00|4|100.00

**Missing** produces:

A|Frequency|Percent|Cumulative Frequency|Cumulative Percent
---|---|---|---|---
.|2|33.33|2|33.33
1|2|33.33|4|66.67
2|2|33.33|6|100.00
    </details>

[SAS doc](https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_freq_sect016.htm)


### Missingness Patterns

    proc mi data=alldat nimpute=0;
        var age height bmi;
        ods select misspattern;
    run;

If you want to also display missingness patterns of character variables, look [here](http://www.ats.ucla.edu/stat/sas/faq/nummiss_sas.htm).


## Investigating interesting observations

### Printing some infos

    * Print dataset infos ;
    proc contents data=alldat;
    run;

    * Print some observations ;
    proc print data=alldat(firstobs=2 obs=5);
    run;
    proc print data=alldat;
        where id=1234; 
    run;
    proc print data=alldat;
        var name gender smoking;
        where bmi > 25;
    run;

### Writing results to an separate output file instead of the log

    proc printto print='path/to/my/file.sasoutput' new; run;
        * call proc freq, proc means, etc.;
    proc printto run;

## Creating new datasets and variables

### Filter/Split a dataset

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

    <details>
    <summary>Output statement description (click to expand)</summary>
    The OUTPUT statement tells SAS to write the current observation to a SAS data set immediately, not at the end of the DATA step. If no data set name is specified in the OUTPUT statement, the observation is written all that are listed in the DATA statement. By default, every DATA step contains an implicit OUTPUT statement at the end of each iteration that tells SAS to write observations to the data set or data sets that are being created. Placing an explicit OUTPUT statement in a DATA step overrides the automatic output, and SAS adds an observation to a data set only when an explicit OUTPUT statement is executed. Once you use an OUTPUT statement to write an observation to any one data set, however, there is no implicit OUTPUT statement at the end of the DATA step. In this situation, a DATA step writes an observation to a data set only when an explicit OUTPUT executes. You can use the OUTPUT statement alone or as part of an IF-THEN or SELECT statement or in DO-loop processing. [Source](https://v8doc.sas.com/sashtml/lgref/z0194540.htm)
    </details>

More examples [here](http://www.lexjansen.com/nesug/nesug06/dm/da30.pdf).  
[Difference between IF and WHERE](http://www2.sas.com/proceedings/sugi31/238-31.pdf).


### Creating quartiles

    proc rank data=alldat out=alldat groups=4;
        var bmi;
        ranks bmi_q;
    run;

Specifying the *out* parameter is important. By default, *proc rank* will generate an incremental data set with a prefix of the original one (here: alldat2). [Source](http://www.lexjansen.com/nesug/nesug09/ap/AP01.pdf)


### Arrays: creation and iterating 

Arrays in the SAS language are different from arrays in many other languages. A SAS array is simply a convenient way of temporarily identifying a group of variables. It is not a data structure, and the array name is not a variable.

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


+ [More Examples -> SAS Doc](http://support.sas.com/documentation/cdl/en/lestmtsref/68024/HTML/default/viewer.htm#p08do6szetrxe2n136ush727sbuo.htm)
+ [More Array Definitions + Loops over arrays](http://support.sas.com/resources/papers/proceedings10/158-2010.pdf)
+ [Functions on Arrays](https://support.sas.com/resources/papers/97529_Using_Arrays_in_SAS_Programming.pdf)
+ [Two dimensional and temporary arrays](http://www.lexjansen.com/nesug/nesug05/pm/pm8.pdf)
+ [Defining your own subscript range](http://www2.sas.com/proceedings/sugi30/242-30.pdf)

## Dataset maintainance

### Reading/Writing from/to disk

    libname store '/path/to/my/folder';

    * Read from file ;
    data alldat;
        set store.alldat;
    run;

    * Write to file ;
    data store.alldat;
        set alldat;
    run;

### Deleting all labels and formats from a dataset

    proc datasets nolist;
        modify alldat;
        attrib _all_ label='';
        attrib _all_ format=;
        attrib _all_ informat=;
    run;

### Delete unused libnames and datasets

    libname oldlib clear;

    proc datasets nolist;
        delete olddata1 olddata2 olddata3;
    quit; run;



## Misc

### Grouping of variables with zero occurences

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

See also [here](http://www.ats.ucla.edu/stat/sas/faq/zero_cell_freq.htm).

### Sum over column by group = "GROUP BY"

    proc summary data=alldat nway completetypes;
        class county year gender;
        var n;
        output out=alldat_g(drop=_freq_ _type_) sum=;
    run;


### Importing a CSV file

    * CSV *;
    filename myfile '/path/to/data.csv';
    proc import datafile=myfile out=alldat dbms=csv replace;
        getnames=yes;
    run;

    * Other separator *;
    proc import datafile=myfile out=alldat dbms=dlm replace;
        delimiter="|";
        getnames=yes;
    run;

Careful if exported from Excel spreadsheet:

* missing values should be missing not coded as a - (hyphen)
* numbers must not have any zero separator (1000 not 1.000)

See also [here](http://www.ats.ucla.edu/stat/sas/faq/read_delim.htm).


## Traps and Pitfalls

### Categorizing variables that have missing values

Missing values in SAS are less than zero! [SAS doc](https://support.sas.com/documentation/cdl/en/lrcon/62955/HTML/default/viewer.htm#a000989180.htm)
    
    data alldat;
        * BMI (.=missing/1=normal/2=overweight/3=obese);
        if      bmi<=0  then bmicat=.;
        else if bmi<25  then bmicat=1; 
        else if bmi<30  then bmicat=2;
        else                 bmicat=3;
    run;


### Sum and plus sign behave differently

`sum()` and other built-in functions like `avg()` ignore missing values. [SAS doc](http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000245953.htm), [pdf](http://www.lexjansen.com/nesug/nesug06/cc/cc31.pdf)

    x1=4
    x2=9
    x3=.

    sum(x1,x2)     yields 13
    sum(x1,x2,x3)  yields 13
    sum(of x1-x3)  yields 13
    sum(of x:)     yields 13
    sum(x1-x2)     yields -5   # forgot 'of' --> subtraction
    x1+x2          yields 13
    x1+x2+x3       yields .


## Find the bug

### Filling up arrays

    data alldat;
    
        * duration of medication use, months: missing is coded as 999*;
        array durmeda          {*} durmed76 durmed78 durmed80 

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
            else    durmedua(i)=durmeda(5);

            durmed=durmedua(i);
        end;

    run;


A proc freq of `durmed` reveals that there are some missing values and some values are still 999.
I thought I have overwritten all 999 values. How is it possible that there are still some 999 values?

