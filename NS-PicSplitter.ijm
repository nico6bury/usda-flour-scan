/*
 * Author: Nicholas Sixbury
 * File: NS-PicSplitter.ijm
 * Purpose: To automate the process of splitting up a bunch
 * of flour scan images, complete with re-labelling them.
 * Explanation of Parameter Passing: Each serialized parameter should be
 * separated by the \r character. For each parameter, it should be the name
 * followed by the value, separated by the ? character. When giving multiple
 * files or strings, separate them by the \f character. Parameters not given
 * will simply use the default.
 */
 
///////////// MAIN FUNCTION START ///////////////
//// Parameters for the macro
// List of files to be processed
filesToProcess = newArray(0);
// whether we should output files to a separate directory
outputToSeparateDirectory = false;
// the directory we should output the images to
outputDir = "";
// The possible methods of selecting files
fileSelectionMethods = newArray("Single File", "Multiple Files",
"Directory", "Multiple Directories");
// the chosen method of selecting files
fileSelectionMethod = fileSelectionMethods[2];
// a list of strings to ignore when directory selecting
forbiddenStrings = newArray("-Skip", "-Split", "-S");

argumentSerialized = getArgument();
if(lengthOf(argumentSerialized) == 0){
	// TODO: Figure out exactly what this macro will do
	// do dialog stuff to figure out parameters
	Dialog.createNonBlocking("Macro Options");
	Dialog.addChoice("File Selection Method", fileSelectionMethods, fileSelectionMethod);
	Dialog.addCheckbox("Output Split Images to Separate Directory", outputToSeparateDirectory);
	Dialog.addString("Forbidden Strings", String.join(forbiddenStrings), 15);
	Dialog.show();
	// get options back from the dialog
	fileSelectionMethod = Dialog.getChoice();
	outputToSeparateDirectory = Dialog.getCheckbox();
	forbiddenStrings = split(Dialog.getString(), ",");
	// get a separate directory if we need one
	if(outputToSeparateDirectory){
		outputDir = getDirectory("Please choose the output directory.");
	}//end if we need to get a separate output directory
	// get the files to process
	filesToProcess = getFilepaths(fileSelectionMethod);
}//end if we just process things normally
else{
	// TODO: Implement Argument parsing
	// parse out parameters from arguementSerialized
	linesToProcess = split(argumentSerialized, "\r");
	for(i = 0; i < lengthOf(linesToProcess); i++){
		thisLine = split(linesToProcess[i], "?");
		if(thisLine[0] == "filesToProcess"){
			filesToProcess = split(thisLine[1], "\f");
		}//end if this line contains files we should process
		else if(thisLine[0] == "outputToSeparateDirectory"){
			outputToSeparateDirectory = parseInt(thisLine[1]);
		}//end if this line tells us whether to output to separate directory
		else if(thisLine[0] == "outputDir"){
			outputDir = thisLine[1];
		}//end if this line tells us the output directory
		else if(thisLine[0] == "forbiddenStrings"){
			forbiddenStrings = split(thisLine[1], "\f");
		}//end if this line tells of forbidden strings
	}//end looping over lines to be deserialized
}//end else we have to figure out the arguments

// loop over all the files, processing each one appropriately
for(i = 0; i < lengthOf(filesToProcess); i++){
	// TODO: Split up each image
	// TODO: Export each image
}//end looping over each file we want to process

///////////// MAIN FUNCTION END /////////////////
///////////// EXTRA FUNCTION START //////////////

/*
 * Given a method of selecting files, prompts user to select files, 
 * and then returns an array of file paths
 */
function getFilepaths(fileSelectionMethod){
	// array to store file paths in
	filesToPrc = newArray(0);
	if(fileSelectionMethod == "Single File"){
		filesToPrc = newArray(1);
		filesToPrc[0] = File.openDialog("Please choose a file to process");
	}//end if we're just processing a single file
	else if(fileSelectionMethod == "Multiple Files"){
		numOfFiles = getNumber("How many files would you like to process?", 1);
		filesToPrc = newArray(numOfFiles);
		for(i = 0; i < numOfFiles; i++){
			filesToPrc[i] = File.openDialog("Please choose file " + (i+1) + 
			"/" + (numOfFiles) + ".");
		}//end looping to get all the files we need
	}//end if we're processing multiple single files
	else if(fileSelectionMethod == "Directory"){
		chosenDirectory = getDirectory("Please choose a directory to process\n"
		+"(Automatically processes subdirectories)");
		// gets all the filenames in the directory path
		filesToPrc = getValidFilePaths(chosenDirectory, forbiddenStrings);
	}//end if we're processing an entire directory
	else if(fileSelectionMethod == "Multiple Directories"){
		numOfDirs = getNumber("How many Directories would you like to select?\n"+
		"(Please note that all subdirectories will be automatically processed.)", 1);
		// get a list of the directories
		tempDirList = newArray(numOfDirs);
		for(i = 0; i < numOfDirs; i++){
			tempDirList[i] = getDirectory("Please choose directory "
			+ (i+1) + "/" + numOfDirs);
		}//end getting numOfDirs directories from the user
		// assemble list of all the files in each of those directories
		for(i = 0; i < lengthOf(tempDirList); i++){
			tempFileList = getValidFilePaths(tempDirList[i], forbiddenStrings);
			filesToPrc = Array.concat(filesToPrc,tempFileList);
		}//end looping over each directory to get
	}//end if we're processing multiple entire directories
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
			if(!contains(allowedFiletypes, fileExtension)){
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

/*
 * 
 */
function makeBackup(appendation){
	// make backup in temp folder
	// figure out the folder path
	backupFolderDir = getDirectory("temp") + "imageJMacroBackup" + 
	File.separator;
	File.makeDirectory(backupFolderDir);
	backupFolderDir += "HVAC" + File.separator;
	// make sure the directory exists
	File.makeDirectory(backupFolderDir);
	// make file path
	filePath = backupFolderDir + "backupImage-" + appendation + ".tif";
	// save the image as a temporary image
	save(filePath);
}//end makeBackup()

/*
 * 
 */
function openBackup(appendation, shouldClose){
	// closes active images and opens backup
	// figure out the folder path
	backupFolderDir = getDirectory("temp") + "imageJMacroBackup" + 
	File.separator + "HVAC" + File.separator;
	// make sure the directory exists
	File.makeDirectory(backupFolderDir);
	// make file path
	filePath = backupFolderDir + "backupImage-" + appendation + ".tif";
	// close whatever's open
	if(shouldClose == true) close("*");
	// open our backup
	open(filePath);
}//end openBackup


///////////// EXTRA FUNCTION END ////////////////