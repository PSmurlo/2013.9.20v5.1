Adding new Modules/Inverters/Locations to GUI:

1. in matlab, change the directory to where the matlab files are held

2. right click 'guiv5' and select open in GUIDE

3. double click the pulldown menu

4. go down to the 'String' variable and click the popup box to the left

5. At this time, open the appropriate .csv file for either:

	a. modules: 'sam-database-cec-modules.csv'

		copy the string found in the first column corresponding with the module to be added

		paste that string into the popup box on a new line
		
		The module databases unfortunately currently do not contain the number of bypass diodes 
		(usuially determined by (number of cells on top)/2) 
		OR the width and length of the module 
		(they do have area, so one can be determined by the other)

		These must both be entered manually.
		
		1. go to popupModule_Callback() in 'guiv5.m'
		
		2. add an elseif statement following the following template:

			elseif moduleIndex==	<--- row of the popup menu at which you entered the module string
    				moduleWidth = ; <--- width in meters of the short side of the module
    				ncellsx = ;     <--- number of cells on the short dimension of the module

		3. Ensure no errors and save the .m file
		

	b. inverters: 'sam-database-sandia-inverters.csv'

		copy the string found in the first column corresponding with the Inverter to be added

		paste that string into the popup box on a new line

	c. location: 'TMY3_StationsMeta.csv'

		Write a description of the location 
				OR 
		Copy the location found in column two
		
		put a '-' after this location description with no spaces on either side
		
		Copy the 'USAF' number found in the first column

		put this concatenated string into the popup box on a new line

		Not all Weather files may be present as they are a substantial file size, the weather files may individually be downloaded 

		and placed in the directory "...\F12_Clinic_ECE10_Inverter\Weather Data" MATLAB will automaticially recognize these files if

		placed here.

6. Save the '*.fig'

NOTE: After some time has gone by, Elements may be added to these files. They may need to be updated from their respective online sources. They can be found at the following locations:

Modules: https://sam.nrel.gov/sites/sam.nrel.gov/files/content/component_libraries/sam-database-cec-modules.csv

Inverters: https://sam.nrel.gov/sites/sam.nrel.gov/files/content/component_libraries/sam-database-sandia-inverters.csv

TMY3 Meta: http://rredc.nrel.gov/solar/old_data/nsrdb/1991-2005/tmy3/TMY3_StationsMeta.csv

TMY3 weather file lookup: http://rredc.nrel.gov/solar/old_data/nsrdb/1991-2005/tmy3/by_USAFN.html

Enjoy!