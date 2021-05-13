#!/usr/bin/python
# -*- coding: cp1252 -*-
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
import shapefile

sf = shapefile.Reader("/<somepath>/PreIndstClipped.shp")

records = sf.records()

#init classes array

classes = [0] * 32
gesammt = 0

for rec in records:
	classes[rec[1]] = classes[rec[1]] + rec[2]
	gesammt = gesammt + rec[2]

i = 0
for cl in classes:
	print str(i) + ": " + str(cl)
	i = i + 1

print "Gesammt: " + str(gesammt)
