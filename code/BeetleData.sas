/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*****                                                           *****/
/*****              STAT0023: beetle mortality data              *****/
/*****                                                           *****/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

/*      The next command labels each page in the output              */

TITLE "STAT0023: Beetle mortality data";

/*      Read the beetle mortality data into a SAS dataset called     */
/*      beetledata using the "datalines" statement, and save in      */
/*      the STAT0023 library.                                        */

DATA STAT0023.beetledata;
	INPUT logdose totals killed;
	proportion = killed / totals;
	FORMAT proportion 6.3;
	IF logdose > 1.8 THEN dosegroup = "High";
	ELSE dosegroup = "Low";
	DATALINES;
1.6907 59 6
1.7242 60 13
1.7552 62 18
1.7842 56 28
1.8113 63 52
1.8369 59 53
1.8610 62 61
1.8839 60 60
;

PROC PRINT DATA=STAT0023.beetledata;
RUN;

PROC PLOT;
	PLOT proportion*logdose;
RUN;

TITLE "Proportion of insects killed";
SYMBOL1 VALUE=squarefilled CV=red;

PROC GPLOT DATA=STAT0023.beetledata;
	PLOT proportion*logdose / HAXIS=axis1 VAXIS=axis2;
	AXIS1 LABEL=("log10 CS2 concentration (mg l^-1)");
	AXIS2 LABEL=("Proportion");
RUN;
QUIT;
