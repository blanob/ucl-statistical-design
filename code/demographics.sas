/**********************************************************************/
/**********************************************************************/
/*****     Simple analyses with the SAS demographics dataset.     *****/
/*****     This script isn't commented as comprehensively as      *****/
/*****     most of the others: use it in conjunction with the     *****/
/*****     workshop notes. The relevant sections of the notes     *****/
/*****            are indicated in the comments below.            *****/
/**********************************************************************/
/**********************************************************************/
TITLE "Analysis of SAS demographics dataset";

/************************************************************************************/
/*     SECTIONS 2.1 & 2.2: look at the metadata, and the first few rows of data     */
/************************************************************************************/
PROC CONTENTS DATA=sashelp.demographics VARNUM;
RUN;
PROC PRINT DATA=sashelp.demographics (OBS=5) NOOBS;
RUN;

/***********************************************************/
/*     SECTION 3.1: summaries of the numeric variables     */
/***********************************************************/
PROC MEANS DATA=sashelp.demographics;
RUN;

PROC MEANS DATA=sashelp.demographics MAXDEC=3 FW=8;
  VAR popAGR popUrban totalFR MaleSchoolPct FemaleSchoolPct;
RUN;

OPTIONS linesize=90 nodate;
PROC MEANS DATA=sashelp.demographics MAXDEC=3 FW=8;
  VAR popAGR popUrban totalFR MaleSchoolPct FemaleSchoolPct;
RUN;

OPTIONS linesize=92;
PROC MEANS DATA=sashelp.demographics N MEAN STD MIN Q1 MEDIAN Q3 MAX MAXDEC=3 FW=8;
  VAR popAGR popUrban totalFR MaleSchoolPct FemaleSchoolPct;
RUN;

/*		Produce summary statistics by CLASS region.		*/

PROC MEANS DATA=sashelp.demographics N MEAN STD MIN MAX MAXDEC=3 FW=8;
  CLASS region;
  VAR MaleSchoolPct FemaleSchoolPct;
RUN;

/*		Sort the data set BY region first, and produce respective summary statistics.		*/

PROC SORT DATA=sashelp.demographics OUT=demographics_sorted;
  BY region;
PROC MEANS DATA=demographics_sorted N MEAN STD MIN MAX MAXDEC=3 FW=8;
  BY region;
  VAR MaleSchoolPct FemaleSchoolPct;
RUN;

/****************************************/
/*    SECTION 3.2: frequency tables     */
/****************************************/
PROC FREQ DATA=sashelp.demographics;
  TABLES cont*region / NOPERCENT NOROW NOCOL;	
RUN;

/****************************************************/
/*    SECTION 4.1: histograms and density estimates */
/****************************************************/
PROC UNIVARIATE DATA=sashelp.demographics;
  VAR MaleSchoolpct FemaleSchoolpct;
  HISTOGRAM;
RUN;

TITLE "Estimated probability density function";
PROC UNIVARIATE DATA=sashelp.demographics NOPRINT;
  VAR FemaleSchoolpct;
  HISTOGRAM / NOBARS KERNEL(LOWER=0 UPPER=1 C=SJPI W=3);
  INSET MEAN (5.2) STD="Std Dev" (5.2) Q1 (5.2) MEDIAN (5.2) Q3 (5.2);
RUN;

/*****************************************************************************/
/*	 SECTION 4.2: boxplots. Note the need to use demographics_sorted     */
/*****************************************************************************/
TITLE "Education access in different world regions";
PROC BOXPLOT DATA=demographics_sorted;
  PLOT (MaleSchoolPct FemaleSchoolPct)* Region;
RUN;

/*************************************************************************************/
/*   SECTION 4.3: barcharts, to show frequency distributions and other quantities    */
/*************************************************************************************/
TITLE "Numbers of countries in each region";
PROC GCHART DATA=sashelp.demographics;
  VBAR region;
RUN;
QUIT;

PROC GCHART DATA=sashelp.demographics;
  VBAR region / DESCENDING;
RUN;

TITLE "Mean of national income per capita, in each region";
PROC GCHART DATA=sashelp.demographics;
  VBAR region / DESCENDING SUMVAR=gni TYPE=MEAN;
RUN;
QUIT;

TITLE "Regional mean income per capita";
PROC GCHART DATA=sashelp.demographics;
  VBAR region / DESCENDING SUMVAR=gni TYPE=MEAN FREQ=pop;
RUN;
QUIT;

PROC GCHART DATA=sashelp.demographics;
  HBAR region / DESCENDING SUMVAR=gni TYPE=MEAN FREQ=pop;
RUN;
QUIT;

/**********************************/
/*   SECTION 4.4: Scatterplots    */
/**********************************/
TITLE "Gender differences in access to primary education, by region";
PROC GPLOT DATA=sashelp.demographics;
  PLOT FemaleSchoolPct*MaleSchoolPct =region;
RUN;
QUIT;

GOPTIONS colors=(blue gold red);
PROC GPLOT DATA=sashelp.demographics;
  PLOT FemaleSchoolPct * MaleSchoolPct = region / HAXIS=axis1 VAXIS=axis2;
  AXIS1 LABEL=("Male enrolment") WIDTH=2;
  AXIS2 LABEL=("Female enrolment") WIDTH=2;
  SYMBOL1 VALUE=squarefilled;
  SYMBOL2 VALUE=trianglefilled;
RUN;
QUIT;
/**********************************************************************/
/*****     END OF SUPPLIED CODE, YOU'RE ON YOUR OWN FROM HERE!    *****/
/**********************************************************************/

TITLE "STAT0023: Demographics data";

/********************************************************************************/
/*		SECTION 2.1: Confidence intervals for population means		*/
/********************************************************************************/

/*		Approximate 95% and 99% confidence intervals using CLM, or alternatively LCLM and UCLM.		*/
PROC MEANS DATA=sashelp.demographics MEAN CLM ALPHA=.05 MAXDEC=3 FW=8;
	VAR FemaleSchoolPct MaleSchoolPct;
RUN;
PROC MEANS DATA=sashelp.demographics MEAN LCLM UCLM ALPHA=.05 MAXDEC=3 FW=8;
	VAR FemaleSchoolPct MaleSchoolPct;
RUN;

PROC MEANS DATA=sashelp.demographics MEAN CLM ALPHA=.01 MAXDEC=3 FW=8;
	VAR FemaleSchoolPct MaleSchoolPct;
RUN;
PROC MEANS DATA=sashelp.demographics MEAN LCLM UCLM ALPHA=.01 MAXDEC=3 FW=8;
	VAR FemaleSchoolPct MaleSchoolPct;
RUN;

/************************************************************************************************/
/*		SECTION 2.3: Chi-squared tests for association in contingency tables		*/
/************************************************************************************************/

/*		Test for association between region and cont variables.		*/
PROC FREQ DATA=sashelp.demographics;
	TABLES cont*region / NOPERCENT NOROW NOCOL CHISQ;
RUN;

/************************************************************************/
/*		SECTION 2.3: Two-sample and paired t-tests		*/
/************************************************************************/

PROC TTEST DATA=sashelp.demographics;
	PAIRED MaleSchoolPct*FemaleSchoolPct;
RUN;

DATA STAT0023.demographics_income;
	SET sashelp.demographics;
	IF GNI=. THEN Income=' ';
	ELSE IF GNI>10000 THEN Income="High";
	ELSE Income="Low";
RUN;

PROC PRINT DATA=STAT0023.demographics_income (OBS=5) NOOBS;
RUN;

/*		The two-sample t-test suggests that we should reject the null hypothesis. Girls in High- and Low- income countries		*/
/*              do not have the same level of access to primary education.                                                                      */

PROC TTEST DATA=STAT0023.demographics_income;
	VAR FemaleSchoolPct;
	CLASS Income;
RUN;

PROC TTEST DATA=STAT0023.demographics_income;
	VAR MaleSchoolPct;
	CLASS Income;
RUN;

PROC UNIVARIATE DATA=sashelp.demographics;
	CLASS region;
	VAR totalFR;
	OUTPUT OUT=pctl_Data pctlpts=90 pctlpre=p_;
RUN;

PROC TTEST DATA=STAT0023.demographics_income;
	VAR popUrban;
	CLASS Income;
RUN;

/*		Compute the 40th percentile of totalFR across all countries		*/
PROC MEANS DATA=sashelp.demographics P40 MAXDEC=3;
	VAR totalFR;
RUN;

/*		Compute the upper quartile of popUrban across all countries in the AMR region		*/
PROC MEANS DATA=sashelp.demographics Q3 MAXDEC=3;
	VAR popUrban;
	CLASS region;
RUN;

/*		Compute the number of low-income countries in the AMR region		*/
PROC FREQ DATA=STAT0023.demographics_income;
 	TABLES Income*region / NOPERCENT NOROW NOCOL;	
RUN;

/*		Compute the lower end of a 99% confidence interval for the difference between the underlying means		*/ 
/*		of FemaleSchoolpct for high- and low-income countries                                                           */
PROC TTEST DATA=STAT0023.demographics_income ALPHA=.01;
	VAR FemaleSchoolpct;
	CLASS Income;
RUN;
