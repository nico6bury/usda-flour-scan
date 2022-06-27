/*
 * Author: Nicholas Sixbury
 * File: NS-ResultsFormatter.ijm
 * Purpose: To post-process results tables 
 * in order to make things easier to display 
 * and/or export to excel.
 */

/// Basic Rundown of what to do
/// 1. Create a new table with all the columns we like
/// 2. Process the filenames of the samples to get Rep, Slice, Rot, Side columns
/// 3. Add processed filenames to the new table along with non-processed stuff
/// 4. At the same time, for each line in results table we get, get three lines
/// 	from Lab table, add those to right places

