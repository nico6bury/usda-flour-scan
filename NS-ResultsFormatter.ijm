/*
 * Author: Nicholas Sixbury
 * File: NS-ResultsFormatter.ijm
 * Purpose: To post-process results tables 
 * in order to make things easier to display 
 * and/or export to excel.
 * 
 * Explanation of Parameter Passing: Each serialized parameter should be
 * separated by the \r character. For each parameter, it should be the name
 * followed by the value, separated by the ? character. Parameters not given
 * will simply use the default, but it is a best practive to specify things
 * in case the default happens to change.
 * 
 * Pre-Execution Contract: This macro assumes that before being executed,
 * there does not exist an open window titled Results. If you want to run
 * this macro when the results window is open, it is recommended to either
 * close the window or rename it (possibly renaming it back to Results after
 * this macro has finished). It also assumes that two result windows are open
 * with names specified in the macro parameters.
 * 
 * Post-Execution Contract: When this macro exits, a new window will have
 * been created from the two input windows. It will contain the following
 * columns (unless I update something and forget to fix this comment): 
 * Rep, Slice, Rot, Side, Count, Pixels, %Area, 
 * l*Mean, L*Stdev, a*Mean, a*Stdev, b*Mean, b*Stdev.
 * 
 * Parameters that can be set in headless execution mode:
 * mainSummaryName : name of window with particle results
 * labResultsName : name of window with L*a*b* results
 * nFilesProcessed : number of files that have been processed
 */

/// just a few useful variables for later
mainSummaryName = "Summary";
labResultsName = "L*a*b* Results";
nFilesProcessed = 0;

serializedArguments = getArgument();
if(lengthOf(serializedArguments) == 0){
	Dialog.create(" Macro Options ???");
	Dialog.addString("Main Summary Name", mainSummaryName, 15);
	Dialog.addString("L*a*b* Results Name", labResultsName, 15);
	Dialog.addNumber("Number of Files Processed", 0);
	Dialog.show();
	mainSummaryName = Dialog.getString();
	labResultsName = Dialog.getString();
	nFilesProcessed = Dialog.getNumber();
}//end if we don't have arguments to read
else{
	// automatically set batch mode to true
	//useBatchMode = true;
	// parse out parameters from arguementSerialized
	linesToProcess = split(serializedArguments, "\r");
	for(i = 0; i < lengthOf(linesToProcess); i++){
		thisLine = split(linesToProcess[i], "?");
		if(thisLine[0] == "mainSummaryName"){
			mainSummaryName = thisLine[1];
		}//end if this line contains main summary name
		else if(thisLine[0] == "labResultsName"){
			labResultsName = thisLine[1];
		}//end if this line contains lab results name
		else if(thisLine[0] == "nFilesProcessed"){
			nFilesProcessed = parseInt(thisLine[1]);
		}//end if this line gives us the number of files that were processed
	}//end looping over lines to be deserialized
}//end else we need to parse the arguments we've been given

/// Basic Rundown of what to do
/// 1. Create a new table with all the columns we like
/// 2. Process the filenames of the samples to get Rep, Slice, Rot, Side columns
/// 3. Add processed filenames to the new table along with non-processed stuff
/// 4. At the same time, for each line in results table we get, get three lines
/// 	from Lab table, add those to right places
