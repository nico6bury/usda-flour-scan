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
	Dialog.addNumber("Number of Files Processed", nFilesProcessed);
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

// strip results from given windows in order to use it in processing.
selectWindow(mainSummaryName);
IJ.renameResults(mainSummaryName,"Results");
String.copyResults;
// note: lines separated by \n, columns by \t, first column is space
summaryResults = split(String.paste, "\n");
run("Close");
selectWindow(labResultsName);
IJ.renameResults(labResultsName,"Results");
String.copyResults;
labResults = split(String.paste, "\n");
run("Close");
// create the table we'll use for displaying everything
finalResultsName = "ResultsTable";
Table.create(finalResultsName);

// figure out column indices before we start iteration
summaryColumns = split(summaryResults[0], "\t");
labColumns = split(labResults[0], "\t");
sliceIndex = arrayIndexOf(summaryColumns, "Slice");
countIndex = arrayIndexOf(summaryColumns, "Count");
pixelsIndex = arrayIndexOf(summaryColumns, "Total Area");
percentIndex = arrayIndexOf(summaryColumns, "%Area");
meanIndex = arrayIndexOf(labColumns, "Mean");
sdevIndex = arrayIndexOf(labColumns, "StdDev");

for(i = 0; i < nFilesProcessed; i++){
	// make sure we have the right window selected
	selectWindow(finalResultsName);
	// get the lines from summary table split up for easy use
	thisSummaryLine = split(summaryResults[i+1], "\t");
	// process slice column to separate the information we want
	nameWoExtn = thisSummaryLine[sliceIndex];
	nameWoExtn = substring(nameWoExtn, 0, indexOf(nameWoExtn, "."));
	nameSplit = split(nameWoExtn, "-");
	// add the names we figured out to the cool table we're building
	Table.set("Rep", i, nameSplit[0]);
	Table.set("Slice", i, nameSplit[1]);
	Table.set("Rot", i, nameSplit[2]);
	Table.set("Side", i, nameSplit[3]);
	// add non-processed columns to right place in the table
	Table.set("Count", i, thisSummaryLine[countIndex]);
	Table.set("Pixels", i, thisSummaryLine[pixelsIndex]);
	Table.set("%Area", i, thisSummaryLine[percentIndex]);
	// get indices for lab columns
	li = i * 3 + 1;
	ai = i * 3 + 2;
	bi = i * 3 + 3;
	// split up the three lab lines we want
	thisLLine = split(labResults[li], "\t");
	thisALine = split(labResults[ai], "\t");
	thisBLine = split(labResults[bi], "\t");
	// add the stuff from lab columns where its supposed to go
	Table.set("L*Mean", i, thisLLine[meanIndex]);
	Table.set("L*StdDev", i, thisLLine[sdevIndex]);
	Table.set("a*Mean", i, thisALine[meanIndex]);
	Table.set("a*StdDev", i, thisALine[sdevIndex]);
	Table.set("b*Mean", i, thisBLine[meanIndex]);
	Table.set("b*StdDev", i, thisBLine[sdevIndex]);
}//end looping over each file that has been processed

function arrayIndexOf(array, value){
	
	for(i = 0; i < lengthOf(array); i++){
		if(array[i] == value){
			return i;
		}
	}
	return -1;
}
