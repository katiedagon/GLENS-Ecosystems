; ***********************************************
; globalClimatology.ncl
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
 
 ; global mean climatology
 var_ctrl_clim_gmean = wgt_areaave2(clmMonTLL(var_ctrl),arwt,0)
 var_fdbk_clim_gmean = wgt_areaave2(clmMonTLL(var_fdbk),arwt,0)

 ; unit conversion (if applicable)
 u = 365*86400 ; gC/m2/s --> gC/m2/yr
 var_ctrl_clim_gmean@units = "gC/m^2/yr"

 var_ctrl_clim_gmean_u = var_ctrl_clim_gmean
 var_ctrl_clim_gmean_u = var_ctrl_clim_gmean*u
 var_fdbk_clim_gmean_u = var_fdbk_clim_gmean
 var_fdbk_clim_gmean_u = var_fdbk_clim_gmean*u

 ; settings for seasonal cycle climatology line plots
 res = True
 res@gsnMaximize = True

 ;res@gsnDraw             = False            ; don't draw
 ;res@gsnFrame            = False            ; don't advance frame  

 res@xyDashPattern     = 0                         ; Make curves all solid
 res@xyLineThicknessF = 3.0
 res@xyLineColors      = (/"green","red"/)
 
 months = ispan(1,12,1)

 res@trXMinF = min(months)
 
 res@tmXBMode      = "Explicit" ; label independently
 res@tmXBValues    = months
 res@tmXBLabels    = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)

 res@tmXBLabelFont         = 21
 res@tmYLLabelFont         = 21

 res@pmLegendDisplayMode    = "Always"
 res@pmLegendSide           = "Top"
 res@pmLegendParallelPosF   = 0.25
 res@pmLegendOrthogonalPosF = -0.35 ; TS_clim_gmean
 ;res@pmLegendOrthogonalPosF = -0.2 ; PREC_clim_gmean
 res@pmLegendWidthF         = 0.1                ; Change width and
 res@pmLegendHeightF        = 0.13                ; height of legend.
 res@lgLabelFont = 21
 res@lgLabelFontHeightF     = 0.02                 ; label font height
 res@lgPerimOn              = False

 res@xyExplicitLegendLabels = (/"Base (2010-2029)", "Feedback (2080-2099)"/)

 ;plot = new(4,graphic)

 wks = gsn_open_wks("x11","test")
 ;wks = gsn_open_wks("eps","TS_clim_gmean")
 ;wks = gsn_open_wks("eps","globalSeasonal")

 data = new((/2,dimsizes(months)/),float)

 data(0,:) = (var_ctrl_clim_gmean_u)
 data(1,:) = (var_fdbk_clim_gmean_u)
 res@tiYAxisString = "Global Mean Climatology" 
 res@tiXAxisString = "Month"

 res@tiMainString = var+" ("+var_ctrl_clim_gmean_u@units+")"
 plot = gsn_csm_xy(wks,months,data,res)

 ;resP                  = True
 ;resP@gsnPanelYWhiteSpacePercent = 5
 ;resP@gsnPanelXWhiteSpacePercent = 5

 ;gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
end
