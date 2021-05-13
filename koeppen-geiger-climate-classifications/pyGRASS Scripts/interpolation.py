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
mapset   = "LGM" 			 								#adjust this path accordingly to your env.
 
sys.path.append(os.path.join(os.environ['GISBASE'], "etc", "python"))
import grass.script as grass
import grass.script.setup as gsetup
 
gsetup.init(gisbase, gisdbase, location, mapset)
 
print grass.gisenv()

#define input data
precip = ["pr01", "pr02", "pr03", "pr04", "pr05", "pr06", "pr07", "pr08", "pr09", "pr10", "pr11", "pr12"]
temperature = ["tas01", "tas02", "tas03", "tas04", "tas05", "tas06", "tas07", "tas08", "tas09", "tas10", "tas11", "tas12"]

print "Interpolation starts"

for pr in precip:
	print pr
	prout = pr #+ "bilin"
	#print "Interpolate raster"
	grass.run_command('r.bilinear', input = pr, output = prout, overwrite = True)

for tas in temperature:
	print tas
	tasout = tas #+ "bilin"
	#print "Interpolate raster"
	grass.run_command('r.bilinear', input = tas, output = tasout, overwrite = True)

print "Interpolation done."
