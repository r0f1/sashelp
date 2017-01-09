%macro print_library_info(library_path);

	libname _store "&library_path.";

    %local dataset_count dataset_name varlist iter;

    ods output members=dataset_list;
        proc datasets library=_store memtype=data; run;
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
                where libname='_STORE' and memname="&dataset_name.";
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
        proc print data=_store.&dataset_name.(obs=20 keep=&varlist.); run;

        %let iter=%eval(&iter.+1);
    %end;

    libname _store clear;

%mend;
