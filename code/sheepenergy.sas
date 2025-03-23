/******************************************************************************
*******************************************************************************
*******************************************************************************
******                                                                   ******
******     STAT0023 Workshop 9: simple regression analysis with SAS      ******
******       This SAS program contains some "blanks", denoted by         ******
******             "???". You must fill this in yourself.                ******
******                                                                   ******
*******************************************************************************
*******************************************************************************
******************************************************************************/
/****
*****     Read in the sheep energy data, and compute some new variables for 
*****     use later on. !!!! SEE WORKSHOP NOTES !!!!
****/
DATA STAT0023.energy;
  INFILE 'energy.dat' FIRSTOBS=2;
  INPUT Weight Energy; 
  WeightSq = Weight*Weight;
  WtLinear = Weight-35.9359;
  WtQuad = (Weight*Weight) - (78.2152*Weight) + 1430.4947;
RUN;
/****
*****     Plot: set up some nice symbols, axis labels etc. Notice how
*****     to rotate the vertical axis label.
****/
AXIS1 LABEL=('Weight (kg)') W=2;
AXIS2 LABEL=(ANGLE=90 'Energy requirement (Mcal / day)') W=2;
SYMBOL1 VALUE=dot CV=blue;
PROC GPLOT DATA=STAT0023.energy;
 PLOT Energy*Weight / HAXIS=axis1 VAXIS=axis2;
 TITLE 'Sheep energy requirements vs body weight';
RUN;
/****
*****     Here's a simple regression. !!!! SEE WORKSHOP NOTES !!!!
****/
TITLE 'Model 1: linear dependence of energy requirement on weight';
PROC REG DATA=STAT0023.energy;
  MODEL Energy=Weight;
RUN;
QUIT;
/****
*****     And the same again, storing residual information and fitted values; also
*****     showing how to produce diagnostic plots. To see these, you need to ensure
*****     that you're using HTML output rather than the usual "listing"; and that
*****     "ODS graphics" are enabled. This is what the first two commands do, 
*****     below (an alternative to the "Tools -> Options -> Preferences -> Results"
*****     menu choices that you made in Workshop 7 - it's much easier to control
*****     this directly in your script). As well as producing plots on screen, the 
*****     "ODS graphics" setting produces PNG files: you can view these by navigating 
*****     to them in the "Results" container (click the tab at the bottom left of 
*****     your SAS window). The disadvantage of ODS graphics, as you will discover,
*****     is that it is VERY slow. This is why I'm turning it on just for this 
*****     procedure, and then turning it off again afterwards. 
****/
ODS HTML;
ODS GRAPHICS ON;
PROC REG DATA=STAT0023.energy PLOTS=DIAGNOSTICS;
  MODEL Energy=Weight;
  OUTPUT OUT=EnergyMod1 PREDICTED=Pred RESIDUAL=Resid STUDENT=StudentResid;
RUN;
QUIT;
ODS GRAPHICS OFF;
/****
*****     Just to illustrate, we can use the output data set to recreate
*****     a plot of studentised residuals against predicted values (it
*****     isn't really needed here because you already have it in the 
*****     diagnostic plots - the purpose is solely to show how you 
*****     can treat an output data set like any other SAS data set).
****/
AXIS3 LABEL=('Fitted values') W=2;
AXIS4 LABEL=(ANGLE=90 'Studentised residuals') W=2;
PROC GPLOT DATA=EnergyMod1;
  PLOT Resid*Pred / HAXIS=axis3 VAXIS=axis4;
  TITLE 'Model 1: residuals versus fitted values';
RUN;
QUIT;
ODS HTML CLOSE;
ODS LISTING;
/****
*****     Now: there's not much evidence for it here, but suppose we
*****     wanted to fit a quadratic model to see if there was any
*****     evidence of nonlinearity in the relationship. In SAS
*****     you can't just write a term like "Weight**2" in the 
*****     model formula for PROC REG: it has to be defined already 
*****     in the data set. This is why the WeightSq variable was
*****     defined when we read the data. !!! SEE WORKSHOP NOTES !!!
*****
*****     As a further illustration of how to control the output,
*****     this time we'll send it to the "Output" window using
*****     ODS LISTING;
****/
TITLE 'Model 2: addition of a quadratic term';
PROC REG DATA=STAT0023.energy;
  MODEL Energy = Weight WeightSq;
RUN;
QUIT;
/****
*****     Looking at the t-statistics for the regression coefficients, 
*****     can you conclude anything? How does the apparent significance
*****     of the "Weight" coefficient compare with the corresponding
*****     result from your first model? Can you figure out what's 
*****     happening? 
*****
*****     Another way to determine whether it's worth adding a term or 
*****     terms to a model is to carry out a nested model comparison 
*****     using an F test. Here's one way of doing it using PROC
*****     REG:
****/
PROC REG DATA=STAT0023.energy;
  MODEL Energy = Weight WeightSq;
  LinearH0: TEST WeightSq=0;
RUN;
QUIT;
/****
*****     Where have you seen that p-value before? What can you conclude?
*****     As a final model to try, here's one with the 'WtLinear' and
*****     'WtQuad' variables defined in the DATA step: these are 'linear'
*****     and 'quadratic' transformations of the 'Weight' variable. 
****/
TITLE 'Model 3: transforming the covariates';
PROC REG DATA=STAT0023.energy;
  MODEL Energy = WtLinear WtQuad;
  LinearH0: TEST WtQuad=0;
RUN;
QUIT;
/****
*****     Compare the coefficient estimates, t-statistics, F-statistic and 
*****     p-values with those from Models 1 and 2. Have you worked out
*****     what's happening yet? Probably, but just to confirm ... 
****/
PROC CORR DATA=STAT0023.energy NOPROB; /*  NOPROB suppresses the printing of p-values  */
RUN;
/****
*****     An alternative to PROC REG is PROC GLM (!!!! SEE WORKSHOP NOTES !!!!)
*****     Since Model 1 seems appropriate, here it is again with PROC GLM. Notice
*****     that the SOLUTION option to the MODEL statement is needed to get
*****     the coefficient estimates to appear in the output. 
****/
TITLE 'Model 1, refitted using PROC GLM';
PROC GLM DATA=STAT0023.energy;
  MODEL Energy = Weight / SOLUTION;
RUN;
QUIT;
