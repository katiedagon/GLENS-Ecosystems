#!/usr/bin/python
# -*- coding: utf-8 -*-
###########################################################################
# Copyright 2014 Christian Willmes  (email : c.willmes@uni-koeln.de)
#
# This software is licensed under The MIT License (MIT) 
# http://opensource.org/licenses/MIT
#
# If you use this software for a research project please cite the 
# following publication:
#
# Willmes, C., Becker, D., Brocks, S., Hütt, C., Bareth, G. (2014): pyGRASS implementation of Köppen-Geiger classifications from CMIP5 simulations. DOI: 10.5880/SFB806.1, SFB/CRC 806 Database.
#
############################################################################

import os
import sys

#pyGRASS Environment 
gisbase = os.environ['GISBASE'] = "/usr/lib/grass64" 		#adjust this path accordingly to your env.
 
gisdbase = os.path.join('/home/christian/dev', "grassdata") #adjust this path accordingly to your env.
location = "KoeppenGeiger"									#adjust this path accordingly to your env.	
mapset   = "LGM"			 								#adjust this path accordingly to your env.	
 
sys.path.append(os.path.join(os.environ['GISBASE'], "etc", "python"))
import grass.script as grass
import grass.script.setup as gsetup
 
gsetup.init(gisbase, gisdbase, location, mapset)
 
print grass.gisenv()


####################
#
# Define Variable
#
var = "tas"


#Define Month raster datasets
grass.mapcalc('jan = 0.0')
grass.mapcalc('feb = 0.0')
grass.mapcalc('mar = 0.0')
grass.mapcalc('apr = 0.0')
grass.mapcalc('may = 0.0')
grass.mapcalc('jun = 0.0')
grass.mapcalc('jul = 0.0')
grass.mapcalc('aug = 0.0')
grass.mapcalc('sep = 0.0')
grass.mapcalc('oct = 0.0')
grass.mapcalc('nov = 0.0')
grass.mapcalc('dec = 0.0')

it = 0 #iterator
allrast = 0 # all rasters conatining tas
years = 0
index = [None] * 1200  # Create list of 1200 (12x100) 'None's or 1800 (12x150)


search = var + "_"

grass.message('Raster maps:')
for raster in grass.list_strings(type = 'rast'):
    if search in raster:
    	print raster
    	split_name = raster.split(".")	
    	split2 = split_name[1].split("@")
    	print split2[0]
    	index[int(split2[0])-1] = raster

for rast in index:
	#print rast
	print index[allrast]

	if it == 0: grass.mapcalc('jan = jan + ' + index[allrast])
	elif it == 1: grass.mapcalc('feb = feb + ' + index[allrast])
	elif it == 2: grass.mapcalc('mar = mar + ' + index[allrast])
	elif it == 3: grass.mapcalc('apr = apr + ' + index[allrast])
	elif it == 4: grass.mapcalc('may = may + ' + index[allrast])
	elif it == 5: grass.mapcalc('jun = jun + ' + index[allrast])
	elif it == 6: grass.mapcalc('jul = jul + ' + index[allrast])
	elif it == 7: grass.mapcalc('aug = aug + ' + index[allrast])
	elif it == 8: grass.mapcalc('sep = sep + ' + index[allrast])
	elif it == 9: grass.mapcalc('oct = oct + ' + index[allrast])
	elif it == 10: grass.mapcalc('nov = nov + ' + index[allrast])
	elif it == 11: grass.mapcalc('dec = dec + ' + index[allrast])
	allrast = allrast + 1
	it = it + 1
	if it == 12: 
		it = 0
		years = years + 1
		print str(years)

print "dataset contains " + str(allrast) + " month."  
print "dataset contains " + str(years) + " years."

print "computing arithmetic mean"
month = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
mindex = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
i = 0
for m in month: 

	calc = var + mindex[i] + " = " + m + " / " + str(years)
	print calc
	grass.mapcalc(calc)
	i = i + 1

print "done."

