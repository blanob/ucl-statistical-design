/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*****                                                           *****/
/*****              STAT0023: a first SAS program                *****/
/*****                                                           *****/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

/*      The next command labels each page in the output              */

TITLE "STAT0023: Galapagos biodiversity data";

/*      Read the data, and store in a SAS dataset called Galapagos.  */
/*      Note that SAS needs to know the variable names (which are    */
/*      given on the first line of the data file), but which are     */
/*      not read directly - notice the FIRSTOBS=2 argument, which    */
/*      tells SAS to start reading the observations from line 2      */
/*      of the data file. Notice also the dollar symbol "$" after    */
/*      "Island": this tells SAS that "Island" is a character        */
/*      variable and not numeric.                                    */
		
DATA Galapagos; 
	INFILE "galapagos.dat" FIRSTOBS=2;
	INPUT Island $ Species Endemics Area Elevation Nearest Scruz Adjacent; 
RUN;

/*      Show the data      */

PROC PRINT;
RUN;

/*      Summarise the numeric variables	    */

PROC MEANS;
RUN;

/*      Plot number of species against island area	*/

PROC PLOT;
	PLOT Species*Area;
RUN;

/*	A "high-quality" (according to SAS) plot. Notice the use of global   */
/*	commands TITLE and SYMBOL1 to define the plot heading and symbol     */
/*  colour / type.                                                       */

TITLE "Galapagos biodiversity data: numbers of species vs island area (km^2)";
SYMBOL1 VALUE=dot CV=blue;
PROC GPLOT DATA=Galapagos;
	PLOT Species*Area / HAXIS=axis1 VAXIS=axis2;
	AXIS1 LABEL=("Island area (km^2)");
	AXIS2 LABEL=("Number of species");
RUN;
QUIT;   /*    "quit" needed for proc gplot interactive annotation allowed up to here)  */

/*		And with log scales		*/

PROC GPLOT DATA=Galapagos;
	PLOT Species*Area / HAXIS=axis1 VAXIS=axis2;
	AXIS1 LABEL=("Island area (km^2)") LOGBASE=10;
	AXIS2 LABEL=("Number of species") LOGBASE=10;
RUN;
QUIT;   /*    "quit" needed for proc gplot interactive annotation allowed up to here)  */

/*		Save the temporary (work library) "Galapagos" dataset        */
/*      to the (permanent) STAT0023 library.		                 */

DATA STAT0023.galapagos;
	SET Galapagos;
RUN;


