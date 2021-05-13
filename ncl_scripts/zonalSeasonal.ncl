; ***********************************************
; zonalSeasonal.ncl
; ***********************************************
;load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
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

 ; calculate weights for global means
 ; get landfrac & area
 landf = f_ctrl->landfrac
 area = f_ctrl->area

 ; create wgt variable
 arwt = area
 arwt = area * landf
 arwt = arwt/max(arwt)
 ;printVarSummary(arwt)
 
 ; zonal mean seasonal means
 ;var_ctrl_DJF_zmean = dim_avg_n_Wrap(dim_avg_n_Wrap(month_to_season(var_ctrl, "DJF"),0),1)
 ;var_fdbk_DJF_zmean = dim_avg_n_Wrap(dim_avg_n_Wrap(month_to_season(var_fdbk, "DJF"),0),1)
 
 ; user-specified seasons
 var_ctrl_seasonal_zmeans = dim_avg_n_Wrap(dim_avg_n_Wrap(month_to_seasonN(var_ctrl, (/"DJF","MAM","JJA","SON"/)),1),2)
 ;printVarSummary(var_ctrl_seasonal_zmeans)
 var_fdbk_seasonal_zmeans = dim_avg_n_Wrap(dim_avg_n_Wrap(month_to_seasonN(var_fdbk, (/"DJF","MAM","JJA","SON"/)),1),2)
 ;printVarSummary(var_fdbk_seasonal_zmeans)

 ; unit conversion (if applicable)
 u = 365*86400 ; gC/m2/s --> gC/m2/yr
 ;var_ctrl_DJF_zmean@units = "gC/m^2/yr"

 ;var_ctrl_DJF_zmean_u = var_ctrl_DJF_zmean
 ;var_ctrl_DJF_zmean_u = var_ctrl_DJF_zmean*u
 ;var_fdbk_DJF_zmean_u = var_fdbk_DJF_zmean
 ;var_fdbk_DJF_zmean_u = var_fdbk_DJF_zmean*u

 ; diffs
 ;var_DJF_zmean_diff = var_ctrl_DJF_zmean
 ;var_DJF_zmean_diff = u*(var_fdbk_DJF_zmean-var_ctrl_DJF_zmean)
 var_zmean_diff = var_ctrl_seasonal_zmeans
 var_zmean_diff = u*(var_fdbk_seasonal_zmeans-var_ctrl_seasonal_zmeans)
 var_zmean_diff@units = "gC/m^2/yr"
 ;printVarSummary(var_zmean_diff)

 ; settings for seasonal cycle climatology line plots
 res = True
 res@gsnMaximize = True

 ;res@gsnDraw             = False            ; don't draw
 ;res@gsnFrame            = False            ; don't advance frame  

 res@xyDashPattern     = 0                         ; Make curves all solid
 res@xyMonoLineThickness = True
 res@xyLineThicknessF = 4.0
 res@xyLineColors      = (/"blue","green","red","orange"/)
 
 res@tmXBLabelFont         = 21
 res@tmYLLabelFont         = 21

 res@pmLegendDisplayMode    = "Always"
 res@pmLegendSide           = "Top"
 res@pmLegendParallelPosF   = 0.15
 res@pmLegendOrthogonalPosF = -0.35 ; TS_clim_gmean
 res@pmLegendWidthF         = 0.1                ; Change width and
 res@pmLegendHeightF        = 0.13                ; height of legend.
 res@lgLabelFont = 21
 res@lgLabelFontHeightF     = 0.02                 ; label font height
 res@lgPerimOn              = False

 ;res@xyExplicitLegendLabels = (/"Base (2010-2029)", "Feedback (2080-2099)"/)
 res@xyExplicitLegendLabels = var_zmean_diff&season

 ;plot = new(4,graphic)

 wks = gsn_open_wks("x11","test")
 ;wks = gsn_open_wks("eps","TS_clim_gmean")
 wks = gsn_open_wks("pdf","ZonalMean_Season_Fdbk_Ctrl_GPP")

 ;lats = var_ctrl_DJF_zmean&lat
 lats = var_zmean_diff&lat
 lats&lat = lats
 ;printVarSummary(lats)

 ;data = new((/2,dimsizes(lats)/),float)
 ;data(0,:) = var_ctrl_DJF_zmean_u
 ;data(1,:) = var_fdbk_DJF_zmean_u

 ;res@tiYAxisString = "Zonal Mean DJF Mean" 
 res@tiYAxisString = var+" ("+var_zmean_diff@units+")"
 res@tiXAxisString = "Latitude"

 ;res@tiMainString = var+" ("+var_ctrl_DJF_zmean_u@units+")"
 ;res@tiMainString = var+" ("+var_zmean_diff@units+")"
 res@tiMainString = "Zonal Mean Feedback (2080-2099) - Control (2010-2029)" 

 ;plot = gsn_csm_xy(wks,lats,data,res)
 ;plot = gsn_csm_xy(wks,lats,var_zmean_diff,res)
 plot = gsn_csm_xy(wks,lats({-60:60}),var_zmean_diff(:,{-60:60}),res)

 ;resP                  = True
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5

 ;gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
end
