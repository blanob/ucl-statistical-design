/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*****                                                           *****/
/*****                 STAT0023: RainTemp data                   *****/
/*****                                                           *****/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

TITLE "STAT0023: RainTemp data";

DATA STAT0023.raintemp;
	INFILE "RainTemp.dat";
	INPUT Year 1-4 Month 5-6 Day 7-8 Station $ 9-12 Rain 13-18 Temp 19-24;
	IF Rain=-99.99 THEN Rain=.;
	ELSE Rain=Rain;
	IF Temp=-99.99 THEN Temp=.;
	ELSE Temp=Temp;
RUN;

PROC CONTENTS DATA=STAT0023.raintemp VARNUM;
RUN;

PROC PRINT DATA=STAT0023.raintemp (OBS=5) NOOBS;
RUN;

TITLE "Mean rainfall at each station";
PROC GCHART DATA=STAT0023.raintemp;
 	HBAR Station / DESCENDING SUMVAR=Rain TYPE=MEAN MAXIS=axis1 RAXIS=axis2;
	AXIS1 LABEL=("Station code");
	AXIS2 LABEL=("Mean rainfall (mm)");
RUN;
QUIT;

TITLE "Mean temperature at each station";
PROC GCHART DATA=STAT0023.raintemp;
    HBAR Station / DESCENDING SUMVAR=Temp TYPE=MEAN MAXIS=axis1 RAXIS=axis2;
    AXIS1 LABEL=("Station code");
    AXIS2 LABEL=("Mean temperature (degrees Celsius)");
    PATTERN COLOR=red;
RUN;
QUIT;

PROC MEANS DATA=STAT0023.raintemp NOPRINT;
    BY Year;
	CLASS Station;
	VAR Rain Temp;
    OUTPUT OUT=raintemp_annual (WHERE=(_type_=1)) MEAN= / AUTONAME; 
RUN;

TITLE "Annual mean temperatures and rainfalls at each site, 1960-1990";
PROC GPLOT DATA=raintemp_annual;
	PLOT Temp_Mean*Rain_Mean = Station;
RUN;
QUIT;

GOPTIONS colors=(blue gold red lime);
TITLE "Annual mean temperatures and rainfalls at each site, 1960-1990";
FOOTNOTE "Each point represents a single year's data at the corresponding station";
PROC GPLOT DATA=raintemp_annual;
	PLOT Temp_Mean*Rain_Mean = Station / HAXIS=axis1 VAXIS=axis2;
	AXIS1 LABEL=("Mean rainfall (mm)") WIDTH=2;
	AXIS2 LABEL=("Mean temperature (degrees Celsius)") WIDTH=2;
RUN;
QUIT;

/*		The largest value of rainfall across all stations		*/
PROC MEANS DATA=STAT0023.raintemp MAX MAXDEC=3 FW=8;
	VAR Rain;
RUN;

PROC MEANS DATA=STAT0023.raintemp MEAN MAXDEC=3 FW=8;
	CLASS Station;
	VAR Temp;
RUN;

/*		The largest value of temperature for station 3950		*/
PROC MEANS DATA=STAT0023.raintemp MAX MAXDEC=3 FW=8;
	CLASS Station;
	VAR Temp;
RUN;

PROC MEANS DATA=STAT0023.raintemp STD MAXDEC=3 FW=8;
	CLASS Station;
	VAR Rain;
RUN;

/*		The 70th percentile of temperature for station 3905		*/
PROC UNIVARIATE DATA=STAT0023.raintemp NOPRINT;
	CLASS Station;
	VAR Temp;
	OUTPUT OUT=pctlData pctlpts=70 pctlpre=p_;
RUN;

/*		The 40th percentile of temperature across all stations		*/
PROC MEANS DATA=STAT0023.raintemp P40 MAXDEC=3;
	VAR Temp;
RUN;

/*		The station with the lowest mean rainfall		*/
PROC MEANS DATA=STAT0023.raintemp MEAN MAXDEC=3 FW=8;
	CLASS Station;
	VAR Rain;
RUN;

/*		The 99% confidence interval for the mean temperature at station 1393		*/
PROC MEANS DATA=STAT0023.raintemp CLM ALPHA=.01 MAXDEC=3 FW=8;
	CLASS Station;
	VAR Temp;
RUN;

/*		The 95% confidence interval for the mean rainfall at station 3950		*/
PROC MEANS DATA=STAT0023.raintemp CLM ALPHA=.05 MAXDEC=3 FW=8;
	CLASS Station;
	VAR Rain;
RUN;

/*		The year of the first temperature observation at station 422		*/
PROC SORT DATA=STAT0023.raintemp OUT=temp_sorted NODUPKEY;
	BY Station;
RUN;

PROC PRINT DATA=temp_sorted;
	VAR Station Rain Year;
RUN;

/*		The station with the overall driest year by mean annual rainfall		*/
PROC MEANS DATA=raintemp_annual MIN;
	CLASS Station;
	VAR Rain_Mean;
RUN;
