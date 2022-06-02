//
//  NS-DB-SG  May26 flour scan automated 10
//  May2022
//
//   simplified particle counts of smut?
//

// upper threshold for processing
th01 = 170;


// define temporary variables for storing dialog results
// whether or not we'll use batch mode, which really speeds things up
useBatchMode = false;
// all the valid selection methods we might use
selectionMethods = newArray("Single File", "Multiple Files", "Directory");
// the path of the file we're processing. Might be a directory
chosenFilePath = "";
// the selection method we're actually going with
selectionMethod = selectionMethods[2];
// whether or not we should display a helpful progress bar for the user
shouldDisplayProgress = true;
// valid operating systems
validOSs = newArray("Windows 10", "Windows 7");
// chosen operating system
chosenOS = validOSs[0];
// filenames with these strings will be ignored in directory selection
forbiddenStrings = newArray("-Skip");
// the only file extension we won't ignore in directory selection
expectedFileExtensions = newArray(".bmp",".tif",".tiff");
// save something before it's overwritten
baseThreshold = th01;
// whether we should display particle detection to the user
showParticles = false;
// Warn the user if they want to view the particles of lots of images
particleShowSoftLim = 10
// whether or not to append threshold to summary
appendThreshold = false;
// default lower size limit
szMin=2;
// default upper size limit
defSizeLimit = 200;
// whether or not to append size limit to summary
appendSize = false;

// define dialog window
Dialog.create("Macro Options");
// first section, first line
Dialog.addChoice("File Selection Method:", selectionMethods, selectionMethod);
Dialog.addToSameRow();
Dialog.addChoice("Current Operating System", validOSs, chosenOS);
// second line
//Dialog.addString("Results File Name", "Summary");
Dialog.addSlider("Threshold", 1, 255, th01);
Dialog.addToSameRow();
Dialog.addCheckbox("Append Threshold to Summary Window", appendThreshold);
// third line
Dialog.addCheckboxGroup(2, 1, newArray("Don't draw images to improve performance",
"Show progress bar with predicted times"), newArray(useBatchMode, shouldDisplayProgress));
// fourth line
Dialog.addCheckbox("Show Particle Detection on Image", false);
// fifth line
Dialog.addNumber("Lower Size Limit", szMin);
Dialog.addToSameRow();
Dialog.addNumber("Upper Size Limit", defSizeLimit);
// sixth line
Dialog.addCheckbox("Append Size limit to Summary Window", appendSize);

// get selected options from dialog window
Dialog.show();
// get user selections from first line
selectionMethod = Dialog.getChoice();
chosenOS = Dialog.getChoice();
// get user selections from second line
//resultsFilename = Dialog.getString();
th01 = Dialog.getNumber();
appendThreshold = Dialog.getCheckbox();
// get user selections from third line
useBatchMode = Dialog.getCheckbox();
shouldDisplayProgress = Dialog.getCheckbox();
// get user selection from fourth line
showParticles = Dialog.getCheckbox();
// get user selection from fifth line
szMin = Dialog.getNumber();
defSizeLimit = Dialog.getNumber();
// get user selection from sixth line
appendSize = Dialog.getCheckbox();
// debug feature for doing infinite max size
infinitySwitch = false;

// act on selected options from dialog window
if(chosenOS == validOSs[1]){
	showMessageWithCancel("WARNING","You've selected Windows 7 as the operating "+
	"system that you're using. The threshold used by this program was tested for"+
	" Windows 10, and there might be differences in thresholding between operating"+
	" systems. At present, this macro does not do anything to account for that, "+
	"so please proceed with caution.");
}//end if chosenOS was Windows 7

// start actually processing all the files
// based on the selection method provided by user and 
// a whole bunch of tests and checks, gets valid file names
filesToProcess = getFilepaths(selectionMethod);
// batch mode
if(useBatchMode){
	if(showParticles){
		showMessageWithCancel("Complication",
		"You selected both that you wanted batch mode and that you wanted to show "+
		"particles. This isn't really possible, so if you want to see particles, "+
		"keep the option that mentions not showing pictures off. Press cancel to "+
		"immediately stop the macro.");
	}//end if user also wants to show particles
	setBatchMode("hide");
}//end if we should use batch mode
if(showParticles && lengthOf(filesToProcess) > particleShowSoftLim){
	showMessageWithCancel("Quick Warning","Just an FYI, you have " +
	lengthOf(filesToProcess) + " files selected to process. You have also \n"+
	"told this macro that you want to stop and look at the particles for every \n"+
	"image. Are you sure about this? If you want to continue anyways, click OK. \n"+
	"If you want to quit and select fewer images, click cancel. Note that you \n"+
	"can queue up a specific number of images to go through by using the file \n"+
	"selection method of [Multiple Files].");
}//end if user wants to show particles for lots of files
// initialize stuff for progress bar
prgBarTitle = "[Progress]";
timeBeforeProc = getTime();
if(shouldDisplayProgress){
	run("Text Window...", "name="+ prgBarTitle +"width=70 height=2.5 monospaced");
}//end if we should display progress
for(i = 0; i < lengthOf(filesToProcess); i++){
	if(shouldDisplayProgress){
		// display a progress window thing
		timeElapsed = getTime() - timeBeforeProc;
		timePerFile = timeElapsed / (i+1);
		eta = timePerFile * (lengthOf(filesToProcess) - i);
		print(prgBarTitle, "\\Update:" + i + "/" + lengthOf(filesToProcess) +
		" files have been processed.\n" + "Time Elapsed: " + timeToString(timeElapsed) + 
		" sec.\tETA: " + timeToString(eta) + " sec."); 
	}//end if we should display progress bar

	// actually actually start processing
	open(filesToProcess[i]);
	processFile();
	
	run("Close All");
}//end looping over each file we need to process

if(shouldDisplayProgress){
	timeElapsed = getTime() - timeBeforeProc;
	print(prgBarTitle, "\\Update:" + lengthOf(filesToProcess) + "/" +
	lengthOf(filesToProcess) + " files have been processed.\n" + "Time Elapsed: "
	+ timeToString(timeElapsed) + " sec.\tETA: 0 sec."); 
}//end if we should display our progress

if(useBatchMode){
	setBatchMode("exit and display");
}//end if we have been using batch mode

curSummaryTitle = "Summary";

if(appendThreshold){
	if(isOpen(curSummaryTitle)){
		selectWindow(curSummaryTitle);
		curSummaryTitle = getInfo("window.title");
		newSummaryTitle = curSummaryTitle+"TH"+th01;
		Table.rename(curSummaryTitle, newSummaryTitle);
		curSummaryTitle = newSummaryTitle;
	}//end if the summary window is even open
}//end if we should append threshold to name of summary

if(appendSize){
	if(isOpen(curSummaryTitle)){
		selectWindow(curSummaryTitle);
		curSummaryTitle = getInfo("window.title");
		newSummaryTitle = curSummaryTitle+"-SizeLimit"+szMin+"-";
		if(infinitySwitch == false){
			newSummaryTitle += defSizeLimit;
		}//end if we use normal defined size limit
		else{
			newSummaryTitle += "Infinity";
		}//end else we use infinite size
		Table.rename(curSummaryTitle, newSummaryTitle);
		curSummaryTitle = newSummaryTitle;
	}//end if the summary window is even open
}//end if we should appent size limit to name of summary

///////////// MAIN FUNCTION START ///////////////

/*
 * Performs all the processing for a particular file. Code is all
 * from DB and SG.
 */
function processFile(){	
	run("Duplicate...", " ");
	
	run("Sharpen");
	run("Smooth");
	
	run("8-bit");
	
	//run("Threshold...");
	setThreshold(0, th01);
	//setOption("BlackBackground", false);
	run("Convert to Mask");

	// set the scale so it doesn't measure in mm or something
	run("Set Scale...", "distance=0 known=0 unit=pixel global");
	// specify the measurement data to recieve from analyze particles
	run("Set Measurements...", "area perimeter bounding redirect=None decimal=1");
	
	
	if(infinitySwitch == true){
		defSizeLimit = "Infinity";
		run("Analyze Particles...", "size=szMin-Infinity "+
	"show=[Overlay Masks] display clear summarize");
	}//end if we should do infinite max size
	else{
		run("Analyze Particles...", "size=szMin-defSizeLimit "+
		"show=[Overlay Masks] display clear summarize");
	}//end else use defined size limit
	
	if(showParticles && !is("Batch Mode")){
		waitForUser("Particle showcase", "Particles should be outlined in blue\n"+
		"Parts of the image within the threshold should be outlined in black");
	}//end if particles can be visible and they should be
}//end processFile(filename)

////////////// MAIN FUNCTION END ////////////////

///////////// START OF SUPPORT FUNCTIONS ///////////////
function timeToString(mSec){
	floater = d2s(mSec, 0);
	floater2 = parseFloat(floater);
	floater3 = floater2 / 1000;
	return floater3;
}//end timeToString()

/*
 * Given a method of selecting files, prompts user to select files, 
 * and then returns an array of file paths
 */
function getFilepaths(fileSelectionMethod){
	// array to store file paths in
	filesToPrc = newArray(0);
	if(selectionMethod == "Single File"){
		filesToPrc = newArray(1);
		filesToPrc[0] = File.openDialog("Please choose a file to process");
	}//end if we're just processing a single file
	else if(selectionMethod == "Multiple Files"){
		numOfFiles = getNumber("How many files would you like to process?", 1);
		filesToPrc = newArray(numOfFiles);
		for(i = 0; i < numOfFiles; i++){
			filesToPrc[i] = File.openDialog("Please choose file " + (i+1) + 
			"/" + (numOfFiles) + ".");
		}//end looping to get all the files we need
	}//end if we're processing multiple single files
	else if(selectionMethod == "Directory"){
		chosenDirectory = getDirectory("Please choose a directory to process");
		// gets all the filenames in the directory path
		filesToPrc = getValidFilePaths(chosenDirectory, forbiddenStrings);
	}//end if we're processing an entire directory
	return filesToPrc;
}//end getFilepaths(fileSelectionMethod)

/*
 * returns an array of valid file paths in the specified
 * directory. Any file whose base name contains a string within
 * the forbiddenStrings array will not be added.
 */
function getValidFilePaths(directory, forbiddenStrings){
	// gets array of valid file paths without forbidden strings
	// just all the filenames
	baseFileNames = getAllFilesFromDirectories(newArray(0), directory);
	// just has booleans for each filename
	q = forbiddenStrings;
	boolArray = areFilenamesValid(baseFileNames, q, false);
	// number of valid filenames we found
	correctFileNamesCount = countTruths(boolArray);
	// initialize our new array of valid names
	filenames = newArray(correctFileNamesCount);
	// populate filenames array
	j = 0;
	for(i = 0; i < lengthOf(boolArray) && j < lengthOf(filenames); i++){
		if(boolArray[i] == true){
			filenames[j] = baseFileNames[i];
			j++;
		}//end if we have a truth
	}//end looping for each element of boolArray
	return filenames;
}//end getValidFilePaths(directory)

/*
 * just returns the number of elements in array which are true
 */
function countTruths(array){
	truthCounter = 0;
	for(i = 0; i < lengthOf(array); i++){
		if(array[i] == true){
			truthCounter++;
		}//end if array[i] is a truth
	}//end looping over array
	return truthCounter;
}//end countTruths(array)

/*
 * 
 */
function getAllFilesFromDirectories(filenames, directoryPath){
	// recursively gets all the files from all the subdirectories of specified path
	// get all the files in the specified directory, including subdirectories
	subFiles = getFileList(directoryPath);
	//print("subFiles before:"); Array.print(subFiles);
	// find number of files in subFiles
	filesInDir = 0;
	for(i = 0; i < lengthOf(subFiles); i++){
		// add full path back to name
		subFiles[i] = directoryPath + subFiles[i];
		if(File.isDirectory(subFiles[i]) == false){
			filesInDir++;
		}//end if we found a file
	}//end looping over sub files
	//print("subFiles after:"); Array.print(subFiles);
	// get list of new filenames
	justNewPaths = newArray(filesInDir);
	indexInNewPaths = 0;
	for(i = 0; i < lengthOf(subFiles); i++){
		if(File.isDirectory(subFiles[i]) == false){
			justNewPaths[indexInNewPaths] = subFiles[i];
			indexInNewPaths++;
		}//end if we found a file
	}//end looping over subFiles to get filenames
	// add new filenames to old array
	returnArray = Array.concat(filenames,justNewPaths);
	//print("returnArray before:"); Array.print(returnArray);
	// recursively search all subdirectories
	for(i = 0; i < lengthOf(subFiles); i++){
		if(File.isDirectory(subFiles[i])){
			tempArray = Array.copy(returnArray);
			newFiles = getAllFilesFromDirectories(filenames, subFiles[i]);
			//print("newFiles:"); Array.print(newFiles);
			returnArray = Array.concat(tempArray,newFiles);
			//print("returnArray after:"); Array.print(returnArray);
		}//end if we found a subDirectory
	}//end looping to get all the subDirectories
	return returnArray;
}//end getAllFilesFromDirectories(filenames, directoryPath)

/*
 * Generates an array with true or false depending on whether each
 * filename is valid. Validity is determined by not having any part
 * of the filename including a string in the forbiddenStrings array.
 * If allowDirectory is set to false, then names ending in the file
 * separator will be determined to be invalid. Otherwise, whether
 * a file is a directory or not will be ignored.
 */
function areFilenamesValid(filenames, forbiddenStrings, allowDirectory){
	// returns true false array on whether files are valid
	booleanArray = newArray(lengthOf(filenames));
	// loop to find out which are valid
	for(i = 0; i < lengthOf(filenames); i++){
		// check if filenames[i] is a directory
		if(allowDirectory == false && File.isDirectory(filenames[i])){
			booleanArray[i] = false;
		}//end if this is a subdirectory
		else{
			// loop to look for all the forbidden strings
			foundString = false;
			tempVar = filenames[i];
			fileExtension = substring(tempVar, lastIndexOf(tempVar, "."));
			if(!contains(expectedFileExtensions, fileExtension)){
				booleanArray[i] = false;
			}//end if wrong file extension
			else{
				filename = File.getName(filenames[i]);
				for(j = 0; j < lengthOf(forbiddenStrings); j++){
					if(indexOf(filename, forbiddenStrings[j]) > -1){
						foundString = true;
						j = lengthOf(forbiddenStrings);
					}//end if we found a forbidden string
				}//end looping over forbiddenStrings
				if(foundString){
					booleanArray[i] = false;
				}//end if we found a forbidden string
				else{
					booleanArray[i] = true;
				}//end else we have a valid file on our hands
			}//end else we need to look for forbidden strings
				
		}//end else it might be good
	}//end looping over each element of baseFileNames
	return booleanArray;
}//end areFilenamesValid(filenames, forbiddenStrings, allowDirectory)

function contains(array, val){
	foundVal = false;
	for(ijkm = 0; ijkm < lengthOf(array) && foundVal == false; ijkm++){
		if(array[ijkm] == val){
			foundVal = true;
		}//end if we found the value
	}//end looping over array
	return foundVal;
}//end contains

// close down the macro
waitForUser("End of Macro", "When this message box is closed, the macro will terminate");
run("Close All");
run("Clear Results");
if(isOpen("Results")){selectWindow("Results"); run("Close");}
if(isOpen("Log")){selectWindow("Log"); run("Close");}
if(shouldDisplayProgress){print(prgBarTitle,"\\Close");}
