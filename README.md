# Useful SAS code


## Exploratory data analysis

### Finding out n, distribution and missing values

    %let constant_vars = height;
    %let dynamic_vars  = bmi n_cigarettes alc_grams;

    proc means nolabels data=alldat n nmiss mean median min p1 q1 q3 p99 max std;
    	var &constant_vars;
    	where period=1;
        class exposure;
    run;

    proc means nolabels data=alldat n nmiss mean median min p1 q1 q3 p99 max std;
    	var &dynamic_vars;
    	class period exposure;
    run;

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
1|2|33.33|2|66.67
2|2|33.33|4|100.00


[Missprint/Missing in SAS documentation](https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_freq_sect016.htm)


### Missingness Patterns

	proc mi data=alldat nimpute=0;
		var age height bmi;
		ods select misspattern;
	run;

If you want to also display missingness patterns of character variables, look [here](http://www.ats.ucla.edu/stat/sas/faq/nummiss_sas.htm).

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

## Working with datasets

### Filter a dataset

    data male;
        set alldat(where=(sex=1));
    run;

### Split a dataset

    data light medium heavy;
        set alldat;
        if            weight < 85   then output light;
        else if 85 <= weight <= 110 then output medium;
        else if       weight > 110  then output heavy;
    run;

    data male(where=(sex=1)) female(where=(sex=2));
        set alldat;
    run;

See also [here](http://www.lexjansen.com/nesug/nesug06/dm/da30.pdf).  
[Difference between IF and WHERE](http://www2.sas.com/proceedings/sugi31/238-31.pdf).

## Debugging

### Printing some infos

    * Print dataset infos ;
    proc contents data=alldat; run;

    * Print some observations ;
    proc print data=alldat(firstobs=2 obs=5); run;
    proc print data=alldat; where id=1234; run;
    proc print data=alldat;
        var name gender smoking;
        where bmi > 25;
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


## Import and Export

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

### Reading/Writing from/to disk

    libname store '/path/to/my/folder';

    * Read from file ;
    data alldat; set store.alldat; run;

    * Write to file ;
    data store.alldat; set alldat; run;
