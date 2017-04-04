## Deleting Formats From Datasets

```SAS
* delete all labels and formats from a dataset ;
proc datasets nolist;
    modify alldat;
    attrib _all_ label='';
    attrib _all_ format=;
    attrib _all_ informat=;
run;
```

## Macros

```SAS

* changing from space-separated macro variable to comma-separated variable ;
%let by2 = %sysfunc(tranwrd(&by.,%str( ),%str(,)));


```

## Arrays: Creation and Iterating 

Arrays in the SAS language are different from arrays in many other languages. A SAS array is simply a convenient way of temporarily identifying a group of variables. It is not a data structure, and the array name is not a variable.

```SAS
data alldat;
    * definition ;
    array incomea  {*} income08 income09 income10 income11 income12;

    * definition + initial values ;
    array sizesa   {*} petite small medium large extra_large (2, 4, 6, 8, 10); 
    array citiesa  {*} $ ('New York' 'Los Angeles' 'Dallas' 'Chicago'); 

    * definition with custom subscript range ;
    array tempa {6:18} temp6 – temp18;


    * function application ;
    sum_income  = sum(of incomea);
    mean_income = mean(of incomea);


    * looping ;
    array wtkga   {5} wtkg1-wtkg5;
    array heighta {5} htm1-htm5;
    array bmia    {5} bmi1-bmi5; /*derived*/

    do i=1 to dim(bmia);
        bmia(i)=wtkga(i)/(heighta(i)**2);
    end;
run;
```

<details>
<summary>Sources and more material (click to expand)</summary>
+ [More Examples -> SAS Doc](http://support.sas.com/documentation/cdl/en/lestmtsref/68024/HTML/default/viewer.htm#p08do6szetrxe2n136ush727sbuo.htm)
+ [More Array Definitions + Loops over arrays](http://support.sas.com/resources/papers/proceedings10/158-2010.pdf)
+ [Functions on Arrays](https://support.sas.com/resources/papers/97529_Using_Arrays_in_SAS_Programming.pdf)
+ [Two dimensional and temporary arrays](http://www.lexjansen.com/nesug/nesug05/pm/pm8.pdf)
+ [Defining your own subscript range](http://www2.sas.com/proceedings/sugi30/242-30.pdf)
</details>


## Graphs and Figures

```SAS
*creating a greyscale barcart ;

proc template;
	define style mytemplate;
		parent=styles.journal;
		style GraphBar from GraphComponent /
			displayopts = "outline fillpattern";
		style GraphData1 from GraphData1 / fillpattern = "S";
		style GraphData2 from GraphData2 / fillpattern = "R2";
		style GraphData3 from GraphData3 / fillpattern = "X2";
		style GraphData4 from GraphData4 / fillpattern = "L2";
		style GraphData5 from GraphData5 / fillpattern = "E";
	end;
run;

*ods listing style=statistical gpath=&folder.; 
ods listing style=mytemplate gpath=&folder.; 
ods graphics on / reset=all imagename=&filename. height=&height.;

title  &title1.;
title2 &title2.;

proc sgplot data=&dataset. pctlevel=group;
	vbar year / group=&var. stat=percent;
	yaxis grid label=&ylabel.;
run;

ods _all_ close;

title;
title2;
```



### Find the bug

<details><summary>Filling up arrays (click to expand)</summary>

### Filling up arrays

```SAS
data alldat;

    * duration of medication use, months: missing is coded as 999 *;
    array durmeda  {*} durmed76 durmed78 durmed80;

    * duration of medication use, months (derived): missing will be coded as . *;
    * and values will be carried forward from 1980 onwards *;
    array durmedua {*} durmedu76 durmedu78 durmedu80 durmedu84 durmedu86 durmedu88;

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

<details><summary>Creating categories (click to expand)</summary>

### Creating categories

```SAS
data alldat;
    *oc   = 1=never taken any oral contraceptives, 2=taken oral contraceptives in the past ;
    *docu = duration of oral contraceptive use in months ;

    ocstatdur=.;
    if      oc=1 or docu=0  then ocstatdur=1;
    else if oc=2 then do;
        if      0<=docu<=12 then ocstatdur=2;
        else if    docu<=36 then ocstatdur=3;
        else if    docu<=72 then ocstatdur=4;
        else if    docu> 72 then ocstatdur=5;
    end;
```
</details>


