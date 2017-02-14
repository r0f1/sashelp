
# Macros 

```SAS
* export SAS data set as Excel spreadsheet, while retaining the assigned format names ;
%export_excel(alldat, keep=year rate, folder="/path/to/folder", 
	filename="rates.xlsx", retain_labels=T, retain_formats=T);

* group dataset and transpose by a period variable ;
%lexis_table1(dataset=population, out=lexis_pop, var=population,
	by=gender agegrp, period=period);

* plot a series plot, based on one x axis and several y axes, grouped by a certain variable ;
%plot_lexis(dataset=alldat, where=agegrp ge 3,
	x_column=cohort, y_columns=mort_rate_men inc_rate_men, by=agegrp,
	legend=Mortality Incidence, datalabel=period_midpoint,
	xlabel="Year of Birth", ylabel="Age-Adjusted Rate per 100.000",
	title="Austria", title2="Age-Adjusted Rates by Birth Cohorts",
	folder=&outpath., filename="cancer_rates_men", 
	height=720px, greyscale=F, log=1);

* scatter + series plot ;
%plot_series_scatter_by(alldat, 
    scatter_x=year, scatter_y=orig, series_x=year, series_y=predicted,
    group=group, log=0, label_x="Year", label_y="Rate",
    title="My title", title2="My subtitle",
    folder="/path/to/folder", filename="image", height=720px);

* print variable names, number of observations, etc. of each data set in a specified folder ;
%print_library_info("/path/to/folder");

* verify one or more tables exist and contain the expected columns ;
%verify_tables(alldat, id firstname lastname state zipcode);
```




