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
mapset   = "LGM"	 										#adjust this path accordingly to your env.
 
sys.path.append(os.path.join(os.environ['GISBASE'], "etc", "python"))
import grass.script as grass
import grass.script.setup as gsetup
 
gsetup.init(gisbase, gisdbase, location, mapset)
 
print grass.gisenv()
#grass.mapcalc('', overwrite = True)

#Mean Annual Precipitation
print "Mean Annual Precipitation"
grass.mapcalc('pr_ann = (pr01 + pr02 + pr03 + pr04 + pr05 + pr06 + pr07 + pr08 + pr09 + pr10 + pr11 + pr12) / 12', overwrite = True)
grass.mapcalc('pr_ann_mm = pr_ann * (86400 * 30)', overwrite = True)
grass.mapcalc('pr_ann_sum = pr01 + pr02 + pr03 + pr04 + pr05 + pr06 + pr07 + pr08 + pr09 + pr10 + pr11 + pr12', overwrite = True)
grass.mapcalc('pr_ann_sum_mm = pr_ann_sum * (86400 * 30)', overwrite = True)

#Driest Month Precipitation
print "Driest Month Precipitation"
grass.mapcalc('pr_dry = min(pr01, pr02, pr03, pr04, pr05, pr06, pr07, pr08, pr09, pr10, pr11, pr12)', overwrite = True)
grass.mapcalc('pr_dry_mm = pr_dry * (86400 * 30)', overwrite = True)

#Wettest Month Precipitation
print "Wettest Month Precipitation"
grass.mapcalc('pr_wet = max(pr01, pr02, pr03, pr04, pr05, pr06, pr07, pr08, pr09, pr10, pr11, pr12)', overwrite = True)
grass.mapcalc('pr_wet_mm = pr_wet * (86400 * 30)', overwrite = True)

#Mean Annual Temperature 
print "Mean Annual Temperature"
grass.mapcalc('tas_ann = (tas01 + tas02 + tas03 + tas04 + tas05 + tas06 + tas07 + tas08 + tas09 + tas10 + tas11 + tas12) / 12', overwrite = True)
grass.mapcalc('tas_ann_c = tas_ann - 273.15', overwrite = True)

#Coldest Month Temperature
print "Coldest Month Temperature"
grass.mapcalc('tas_cold = min(tas01, tas02, tas03, tas04, tas05, tas06, tas07, tas08, tas09, tas10, tas11, tas12)', overwrite = True)
grass.mapcalc('tas_cold_c = tas_cold - 273.15', overwrite = True)

#Hottest Month Temperature
print "Hottest Month Temperature"
grass.mapcalc('tas_hot = max(tas01, tas02, tas03, tas04, tas05, tas06, tas07, tas08, tas09, tas10, tas11, tas12)', overwrite = True)
grass.mapcalc('tas_hot_c = tas_hot - 273.15', overwrite = True)

#Calculate Summer/Winter (Summer (winter) is defined as the warmer (cooler) six month period of ONDJFM and AMJJAS.)
print "Calculate Summer/Winter"
grass.mapcalc('ONDJFM = tas10 + tas11 + tas12 + tas01 + tas02 + tas03', overwrite = True)
grass.mapcalc('AMJJAS = tas04 + tas05 + tas06 + tas07 + tas08 + tas09', overwrite = True)
grass.mapcalc('nsummer = if(ONDJFM <= AMJJAS, 1, 0)', overwrite = True)

#Calculate number of month where the temperature is above 10 C
print "Calculate number of month where the temperature is above 10 C"
grass.mapcalc('jan10 = if(tas01 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('feb10 = if(tas02 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('mar10 = if(tas03 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('apr10 = if(tas04 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('may10 = if(tas05 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('jun10 = if(tas06 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('jul10 = if(tas07 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('aug10 = if(tas08 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('sep10 = if(tas09 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('okt10 = if(tas10 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('nov10 = if(tas11 >= 283.15,1,0)', overwrite = True)
grass.mapcalc('dez10 = if(tas12 >= 283.15,1,0)', overwrite = True)

grass.mapcalc('tas_mon10 = jan10 + feb10 + mar10 + apr10 + may10 + jun10 + jul10 + aug10 + sep10 + okt10 + nov10 + dez10', overwrite = True)

#Calculate Precipitaion of the driest month in Summer
print "Calculate Precipitaion of the driest month in Summer"
grass.mapcalc('pr_sdry = if(nsummer,min(pr04, pr05, pr06, pr07, pr08, pr09),min(pr10, pr11, pr12, pr01, pr02, pr03))', overwrite = True)
grass.mapcalc('pr_sdry_mm = pr_sdry * (86400 * 30)', overwrite = True)

#Calculate Precipitation of the driest month in Winter
print "Calculate Precipitation of the driest month in Winter"
grass.mapcalc('pr_wdry = if(nsummer,min(pr10, pr11, pr12, pr01, pr02, pr03),min(pr04, pr05, pr06, pr07, pr08, pr09))', overwrite = True)
grass.mapcalc('pr_wdry_mm = pr_wdry * (86400 * 30)', overwrite = True)

#Calculate precipitation of the wettest month in Summer
print "Calculate precipitation of the wettest month in Summer"
grass.mapcalc('pr_swet = if(nsummer,max(pr04, pr05, pr06, pr07, pr08, pr09),max(pr10, pr11, pr12, pr01, pr02, pr03))', overwrite = True)
grass.mapcalc('pr_swet_mm = pr_swet * (86400 * 30)', overwrite = True)

#Calculate precipitation of wettest month in winter
print "Calculate precipitation of wettest month in winter"
grass.mapcalc('pr_wwet = if(nsummer,max(pr10, pr11, pr12, pr01, pr02, pr03),max(pr04, pr05, pr06, pr07, pr08, pr09))', overwrite = True)
grass.mapcalc('pr_wwet_mm = pr_wwet * (86400 * 30)', overwrite = True)

#Calculate if 70% of precipitation occurs in Winter
print "Calculate if 70% of precipitation occurs in Winter"
grass.mapcalc('pr_winter = if(nsummer,(pr10 + pr11 + pr12 + pr01 + pr02 + pr03),(pr04 + pr05 + pr06 + pr07 + pr08 + pr09))', overwrite = True)
grass.mapcalc('pr_winter_mm = pr_winter * (86400 * 30)', overwrite = True)
grass.mapcalc('pr_tr1 = if(pr_winter >= (pr_ann_sum * 0.7),(tas_ann_c * 2), 0)', overwrite = True)
grass.mapcalc('thresh1 = if(pr_winter >= (pr_ann_sum * 0.7),1,0)', overwrite = True)

grass.mapcalc('pr_summer = if(nsummer,(pr04 + pr05 + pr06 + pr07 + pr08 + pr09),(pr10 + pr11 + pr12 + pr01 + pr02 + pr03))', overwrite = True)
grass.mapcalc('pr_summer_mm = pr_summer * (86400 * 30)', overwrite = True)
grass.mapcalc('pr_tr2 = if(pr_summer > (pr_ann_sum * 0.7),(tas_ann_c * 2) + 28, 0)', overwrite = True)
grass.mapcalc('thresh2 = if(pr_summer > (pr_ann_sum * 0.7),1,0)', overwrite = True)
grass.mapcalc('pr_tr3 = if((pr_tr1 == 0) && (pr_tr2 == 0),(tas_ann_c * 2) + 14, 0)', overwrite = True)
grass.mapcalc('pr_threshold = pr_tr1 + pr_tr2 + pr_tr3', overwrite = True)

#
#Compute the Classes
#
print "Compute the Classes"

#A Climates
print "A Climates"
grass.mapcalc('A = if(tas_cold_c >= 18,1,0)', overwrite = True)
grass.mapcalc('Af = if(A == 1 && (tas_cold_c >= 18  &&  pr_dry_mm >= 60),7,0)', overwrite = True)
grass.mapcalc('Am = if(A == 1 && Af == 0 && pr_dry_mm >= 100 - (pr_ann_sum_mm / 25),8,0)', overwrite = True)
grass.mapcalc('Aw = if(A == 1 && Af == 0 && pr_dry_mm < 100 - (pr_ann_sum_mm / 25),10,0)', overwrite = True)

#B Climates
print "B Climates"
grass.mapcalc('B = if(pr_ann_sum_mm < 10 * pr_threshold,1,0)', overwrite = True)
grass.mapcalc('BW = if(B == 1 && pr_ann_sum_mm < 5 * pr_threshold,1,0)', overwrite = True)
grass.mapcalc('BS = if(B == 1 && pr_ann_sum_mm >= 5 * pr_threshold,1,0)', overwrite = True)
grass.mapcalc('BWh = if(BW == 1 && tas_ann_c >= 18,5,0)', overwrite = True)
grass.mapcalc('BWk = if(BW == 1 && tas_ann_c < 18,6,0)', overwrite = True)
grass.mapcalc('BSh = if(BS == 1 && BW == 0 && tas_ann_c >= 18,3,0)', overwrite = True)
grass.mapcalc('BSk = if(BS == 1 && BW == 0 && tas_ann_c < 18,4,0)', overwrite = True)

#C Climates
print "C Climates"
grass.mapcalc('C = if(A == 0 && B == 0 && tas_hot_c > 10 && tas_cold_c < 18 && tas_cold_c > 0,1,0)', overwrite = True)
grass.mapcalc('Cs = if(C == 1 && pr_sdry_mm < 40 && pr_sdry_mm < pr_wwet_mm/3,1,0)', overwrite = True)
grass.mapcalc('Cw = if(C == 1 && pr_wdry_mm < pr_swet_mm / 10,1,0)', overwrite = True)
grass.mapcalc('Cf = if(C == 1 && Cs == 0 && Cw == 0,1,0)', overwrite = True)

grass.mapcalc('Csreal = if(Cs == 1 && Cw == 1,if(pr_summer_mm < pr_winter_mm,1,0),Cs)', overwrite = True)
grass.mapcalc('Cwreal = if(Cs == 1 && Cw == 1,if(pr_summer_mm >= pr_winter_mm,1,0),Cw)', overwrite = True)
grass.mapcalc('Cw = Cwreal', overwrite = True)
grass.mapcalc('Cs = Csreal', overwrite = True)

grass.mapcalc('Csa = if(Cs == 1 && tas_hot_c >= 22,11,0)', overwrite = True)
grass.mapcalc('Csb = if(Cs == 1 && Csa == 0 && tas_mon10 >= 4,12,0)', overwrite = True)
grass.mapcalc('Csc = if(Cs == 1 && Csa == 0 && Csb == 0 && 1 <= tas_mon10 && tas_mon10 < 4,13,0)', overwrite = True)
grass.mapcalc('Cwa = if(Cw == 1 && Csa == 0 && Csb == 0 && Csc == 0 && tas_hot_c >= 22,14,0)', overwrite = True)
grass.mapcalc('Cwb = if(Cw == 1 && Csa == 0 && Csb == 0 && Csc == 0 && Cwa == 0 && tas_mon10 >= 4,15,0)', overwrite = True)
grass.mapcalc('Cwc = if(Cw == 1 && Csa == 0 && Csb == 0 && Csc == 0 && Cwa == 0 && Cwb == 0 && 1 <= tas_mon10 && tas_mon10 < 4,16,0)', overwrite = True)
grass.mapcalc('Cfa = if(Cf == 1 && Csa == 0 && Csb == 0 && Csc == 0 && Cwa == 0 && Cwb == 0 && tas_hot_c >= 22,17,0)', overwrite = True)
grass.mapcalc('Cfb = if(Cf == 1 && Cfa == 0 && Cwa == 0 && Csa == 0 && tas_mon10 >= 4,18,0)', overwrite = True)
grass.mapcalc('Cfc = if(Cf == 1 && Cfa == 0 && Cfb == 0 && Cwa == 0 && Cwb == 0 && 1 <= tas_mon10 && tas_mon10 < 4,19,0)', overwrite = True)

#D Climates
print "D Climates"
grass.mapcalc('D = if(tas_hot_c > 10 && tas_cold_c <= 0,1,0)', overwrite = True)
grass.mapcalc('Ds = if(D == 1 && pr_sdry_mm < 40 && pr_sdry_mm < pr_wwet_mm / 3,1,0)', overwrite = True)
grass.mapcalc('Dw = if(D == 1 && pr_wdry_mm < pr_swet_mm / 10,1,0)', overwrite = True)

grass.mapcalc('Dsreal = if(Ds == 1 && Dw == 1,if(pr_summer_mm < pr_winter_mm,1,0),Ds)', overwrite = True)
grass.mapcalc('Dwreal = if(Ds == 1 && Dw == 1,if(pr_summer_mm >= pr_winter_mm,1,0),Dw)', overwrite = True)
grass.mapcalc('Dw = Dwreal', overwrite = True)
grass.mapcalc('Ds = Dsreal', overwrite = True)

grass.mapcalc('Df = if(D == 1 && Ds == 0 && Dw == 0,1,0)', overwrite = True)
grass.mapcalc('Dsa = if(Ds == 1 && tas_hot_c >= 22,20,0)', overwrite = True)
grass.mapcalc('Dsb = if(Ds == 1 && Dsa == 0 && tas_mon10 >= 4,21,0)', overwrite = True)
grass.mapcalc('Dsd = if(Ds == 1 && Dsa == 0 && Dsb == 0 && tas_cold_c < -38,23,0)', overwrite = True)
grass.mapcalc('Dsc = if(Ds == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0,22,0)', overwrite = True)
grass.mapcalc('Dwa = if(Dw == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && tas_hot_c >= 22,24,0)', overwrite = True)
grass.mapcalc('Dwb = if(Dw == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && Dwa == 0 && tas_mon10 >= 4,25,0)', overwrite = True)
grass.mapcalc('Dwd = if(Dw == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && Dwa == 0 && Dwb == 0 && tas_cold_c < -38,27,0)', overwrite = True)
grass.mapcalc('Dwc = if(Dw == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && Dwa == 0 && Dwb == 0 && Dwd == 0,26,0)', overwrite = True)
grass.mapcalc('Dfa = if(Df == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && tas_hot_c >= 22,28,0)', overwrite = True)
grass.mapcalc('Dfb = if(Df == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && Dfa == 0 && tas_mon10 >= 4,29,0)', overwrite = True)
grass.mapcalc('Dfd = if(Df == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && Dfa == 0 && Dfb == 0 && tas_cold_c < -38,31,0)', overwrite = True)
grass.mapcalc('Dfc = if(Df == 1 && Dsa == 0 && Dsb == 0 && Dsd == 0 && Dfa == 0 && Dfb == 0 && Dfd == 0,30,0)', overwrite = True)

#E Climates
print "E Climates"
grass.mapcalc('E = if(tas_hot_c < 10,1,0)', overwrite = True)
grass.mapcalc('ET = if(E==1 && tas_hot_c > 0,1,0)', overwrite = True)
grass.mapcalc('EF = if(E==1 && tas_hot_c <= 0,2,0)', overwrite = True)

#Merging the classification rasters
print "Merging the classification rasters"
grass.mapcalc('Eclass = ET + EF', overwrite = True)
grass.mapcalc('Bclass = BSh + BSk + BWh + BWk', overwrite = True)
grass.mapcalc('Aclass = Af + Am + Aw', overwrite = True)
grass.mapcalc('Cclass = Csa + Csb + Csc + Cwa + Cwb + Cwc + Cfa + Cfb + Cfc', overwrite = True)
grass.mapcalc('Dclass = Dsa + Dsb + Dsd + Dsc + Dwa + Dwb + Dwd + Dwc + Dfa + Dfb + Dfd + Dfc', overwrite = True)

grass.mapcalc('EandB = if(Eclass == 0,Bclass,Eclass)', overwrite = True)
grass.mapcalc('EBandA = if(EandB == 0,Aclass,EandB)', overwrite = True)
grass.mapcalc('EBAandC = if(EBandA == 0,Cclass,EBandA)', overwrite = True)

grass.mapcalc('Classification = if(EBAandC == 0,Dclass,EBAandC)', overwrite = True)
#grass.mapcalc('Classification = if(Dclass != 0,Dclass,EBAandC)', overwrite = True)
