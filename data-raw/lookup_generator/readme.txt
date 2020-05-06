Note for any oceanobservatories/ooim2mr maintainer.

The Python scripts included in this folder are used to generate the lookup table utilized by this package.

make_ooi_master.py will create a master list of ALL (science, engineering, calibration) possible OOI request URLs based on site, node, instrument, method, and stream.

master_to_science.py will create a CSV of science stream urls based on site, node, instrument, and method. It will also add pipe-delimited cells of variables, units, display names, and variable descriptions.

To update the ooi_science.RData file, you will need to first run the make_ooi_master.py file to generate the master file.
Next, run master_to_science.py to create the science file.
Finally, run ooi_science.RData to save the file in a packageable format. 
Once this is complete, update the version number of the package.