/******************************************************************************
*******************************************************************************
*******************************************************************************
******                                                                   ******
******     STAT0023 Workshop 9: logistic regression modelling of         ******
******        proportions of wet days at northern Iberian weather        ******
******                          stations                                 ******
******                                                                   ******
*******************************************************************************
*******************************************************************************
******************************************************************************/
/****
*****     Read in the data. If I'd thought about this last week, you could 
*****     just re-use the dataset you've already created in Workshop 8, but we 
*****     didn't create the Wet variable there so need to do it again. 
*****     Note that I'll define a day as "Wet" if the rainfall is at least 1mm,
*****     because smaller amounts tend to be recorded inconsistently. Also,
*****     I'll define the "Site" variable as numeric rather than character here -
*****     it just makes for an easier life when sorting things later on. 
****/
DATA STAT0023.raintemp;
  INFILE "raintemp.dat";
  INPUT Year 1-4 Month 5-6 Day 7-8 Site 9-12 Rain 13-18 Temp 19-24;
  IF (Temp=-99.99) THEN Temp=.;
  IF (Rain=-99.99) THEN Rain=.;
  IF (Rain=.) THEN Wet=.;
    ELSE IF (Rain >= 1) THEN Wet=1;
    ELSE Wet=0;
RUN;
/****
*****     Now aggregate the data to an annual series, recording the total
*****     numbers of wet days and mean rainfall for each site and year.
*****     For explanation of the "(WHERE ...)" code !!!! SEE WORKSHOP NOTES !!!!
*****     Notice also that the statement "CLASS Site Year" orders the output
*****     primarily by site, and within that by year. This becomes important
*****     later on!
*****/
PROC MEANS DATA=STAT0023.raintemp NOPRINT;
  CLASS Site Year;
  VAR Rain Temp;
  OUTPUT OUT=Yearlyweather (WHERE=(_TYPE_=3 & NDaysR>360 & NDAysT>360)) 
         SUM(Wet)=Nwet MEAN(Temp)=Temp N(Rain)=NDaysR N(Temp)=NDaysT;
RUN;
/****
*****     Plot Nwet against Temp
****/
AXIS1 LABEL=('Temperature (degrees C)') W=2;
AXIS2 LABEL=(ANGLE=90 'Number of wet days') W=2;
GOPTIONS colors=(blue gold red lime);
SYMBOL1 VALUE=square;
SYMBOL2 VALUE=squarefilled;
SYMBOL3 VALUE=diamond;
SYMBOL4 VALUE=diamondfilled;
SYMBOL5 VALUE=triangle;
SYMBOL6 VALUE=trianglefilled;
SYMBOL7 VALUE=circle;
SYMBOL8 VALUE=dot;
LEGEND1 LABEL=('Station code') FRAME;
PROC GPLOT DATA=Yearlyweather;
 PLOT Nwet*Temp =Site / HAXIS=axis1 VAXIS=axis2 LEGEND=legend1;
 TITLE 'Annual numbers of wet days vs annual mean temperature';
RUN;
QUIT;
/****
*****     A naive person (who hadn't used different plotting symbols for the 
*****     different stations) might think there's a slight positive correlation
*****     between temperature and number of wet days. Assuming individual days
*****     days are independent, as a first attempt you might think that the 
*****     number of wet days in a year can be modelled using a binomial 
*****     distribution, so perhaps logistic regression may be suitable:
*****/
TITLE 'Model 1: logistic regression of number of wet days on temperature';
PROC GENMOD DATA=Yearlyweather;
  MODEL Nwet/NDaysR = Temp / DIST=bin LINK=logit;
RUN;
/****
*****     Looking at 95% confidence limits for coefficients, this confirms 
*****     a significant positive association between temperature and
*****     proportion of wet days. But the earlier plot suggested that 
*****     are substantial differences between stations, so add "Site" to
*****     the model as a factor. Also produce some residual plots:
*****     PLOTS=RESCHI(XBETA) produces plots of Pearson residuals (see
*****     workshop 6) agains the linear predictor (which has the matrix
*****     representation X'beta, hence XBETA).
****/
TITLE 'Model 2: including site effects';
ODS HTML;
ODS GRAPHICS ON;
PROC GENMOD DATA=Yearlyweather PLOTS=RESCHI(XBETA);
  CLASS Site;
  MODEL Nwet/NDaysR = Temp Site / DIST=bin LINK=logit;
RUN;
ODS GRAPHICS OFF;
ODS HTML CLOSE;
/****
*****     What does *this* suggest about the relationship between 
*****     temperature and wet days? 
*****
*****     Apart from that, it looks as though many of the Pearson residuals
*****     are greater than 2 in absolute value. We may have overdispersion,
*****     therefore (QUESTION: can you think of any possible causes of this
*****     overdispersion - e.g. reasons that the binomial assumption on the 
*****     number of wet days in a year might not be strictly correct?). To 
*****     deal with this, specify SCALE=PEARSON as an option to fit a 
*****     quasibinomial GLM (again, see Workshop 6):
****/
TITLE 'Model 3: quasibinomial';
PROC GENMOD DATA=Yearlyweather;
  CLASS Site;
  MODEL Nwet/NDaysR = Temp Site / DIST=bin LINK=logit SCALE=Pearson;
RUN;
QUIT;
/****
*****     Notice: the coefficient estimates haven't changed, just the standard errors. 
*****     Is there any evidence for differences in the temperature:wet days relationship
*****     between stations? Look at the AIC values after fitting the model below (I'd
*****     prefer to use a likelihood ratio test, but this requires a CONTRASTS statement
*****     in PROC GENMOD and this is messy with so many stations).
****/
TITLE 'Model 4: quasibinomial, with station*temperature interaction';
PROC GENMOD DATA=Yearlyweather;
  CLASS Site;
  MODEL Nwet/NDaysR = Temp Site Temp*Site / DIST=bin LINK=logit SCALE=Pearson;
RUN;
QUIT;
/****
*****     You should conclude that the relationships at different stations
*****     are indeed different. But there is presumably some reason for this.
*****     Perhaps we don't have to treat the stations entirely separately, 
*****     but there's something like altitude, latitude or longitude that 
*****     controls what's going on. In order to figure this out, we need some
*****     more information on the stations ... !!!! SEE WORKSHOP NOTES !!!!
****/
DATA Iberiastations;
  INFILE 'stations.csv' FIRSTOBS=2 DLMSTR=",";
  INPUT Site Name $ Latitude Longitude Altitude;
/****
*****     Check to see what that did
****/
TITLE 'Station information from file';
  PROC PRINT DATA=IberiaStations NOOBS;
RUN;
/****
*****     This is where it becomes important that the "Yearlyweather" data set
*****     is sorted in site order (see earlier comments). It means that we can 
*****     merge it with the "Iberiastations" data that we've just defined.
*****     In SAS, the default behaviour when merging data sets is to join 
*****     them up row-wise - which is fine if they have the same number of 
*****     rows, all in the right order, but that's not what we have here.
*****     What we need is called "match-merging" in SAS. 
****/
TITLE 'Weather and station information combined';
DATA YearlyAugmented;
 MERGE Yearlyweather Iberiastations;
 BY Site;
RUN;
/****
*****     Again, check to see what that did
****/
PROC PRINT DATA=YearlyAugmented (OBS=10);
RUN;
/****
*****     Now we can fit a logistic regression model using just altitude, 
*****     latitude and longitude as covariates, and see whether this does
*****     as well as the model that has a separate relationship for 
*****     every site.
****/
TITLE 'Model 5: quasibinomial, with station effects modelled via geographical information';
PROC GENMOD DATA=YearlyAugmented;
  MODEL Nwet/NDaysR = Temp Latitude Longitude Altitude 
                      Temp*Latitude Temp*Longitude Temp*Altitude / 
                      DIST=bin LINK=logit SCALE=Pearson;
RUN;
QUIT;
/****
*****     If you look at the AIC scores, you'll see that the model with 
*****     individual relationships for each station is preferred. 
*****     Perhaps we want to see what these relationships look like?
****/
ODS HTML;
ODS GRAPHICS ON;
PROC GENMOD DATA=Yearlyweather;
  CLASS Site;
  MODEL Nwet/NDaysR = Temp Site Temp*Site / DIST=bin LINK=logit SCALE=Pearson;
  EFFECTPLOT FIT (PLOTBY=Site);
RUN;
QUIT;
ODS GRAPHICS OFF;
ODS HTML CLOSE;
/****
*****     Look at those plots carefully. Does anything stand out? Are you
*****     interested in find out more? If so, you are in possession of 
*****     (a) all of the information (b) most of the knowledge needed to 
*****     do so ...
*****
*****     I know, that's an unsatisfactory way to end the course, many of
*****     you want *the answers*. If you're particularly interested in the 
*****     Iberian weather example, look at http://www.value-cost.eu/TS3. It's 
*****     all in R, but it shows what can be done with statistical techniques 
*****     that are available to all of you after completing this course.  
****/
