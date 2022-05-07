begin
;************************************************
; read in data
;************************************************

 ; CLM output
 ctrl_path_lnd = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.control.EM1-20/lnd/proc/tseries/month_1/"
 fdbk_path_1_lnd = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20/lnd/proc/tseries/month_1/"
 fdbk_path_2_lnd = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20/lnd/proc/tseries/month_1/"

 var = "TSA"

 f_ctrl = addfile(str_concat((/ctrl_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.control.EM1-20.clm2.h0.",var,".201001-203012.nc"/)),"r")
 f_fdbk_1 = addfile(str_concat((/fdbk_path_1_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.clm2.h0.",var,".208001-208912.nc"/)),"r")
 f_fdbk_2 = addfile(str_concat((/fdbk_path_2_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.clm2.h0.",var,".209001-209912.nc"/)),"r")

 var_ctrl_full = f_ctrl->$var$
 var_ctrl = var_ctrl_full(:239,:,:) ; subset 2010-2029 (20 years of monthly averages)
 var_fdbk_1 = f_fdbk_1->$var$
 var_fdbk_2 = f_fdbk_2->$var$
 var_fdbk = array_append_record(var_fdbk_1, var_fdbk_2, 0) ; join 2080-2099 (20 years)

 ; CAM output
 ctrl_path_atm = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.control.EM1-20/atm/proc/tseries/month_1/"
 fdbk_path_1_atm = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20/atm/proc/tseries/month_1/"
 fdbk_path_2_atm = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20/atm/proc/tseries/month_1/"

 var_atm = "TS"

 f_ctrl_atm = addfile(str_concat((/ctrl_path_atm,"b.e15.B5505C5WCCML45BGCR.f09_g16.control.EM1-20.cam.h0.",var_atm,".201001-203012.nc"/)),"r")
 f_fdbk_1_atm = addfile(str_concat((/fdbk_path_1_atm,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.cam.h0.",var_atm,".208001-208912.nc"/)),"r")
 f_fdbk_2_atm = addfile(str_concat((/fdbk_path_2_atm,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.cam.h0.",var_atm,".209001-209912.nc"/)),"r")

 var_ctrl_atm_full = f_ctrl_atm->$var_atm$
 var_ctrl_atm = var_ctrl_atm_full(:239,:,:)
 ;printVarSummary(var_ctrl_atm)
 var_fdbk_1_atm = f_fdbk_1_atm->$var_atm$
 var_fdbk_2_atm = f_fdbk_2_atm->$var_atm$
 var_fdbk_atm = array_append_record(var_fdbk_1_atm, var_fdbk_2_atm, 0)

 ; TEMP flag - to switch btw ctrl/fdbk
 ;var_ctrl = var_fdbk
 ;var_ctrl_atm = var_fdbk_atm

 ; spatial gradient - pulled from equivalent CAM output 
 var_ctrl_grad_lon=var_ctrl_atm ; metadata
 var_ctrl_grad_lat=var_ctrl_atm
 gradsf(var_ctrl_atm,var_ctrl_grad_lon,var_ctrl_grad_lat) ; will not work for land-only data
 ;printMinMax(var_ctrl_grad_lon, True) 

 var_ctrl_grad_lon@long_name = "longitudinal gradient"
 var_ctrl_grad_lat@long_name = "latitudinal gradient"

 var_ctrl_grad_lon_km = var_ctrl_grad_lon
 var_ctrl_grad_lon_km = var_ctrl_grad_lon*1000 ; K/km
 var_ctrl_grad_lat_km = var_ctrl_grad_lat
 var_ctrl_grad_lat_km = var_ctrl_grad_lat*1000 ; K/km

 var_ctrl_grad_lon_km@units     = "K/km"
 var_ctrl_grad_lat_km@units     = "K/km"

 ; is it fair to take a time mean?
 var_ctrl_grad_lon_km_mean = dim_avg_n_Wrap(var_ctrl_grad_lon_km,0)
 ;printVarSummary(var_ctrl_grad_lon_km_mean)
 var_ctrl_grad_lat_km_mean = dim_avg_n_Wrap(var_ctrl_grad_lat_km,0)

 ; now for feedback
 var_fdbk_grad_lon=var_fdbk_atm ; metadata
 var_fdbk_grad_lat=var_fdbk_atm
 gradsf(var_fdbk_atm,var_fdbk_grad_lon,var_fdbk_grad_lat) ; will not work for land-only data
 var_fdbk_grad_lon@long_name = "longitudinal gradient"
 var_fdbk_grad_lat@long_name = "latitudinal gradient"
 var_fdbk_grad_lon_km = var_fdbk_grad_lon
 var_fdbk_grad_lon_km = var_fdbk_grad_lon*1000 ; K/km
 var_fdbk_grad_lat_km = var_fdbk_grad_lat
 var_fdbk_grad_lat_km = var_fdbk_grad_lat*1000 ; K/km
 var_fdbk_grad_lon_km@units     = "K/km"
 var_fdbk_grad_lat_km@units     = "K/km"

 ; slope by average maximum technique (Loarie et al. 2009)
 ; http://webhelp.esri.com/arcgisdesktop/9.2/index.cfm?TopicName=How%20Slope%20works
 ; http://jhpantel.com/science-aesthetics-blog/2015/08/calculating-the-spatial-gradient-for-georeferenced-trait-values/
 var_ctrl_grad = var_ctrl_grad_lon
 var_ctrl_grad@long_name = "spatial gradient"
 var_ctrl_grad = sqrt((var_ctrl_grad_lat_km)^2 + (var_ctrl_grad_lon_km)^2)
 ;printVarSummary(var_ctrl_grad)
 var_ctrl_grad_mean = dim_avg_n_Wrap(var_ctrl_grad,0) ; K/km
 var_ctrl_grad_mean@units = "K/km"
 ;printVarSummary(var_ctrl_grad_mean)

 var_fdbk_grad = var_fdbk_grad_lon                                                                                                           
 var_fdbk_grad@long_name = "spatial gradient"                                                                                                
 var_fdbk_grad = sqrt((var_fdbk_grad_lat_km)^2 + (var_fdbk_grad_lon_km)^2)                                                                   
 ;printVarSummary(var_fdbk_grad)                                                                                                              
 var_fdbk_grad_mean = dim_avg_n_Wrap(var_fdbk_grad,0) ; K/km                                                                                 
 var_fdbk_grad_mean@units = "K/km"                                                                                                           
 ;printVarSummary(var_fdbk_grad_mean)

 ; regression/trends
 ;time = TS&time
 time = ispan(1,240,1)
 ;printVarSummary(time)
 tmp = var_ctrl(lat|:,lon|:,time|:)               ; reorder variable
 tmp = tmp - 273 ; convert K->C
 rc = regCoef(time,tmp)
 ;rc@long_name = "regression coefficient (trend)"
 ;rc@units     = TS@units+"/month"
 ;printVarSummary(rc)
 copy_VarCoords(tmp(:,:,0),rc)
 ;printVarSummary(rc)
 ;rc_yr = rc
 ;rc_yr = rc*12 ; K/yr
 ;rc_yr@units = "K/yr"
 ;rc_d = rc
 ;rc_d = rc_yr*10 ; K/decade
 ;printVarSummary(rc_d)

 tmp = var_fdbk(lat|:,lon|:,time|:) 
 tmp = tmp - 273 ; convert K->C
 rc_fdbk = regCoef(time,tmp)
 copy_VarCoords(tmp(:,:,0),rc_fdbk)

 ; velocity
 ;cV_lon = T_grad_lon_km_mean ; metadata
 ;cV_lon = 12*(tofloat(rc)/T_grad_lon_km_mean) ; km/yr
 ;cV_lon@long_name = "longitudinal velocity"
 ;cV_lon@units = "km/yr"
 ;printVarSummary(cV_lon)
 ;cV_lat = T_grad_lat_km_mean
 ;cV_lat = 12*(tofloat(rc)/T_grad_lat_km_mean)
 ;cV_lat@long_name = "latitudinal velocity"
 ;cV_lat@units = "km/yr" 

 cV = var_ctrl_grad_mean ; metadata
 cV = 12*10*(tofloat(rc)/var_ctrl_grad_mean) ; km/decade
 cV@long_name = "velocity"
 cV@units = "km/decade"

 cV_fdbk = var_fdbk_grad_mean
 cV_fdbk = 12*10*(tofloat(rc_fdbk)/var_fdbk_grad_mean) ; km/decade
 cV_fdbk@long_name = "velocity"
 cV_fdbk@units = "km/decade"

 ;global means
 ;f_gw = addfile("../B_RCP6.f19_g16/run/B_RCP6.f19_g16.cam.h0.2000-01.nc4","r")
 ;gw = f_gw->gw

 ;rate1_gmean = wgt_areaave_Wrap(cV,gw,1.0,0)
 ;print(rate1_gmean)

 wks = gsn_open_wks("x11","test")
 ;wks = gsn_open_wks("pdf","control.TSA.cV")
 ;wks = gsn_open_wks("pdf","feedback.TSA.cV")
 ;wks = gsn_open_wks("pdf","ClimateVelocity_Fdbk_Ctrl")

 plot = new(2, graphic)

 res = True
 res@gsnDraw             = False            ; don't draw
 res@gsnFrame            = False            ; don't advance frame
 ;res@gsnMaximize = True
 res@cnFillOn = True
 res@cnLinesOn = False
 res@cnLineLabelsOn = False
 res@cnFillPalette = "BlWhRe"
 res@lbLabelBarOn        = False           ; turn off individual cb's  
 ;res@lbBoxLinesOn = False ; turn off lines in label bar

 ;symMinMaxPlt(cV_lon,40,False,res) 
 res@cnLevelSelectionMode =  "ManualLevels"
 res@cnMinLevelValF       = -100.
 res@cnMaxLevelValF       =  100.
 res@cnLevelSpacingF      =  5.
 ;plot = gsn_csm_contour_map(wks,cV_lon,res)
 ;symMinMaxPlt(cV_lat,40,False,res)
 ;plot = gsn_csm_contour_map(wks,cV_lat,res)

 res@gsnLeftString = "Control, 2010-2029"
 ;res@gsnLeftString = "Feedback, 2080-2099"
 res@gsnRightString = "Climate Velocity, km/decade"
 plot(0) = gsn_csm_contour_map(wks,cV,res)

 res@gsnLeftString = "Feedback, 2080-2099" 
 plot(1) = gsn_csm_contour_map(wks,cV_fdbk,res)  

 resP                  = True
 resP@gsnPanelLabelBar = True                   ; add common colorbar
 resP@lbBoxLinesOn         = False     ; Turn off labelbar box lines
 resP@gsnPanelYWhiteSpacePercent = 5 

 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

 ; Gradients plots
 ;wks = gsn_open_wks("x11","test")
 ;wks = gsn_open_wks("pdf","/glade/work/kdagon/GeoCAT/Gradients_NCL")
 ;wks = gsn_open_wks("pdf","/glade/work/kdagon/GeoCAT/gradsf_rasterfill")
 wks = gsn_open_wks("pdf","/glade/work/kdagon/GeoCAT/gradsf_areafill")
 ;res@gsnMaximize = True

 plot2 = new(3, graphic)

 res = True
 res@gsnDraw             = False            ; don't draw
 res@gsnFrame            = False            ; don't advance frame
 ;res@gsnMaximize = True
 res@cnFillOn = True
 ;res@cnFillMode           = "RasterFill" ; raster contours (no smoothing)
 res@cnFillMode           = "AreaFill" ; automatic smoothing of contours
 res@cnLinesOn = False
 res@cnLineLabelsOn = False
 res@cnFillPalette = "MPL_seismic"
 res@lbLabelBarOn        = False           ; turn off individual cb's  
 ;res@lbBoxLinesOn = False ; turn off lines in label bar

 res@cnLevelSelectionMode =  "ManualLevels"
 res@cnMinLevelValF       = -0.1
 res@cnMaxLevelValF       =  0.1
 res@cnLevelSpacingF      =  0.005

 res@gsnLeftString = ""
 res@gsnRightString = "Latitudinal Temperature Gradient, K/km"
 plot2(0) = gsn_csm_contour_map(wks,var_ctrl_grad_lat_km_mean,res)

 res@gsnRightString = "Longitudinal Temperature Gradient, K/km"
 plot2(1) = gsn_csm_contour_map(wks,var_ctrl_grad_lon_km_mean,res)

 res@gsnRightString = "Total Gradient (by average maximum technique), K/km"
 plot2(2) = gsn_csm_contour_map(wks,var_ctrl_grad_mean,res)

 resP                  = True
 resP@gsnPanelLabelBar = True                   ; add common colorbar
 resP@lbBoxLinesOn         = False     ; Turn off labelbar box lines
 resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelMainString = "Control Ensemble Mean, Annual Mean, 2010-2029"     ; set main title

 gsn_panel(wks,plot2,(/3,1/),resP)               ; now draw as one plot

 ; 4 panel plot
 ;plot = new(4,graphic)

 ; 50 years
 ;res@cnLevelSelectionMode =  "ManualLevels"
 ;res@cnMinLevelValF       = -10
 ;res@cnMaxLevelValF       =  10
 ;res@cnLevelSpacingF      =  1

 ;res@gsnStringFontHeightF = 0.02
 ;res@tmXBLabelFont         = 21
 ;res@tmYLLabelFont         = 21
 ;res@tmXBLabelFontHeightF = 0.016                 ; resize tick labels
 ;res@tmYLLabelFontHeightF = 0.016

 ;res@gsnLeftString = "~F21~a) 2000-2050, RCP6"
 ;res@gsnLeftString = "~F21~a) 2000-2015, Present Day"
 ;res@gsnRightString = "~F21~km decade~S~-1~N~"
 ;res@gsnRightString = "~F21~~S~o~N~C decade~S~-1~N~" 
 ;res@gsnLeftString = "~F21~a) 2000-2030, RCP6"
 ;plot(0) = gsn_csm_contour_map(wks,rate1,res)                                                         
 ;res@gsnLeftString = "~F21~b) 2050-2100, RCP6"
 ;res@gsnLeftString = "~F21~b) 2085-2100, RCP6"
 ;res@gsnLeftString = "~F21~b) 2070-2100, RCP6"
 ;plot(1) = gsn_csm_contour_map(wks,rate2,res)
 ;res@gsnLeftString = "~F21~c) 2050-2100, SG2050"
 ;res@gsnLeftString = "~F21~c) 2085-2100, SG2050"
 ;res@gsnLeftString = "~F21~c) 2070-2100, SG2050"
 ;plot(2) = gsn_csm_contour_map(wks,rate3,res)
 ;res@gsnLeftString = "~F21~d) 2050-2100, SG2000"
 ;res@gsnLeftString = "~F21~d) 2085-2100, SG2000"
 ;res@gsnLeftString = "~F21~d) 2070-2100, SG2000"
 ;plot(3) = gsn_csm_contour_map(wks,rate4,res)

 ;resP                  = True
 ;resP@gsnPanelLabelBar = True                   ; add common colorbar
 ;resP@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/) ; add strings to panel
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5
 ;resP@lbBoxLinesOn         = False     ; Turn off labelbar box lines
 ;resP@lbLabelFont = 21
 ;resP@lbLabelFontHeightF = 0.015

 ;gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

end

 
