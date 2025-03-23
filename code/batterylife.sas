/******************************************************************************
*******************************************************************************
*******************************************************************************
******                                                                   ******
******     STAT0023 Workshop 9: analysis of battery life data using      ******
******        PROC GLM, to illustrate mixtures of continuous and         ******
******                categorical covariates in regression               ******
******                                                                   ******
*******************************************************************************
*******************************************************************************
******************************************************************************/
/****
*****     Read in the battery life data !!!! SEE WORKSHOP NOTES FOR EXPLANATION !!!!
****/
DATA STAT0023.battlife;
  IF _N_ <=2 THEN Material=1;
    ELSE IF _N_ <=4 THEN Material=2;
    ELSE Material=3;
  DO i=0 TO 2;
    Temp = 15 + (55*i);
	TempSq = Temp*Temp;
    INPUT life @@;
    OUTPUT;
    INPUT life @@;
    OUTPUT;
  END;
  DATALINES;
    130 155  34  40 20  70
     74 180  80  75 82  58
    150 188 136 122 25  70
    159 126 106 115 58  45
    138 110 174 120 96 104
    168 160 150 139 82  60
;
RUN;
/****
*****     Plot: set up some nice symbols, axis labels etc. The basic 
*****     setup of the GPLOT command is very like one of the demographics
*****     examples from Workshop 8, but with a couple of new concepts:
*****
*****     - H=2 in the SYMBOL statements means "make the symbols twice
*****       the default size"
*****     - Notice the LEGEND global statement: the LABEL option defines 
*****       the legend title, and FRAME draws a box round it. This 
*****       works the same way as the AXIS and SYMBOL statements: 
*****       in the GPLOT procedure we say "use the legend defined by
*****       the specification in LEGEND1". 
****/
AXIS1 LABEL=('Temperature (degrees F)') W=2;
AXIS2 LABEL=(ANGLE=90 'Battery life (hours)') W=2;
SYMBOL1 VALUE=dot CV=blue H=2;
SYMBOL2 VALUE=squarefilled CV=red H=2;
SYMBOL3 VALUE=trianglefilled CV=gold H=2;
LEGEND1 LABEL=('Material type') FRAME;
PROC GPLOT DATA=STAT0023.battlife;
 PLOT Life*Temp =Material / HAXIS=axis1 VAXIS=axis2 LEGEND=legend1;
 TITLE 'Measurements of temperature and battery life';
RUN;
/****
*****     Start by fitting a model in which both material and temperature
*****     are treated as factors, with no interaction
*****/
TITLE 'Model 1: factor covariates with additive structure';
PROC GLM DATA=STAT0023.battlife;
  CLASS Temp Material;
  MODEL Life = Temp Material;
RUN;
QUIT;

TITLE 'Model 1: Life ~ Material Temp';
PROC GLM DATA=STAT0023.battlife;
  CLASS Material Temp;
  MODEL Life = Material Temp / SOLUTION;
RUN;
QUIT;
/****
*****     And the same again, with diagnostic plots and also the estimated effects
*****     for each material type !!!! SEE WORKSHOP NOTES !!!! 
*****     
****/
ODS HTML;
ODS GRAPHICS ON;
PROC GLM DATA=STAT0023.battlife PLOTS=DIAGNOSTICS;
  CLASS Temp Material;
  MODEL Life = Temp Material / SOLUTION;
  ESTIMATE 'Material 1 effect' Material 2 -1 -1 / DIVISOR=3;
  ESTIMATE 'Material 2 effect' Material -1 2 -1 / DIVISOR=3;
  ESTIMATE 'Material 3 effect' Material -1 -1 2 / DIVISOR=3;
RUN;
QUIT;
ODS GRAPHICS OFF;
ODS HTML CLOSE;
/****
*****     Notice that the fitted lines on the interaction plot are parallel:
*****     this is because the model is *additive* i.e. the effect of 
*****     material is assumed to be the same for all temperatures (and vice
*****     versa). We could fit a model with interaction, and test whether
*****     it seems to be an improvement. Actually though, all that's required 
*****     in SAS is to *fit* the model and look at the ANOVA tables in the 
*****     output. The one that you want is the "Type I SS", which gives
*****     the successive F statistics that you'd get if you gradually 
*****     increased the model in the order that the terms are defined. 
*****     It's probably worth producing the interaction plot here as
*****     well - but we won't bother with all the others. 
****/
ODS HTML;
ODS GRAPHICS ON;
TITLE 'Model 2: addition of a material:temperature interaction';
PROC GLM DATA=STAT0023.battlife PLOTS=INTPLOT(CLM);
  CLASS Temp Material;
  MODEL Life = Temp Material Temp*Material;
RUN;
QUIT;
ODS GRAPHICS OFF;
ODS HTML CLOSE;
/****
*****     Some evidence for interaction there? But also, with the confidence
*****	  intervals on the plot it looks as though we *might* get away with
*****     modelling the effect of temperature as linear - this would reduce
*****     the number of coefficients (2 coefficients for each material 
*****     instead of 3). 
****/
TITLE 'Model 3: temperature as a continuous covariate with linear effects';
PROC GLM DATA=STAT0023.battlife;
  CLASS Material;
  MODEL Life = Temp Material Temp*Material / SOLUTION;
RUN;
QUIT;
/****
*****     Does that help? Really it would be good to carry out a formal test, 
*****     to see whether we can justify simplifying the model in this way. 
*****     Unfortunately, it's really hard to convince SAS that Model 3 is 
*****     a special case of Model 2 (need to sit down with a pencil and 
*****     paper to write down exactly how the model parameters need to be 
*****     constrained to make things linear, and then use a CONTRASTS 
*****     statement in PROC GLM). As a very simple cheat, note that there are 
*****     just 3 unique temperatures, so if we fit a model that includes a 
*****     *quadratic* effect of temperature and its interactions with material,
*****     we'll get three temperature coefficients for each material and the 
*****     fit should be identical to Model 2. We can thus test for linearity
*****     by comparing linear and quadratic models. Note that TempSq was 
*****     defined in the DATA step. Also, to get a first impression, note that 
*****     by writing the quadratic terms at the end of the model we can read 
*****     off the "Type I SS" ANOVA table easily in the output. 
****/
TITLE 'Model 4a: temperature as a continuous covariate with quadratic effects';
PROC GLM DATA=STAT0023.battlife;
  CLASS Material;
  MODEL Life = Temp Material Temp*Material TempSq TempSq*Material / SOLUTION;
RUN;
QUIT;
/****
*****     Compare the error sum of squares for this model with that for Model 2.
*****     Does this satisfy you that the fitted values are indeed the same? 
*****     The only snag now is that the output has partitioned the sums of 
*****     squares and F-statistics into separate contributions from TempSq 
*****     and TempSq*Material: we want them combined into a *single* sum of
*****     squares, so that we can directly compare the models with a single 
*****     F-statistic. We can do it manually, of course: the reductions of 
*****     sums of squares associated with TempSq and TempSq*Material are
*****     76.05556 and 7298.694444 respectively, so the total reduction in 
*****     SS going from the "linear with interaction" model to the 
*****     "quadratic with interaction" model is 7374.75, on (1+2)=3 degrees
*****     of freedom. A solution is to take advantage of the fact that
*****     there are only 3 degrees of freedom associated with the TempSq
*****     and TempSq*Material terms combined, but there are 4 coefficients:
*****     so we can set one of the coefficients to zero without affecting
*****     the fit (indeed, this is what SAS does - you can see it when 
*****     you look at the coefficient estimates in the output). We can 
*****     take advantage of this: set the "TempSq" coefficient to zero,
*****     by dropping it from the model. Then SAS won't see it, won't 
*****     try and include it in the ANOVA table and we'll get what we
*****     want. @@@@ NB THIS IS ONE OF VERY FEW OCCASIONS WHEN IT IS 
*****     LEGITIMATE TO DROP A MAIN EFFECT WHEN THE CORRESPONDING 
*****     INTERACTION TERM IS PRESENT - YOU REALLY NEED TO KNOW WHAT
*****     YOU'RE DOING BEFORE ATTEMPTING THIS KIND OF THING!!! @@@@
****/
TITLE 'Model 4b: temperature as a continuous covariate (omitting main quadratic effect)';
PROC GLM DATA=STAT0023.battlife;
  CLASS Material;
  MODEL Life = Temp Material Temp*Material TempSq*Material;
RUN;
QUIT;
/****
*****     Check the reduction in Type 1 SS associated with the "TempSq*Material"
*****     term now, and verify that it is indeed what it should be. What do 
*****     you conclude: can the effect of temperature safely be assumed as 
*****     linear?
****/
