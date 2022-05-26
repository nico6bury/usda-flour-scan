//
//  DB-SG  May18  flour scan 08 b
//  May2022
//
//   simplified particle counts of smut?
//

run("Duplicate...", " ");

run("Sharpen");
run("Smooth");

run("8-bit");

th01 = 170;

run("Threshold...");
setThreshold(0, th01);
setOption("BlackBackground", false);
run("Convert to Mask");

szMin=2;
run("Analyze Particles...", "size=szMin-200 show=[Nothing] display clear summarize");

//  
//  


