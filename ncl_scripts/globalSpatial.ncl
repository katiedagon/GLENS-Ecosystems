; ***********************************************
; globalSpatial.ncl
; ***********************************************
;************************************************
begin
;************************************************
; read in data
;************************************************
 ctrl_path_lnd = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.control.EM1-20/lnd/proc/tseries/month_1/"
 fdbk_path_lnd = "/glade/collections/glens/B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20/lnd/proc/tseries/month_1/"

 ;var = "SOILWATER_10CM" ; toggle this to read different variables
 var = "GPP"
 ;var = "NPP"
 ;var = "TSA"
 ;var = "FSDSVI"
 ;var = "FSDSVD"
 ;var = "QVEGT"

 f_ctrl = addfile(str_concat((/ctrl_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.control.EM1-20.clm2.h0.",var,".201001-203012.nc"/)),"r")
 f_fdbk_1 = addfile(str_concat((/fdbk_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.clm2.h0.",var,".208001-208912.nc"/)),"r")
 f_fdbk_2 = addfile(str_concat((/fdbk_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.clm2.h0.",var,".209001-209912.nc"/)),"r")

 nyrs = 20 ; subset 2010-2029 for control, 2080-2099 for feedback

 var_ctrl_full = f_ctrl->$var$
 var_ctrl = var_ctrl_full(:(nyrs*12)-1,:,:) ; subset 2010-2029
 var_fdbk_1 = f_fdbk_1->$var$
 var_fdbk_2 = f_fdbk_2->$var$
 var_fdbk = array_append_record(var_fdbk_1, var_fdbk_2, 0) ; join 2080-2099 (20 years)

 ; optional second variable to compare/calculate
 ;var = "FSDS"
 var = "FSDSVI"

 f_ctrl = addfile(str_concat((/ctrl_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.control.EM1-20.clm2.h0.",var,".201001-203012.nc"/)),"r")
 f_fdbk_1 = addfile(str_concat((/fdbk_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.clm2.h0.",var,".208001-208912.nc"/)),"r")
 f_fdbk_2 = addfile(str_concat((/fdbk_path_lnd,"b.e15.B5505C5WCCML45BGCR.f09_g16.feedback.EM1-20.clm2.h0.",var,".209001-209912.nc"/)),"r")
 var_ctrl_full = f_ctrl->$var$
 var2_ctrl = var_ctrl_full(:(nyrs*12)-1,:,:) ; subset 2010-2029
 var_fdbk_1 = f_fdbk_1->$var$
 var_fdbk_2 = f_fdbk_2->$var$
 var2_fdbk = array_append_record(var_fdbk_1, var_fdbk_2, 0)

 ; diffuse fraction
 ;var_ctrl = var_ctrl/mask(var2_ctrl, var2_ctrl.eq.0, False)
 ;var_fdbk = var_fdbk/mask(var2_fdbk, var2_fdbk.eq.0, False)

 res = True
 ;res@gsnMaximize = True

 ; for panel plots 
 res@gsnDraw             = False            ; don't draw
 res@gsnFrame            = False            ; don't advance frame
 
 ; plot settings for global mean contour maps of differences
 res@cnFillOn = True
 res@cnLinesOn = False                                                                                
 res@cnLineLabelsOn = False                                                                           
 ;res@cnFillPalette = "BlWhRe"
 res@cnFillPalette = "MPL_BrBG"
 ;res@lbLabelBarOn      = False            ; turn off individual label bars
 res@lbBoxLinesOn = False ; turn off lines in label bar

 ; unit conversion (if applicable)
 u = 365*86400 ; gC/m2/s --> gC/m2/yr
 var_ctrl@units = "gC/m^2/yr"
 ;u = 86400 ; mm/s --> mm/day
 ;var_ctrl@units = "mm/day"
 ;u = 1

 var_diff = var_ctrl
 var_diff = u*(var_fdbk - var_ctrl)
 ;var_perdiff = var_ctrl
 ;var_perdiff = 100*(var_diff)/var_ctrl
 var_diff_mean = dim_avg_n_Wrap(var_diff,0)
 ;var_perdiff_mean = dim_avg_n_Wrap(var_perdiff,0)

 var2_diff = var2_ctrl
 var2_diff = var2_fdbk - var2_ctrl
 var2_diff_mean = dim_avg_n_Wrap(var2_diff,0) 
 var2_perdiff = var2_ctrl
 var2_ctrl_mask = var2_ctrl
 var2_ctrl_mask = mask(var2_ctrl, var2_ctrl.eq.0, False)
 var2_perdiff = 100*(var2_diff)/var2_ctrl_mask
 var2_perdiff_mean = dim_avg_n_Wrap(var2_perdiff,0)  
 var2_perdiff_mean@units = "%" 
                                                                                                                                                             
 ;wks = gsn_open_wks("x11","test")
 ;plot_title = str_concat((/"ANN_GLENS_BASE_",var,"_diff"/))
 ;plot_title = str_concat((/"ANN_GLENS_BASE_","diffusefraction","_diff"/))
 plot_title = "AnnualMean_Fdbk_Ctrl_GPP_FSDSVI"
 wks = gsn_open_wks("pdf",plot_title)

 plot = new(2,graphic)

 res@cnLevelSelectionMode="ManualLevels"

 ; SOILWATER_10CM diff
 ;res@cnMinLevelValF  = -2
 ;res@cnMaxLevelValF  = 2
 ;res@cnLevelSpacingF = 0.1

 ; GPP diff
 res@cnMinLevelValF  = -500
 res@cnMaxLevelValF  = 500
 res@cnLevelSpacingF = 25

 ; NPP diff
 ;res@cnMinLevelValF  = -300
 ;res@cnMaxLevelValF  = 300
 ;res@cnLevelSpacingF = 15

 ; FSDSVI diff
 ;res@cnMinLevelValF  = -20
 ;res@cnMaxLevelValF  = 20
 ;res@cnLevelSpacingF = 1
  
 ; diffuse fraction (FSDSVI/FSDS)
 ;res@cnMinLevelValF  = -0.1
 ;res@cnMaxLevelValF  = 0.1
 ;res@cnLevelSpacingF = 0.005

 ; QVEGT diff
 ;res@cnMinLevelValF  = -0.5
 ;res@cnMaxLevelValF  = 0.5
 ;res@cnLevelSpacingF = 0.025
                                                                                                                                                               
 ;res@gsnLeftString = "Diffuse Fraction"
 ;res@gsnRightString = ""
 ;res@tiMainString = "Annual Mean GLENS (2080-2099) - BASE (2010-2029)"
 res@tiMainString = "Annual Mean Feedback (2080-2099) - Control (2010-2029)"
 plot(0) = gsn_csm_contour_map(wks,var_diff_mean,res)
 ;plot = gsn_csm_contour_map(wks,var_perdiff_mean,res)

 ; FSDSVI diff                                                                                                                               
 ;res@cnMinLevelValF  = -20                                                                                                                  
 ;res@cnMaxLevelValF  = 20                                                                                                                   
 ;res@cnLevelSpacingF = 1

 ; FSDSVI perdiff                                                                                                                               
 res@cnMinLevelValF  = -80                                                                                                                  
 res@cnMaxLevelValF  = 80                                                                                                                   
 res@cnLevelSpacingF = 5

 res@tiMainString = ""
 plot(1) = gsn_csm_contour_map(wks,var2_perdiff_mean,res)

 resP                  = True
 ;resP@gsnPanelLabelBar = True                   ; add common colorbar
 ;resP@lbBoxLinesOn         = False     ; Turn off labelbar box lines
 ;resP@gsnFrame            = False      ; don't advance frame yet
 ;resP@gsnPanelBottom      = 0.5        ; move bottom up from 0.0 to 0.5
 ;resP@gsnPanelTop = 0.9
 ;resP@lbLabelFontHeightF = 0.013
 gsn_panel(wks,plot,(/2,1/),resP)

 ;resP@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/) ; add strings to panel
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5
 ;resP@lbLabelFont = 21
 ;resP@lbLabelFontHeightF = 0.015

 ;frame(wks) ; now advance frame
end

