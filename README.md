# Useful SAS code


## Exploratory data analysis

### Finding out n, distribution and missing values

    %let vars  = bmi n_cigarettes alc_grams;

    proc contents data=alldat;
    run;

    proc means data=alldat maxdec=1 nolabels missing n nmiss mean std;
        var age;
        class exposure;
    run;

    proc means data=alldat nolabels missing n nmiss mean median min max p1 p5 q1 q3 p95 p99 std;
        var &vars;
        class period exposure;
    run;

[Source](https://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a000146729.htm)

### Cross-Tabulating

    proc freq data=alldat noprint;
        tables (age height bmi)*year / missing out=result;
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

[Source](https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_freq_sect016.htm)

</details>


### Missingness Patterns

    proc mi data=alldat nimpute=0;
        var age height bmi;
        ods select misspattern;
    run;

Missingness patterns of character variables: [here](http://www.ats.ucla.edu/stat/sas/faq/nummiss_sas.htm).

## Investigating interesting observations

### Printing some infos

    * Print the first 20 observations ;
    proc print data=alldat(obs=20);
    run;

    * Print the observations 50 through 70 ;
    proc print data=alldat(firstobs=50 obs=70);
    run;

    proc print data=alldat;
        where id=1234; 
    run;

    proc print data=alldat;
        var name gender smoking;
        where bmi > 25;
    run;

<details>
<summary>obs= and firstobs= explaination (click to expand)</summary>
FIRSTOBS= option tells SAS to begin reading the data from the input SAS data set at the line number specified by FIRSTOBS.  
OBS= option tells SAS to stop reading the data from the input SAS data set at the line number specified by OBS.  
[Source](https://onlinecourses.science.psu.edu/stat481/node/14)
</details>

<details>
<summary>Print variables in alphabetical order (click to expand)</summary>

### Print variables in alphabetical order

    proc sql noprint;                               
        select distinct name into :varlist separated by ','              
        from dictionary.columns                      
        where libname='work' and memname='alldat'
        order by name;

        create table toprint as 
            select &varlist from alldat;
    quit; run;

    proc print data=toprint;
        var &varlist;
    run;

[Source](http://www.amadeus.co.uk/sas-training/tips/1/1/139/sorting-variable-names-alphabetically.php)

</details>

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

    *Create data set with observations 100 through 200*;
    data reduced;
        set alldat(firstobs=100 obs=200);
    run;

<details>
<summary>Output statement description (click to expand)</summary>
The OUTPUT statement tells SAS to write the current observation to a SAS data set immediately, not at the end of the DATA step. If no data set name is specified in the OUTPUT statement, the observation is written all that are listed in the DATA statement. By default, every DATA step contains an implicit OUTPUT statement at the end of each iteration that tells SAS to write observations to the data set or data sets that are being created. Placing an explicit OUTPUT statement in a DATA step overrides the automatic output, and SAS adds an observation to a data set only when an explicit OUTPUT statement is executed. Once you use an OUTPUT statement to write an observation to any one data set, however, there is no implicit OUTPUT statement at the end of the DATA step. In this situation, a DATA step writes an observation to a data set only when an explicit OUTPUT executes. You can use the OUTPUT statement alone or as part of an IF-THEN or SELECT statement or in DO-loop processing. [Source](https://v8doc.sas.com/sashtml/lgref/z0194540.htm)

More examples [here](http://www.lexjansen.com/nesug/nesug06/dm/da30.pdf).  
</details>

[IF and WHERE](http://www2.sas.com/proceedings/sugi31/238-31.pdf).

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

<details>
<summary>Sources and more material (click to expand)</summary>
+ [More Examples -> SAS Doc](http://support.sas.com/documentation/cdl/en/lestmtsref/68024/HTML/default/viewer.htm#p08do6szetrxe2n136ush727sbuo.htm)
+ [More Array Definitions + Loops over arrays](http://support.sas.com/resources/papers/proceedings10/158-2010.pdf)
+ [Functions on Arrays](https://support.sas.com/resources/papers/97529_Using_Arrays_in_SAS_Programming.pdf)
+ [Two dimensional and temporary arrays](http://www.lexjansen.com/nesug/nesug05/pm/pm8.pdf)
+ [Defining your own subscript range](http://www2.sas.com/proceedings/sugi30/242-30.pdf)
</details>

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

### Deleting 

    * delete all labels and formats from a dataset ;
    proc datasets nolist;
        modify alldat;
        attrib _all_ label='';
        attrib _all_ format=;
        attrib _all_ informat=;
    run;

    * delete libnames, filenames, datasets ;
    libname oldlib clear;

    proc datasets nolist;
        delete olddata1 olddata2 olddata3;
    quit; run;

    * delete entire library ;
    proc datasets library=work kill; run; quit;

## Misc

<details>
<summary>Iterating over all datasets of library (click to expand)</summary>
    
    libname store "/path/to/library";

    %macro printInfo();
        %local dataset_count dataset_name varlist iter;

        ods output members=dataset_list;
            proc datasets library=store memtype=data; run;
        quit;

        proc sql noprint;
            select count(*) into :dataset_count from dataset_list;
        quit;

        %let iter=1;
        %do %while (&iter.<= &dataset_count.);

            data _null_;
                set dataset_list(firstobs=&iter. obs=&iter.);
                call symput("dataset_name",upcase(strip(name)));
            run;

            proc sql noprint;
                create table varnames as
                    select memname, name, type from dictionary.columns
                    where libname='STORE' and memname="&dataset_name.";
            quit;

            proc sql noprint;
                create table dsinfo as
                    select count(*) as number_observations from &dataset_name.;
            quit;

            proc sql noprint;
                 select name into :varlist separated by ' ' from varnames(obs=10);
            quit;

            proc print data=varnames; run;
            proc print data=dsinfo; run;
            proc print data=store.&dataset_name.(obs=20 keep=&varlist.); run;

            %let iter=%eval(&iter.+1);
        %end;
    %mend;

</details>


<details>
<summary>Grouping of variables with zero occurences (click to expand)</summary>
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
</details>
<details>
<summary>Sum over column by group = "GROUP BY" (click to expand)</summary>
### Sum over column by group = "GROUP BY"

    proc summary data=alldat nway completetypes;
        class county year gender;
        var n;
        output out=alldat_g(drop=_freq_ _type_) sum=;
    run;
</details>
<details>
<summary>Importing a CSV file (click to expand)</summary>

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
</details>

## Traps and Pitfalls

### Always initialize variables

    data alldat;
        agecat=.; * <-- this statement is important *;
        if      0<=age<10 then agecat=1;
        else if    age<20 then agecat=2;
    run;

SAS will put *NOTE: Variable ... is uninitialized* into the log otherwise. Never ignore this note.

### Missing values are less than zero
    
    data alldat;
        * BMI (.=missing/1=normal/2=overweight/3=obese);
        if      bmi<=0  then bmicat=.;
        else if bmi<25  then bmicat=1; 
        else if bmi<30  then bmicat=2;
        else                 bmicat=3;
    run;

[More on missing values](https://support.sas.com/documentation/cdl/en/lrcon/62955/HTML/default/viewer.htm#a000989180.htm)

### Built-in functions ignore missing values

For example, `sum()` and `avg()` ignore missing values. [SAS doc](http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000245953.htm), [pdf](http://www.lexjansen.com/nesug/nesug06/cc/cc31.pdf)

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


### Array variables do not have to exist

    data alldat;
        merge data90 data91 data92; by id;

        array bmia {*} bmi90 bmi91 bmi92;

        do i=1 to dim(bmia);
            bmi=bmia(i);
            ...
            output;
        end;
    run;

If the variables `bmi90`, `bmi91`, `bmi92` do not exist in the data sets `data90 data91 data92`, SAS will not issue a warning. SAS will create these temporary names for you and as a result, `bmi` will always be missing.


## Find the bug

<details><summary>Filling up arrays (click to expand)</summary>

### Filling up arrays

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


A proc freq of `durmed` reveals that there are some missing values and some values are still 999.
I thought I have overwritten all 999 values. How is it possible that there are still some 999 values?

</details>