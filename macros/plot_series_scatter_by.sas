
%macro plot_series_scatter_by(dataset, series_x=, series_y=, scatter_x=, scatter_y=, group=, 
	min_y=, max_y=, label_x=, label_y=, log=0, title=, title2=, folder=, filename=, height=);

	ods listing style=statistical gpath=&folder.; 
	ods graphics on / reset=all border=off imagename=&filename. height=&height.;

	title &title.;
	title2 &title2.;

	proc sgplot data=&dataset. noautolegend;
		xaxis grid fitpolicy=rotatethin label=&label_x.;
		yaxis grid minor label=&label_y.
			%if &log.=1 %then %do;
				type=log logbase=10 logstyle=logexpand
			%end;
			%if %length(&min_y.) > 0 %then %do;
				min=&min_y.
			%end;
			%if %length(&max_y.) > 0 %then %do;
				max=&max_y.
			%end;
		;
		series x=&series_x. y=&series_y. / 
			group=&group.
			name="legend"
			lineattrs=(pattern=solid thickness=3);
		scatter x=&scatter_x. y=&scatter_y. / 
			group=&group.
			markerattrs=(size=6);
		keylegend "legend" / position=bottom;
	run;

	title "";
	title2 "";

	ods _all_ close;

%mend;