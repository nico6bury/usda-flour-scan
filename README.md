# usda-flour-scan

Macro for flour scanning project for USDA-ARS

## Directory Requirements

Requires the macro file to be in directory ~/Fiji.app/macros/usda-flour-scan/.
This is required in order to locate sub macros due to current language limitations of the imagej macro language. Also, Fiji.app needs to be in the home directory of the current user.

## How to Run

In order to run this macro the conventional way, open ImageJ. Then, navigate in the menus Plugins > Macros > Edit. From here, you'll want to open NS-FlourScan-Main.ijm in order to run the main program, though you can also run the other macros by themselves if you just want to do one thing. Each helper-macro should have a comment at the top explaining what the macro does and how to arrange arguments to call the macro from another macro or program.
