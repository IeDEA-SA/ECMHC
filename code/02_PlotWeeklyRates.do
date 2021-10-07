* Andreas Haas, v1.0, Oct 7, 2020
	* andreas.haas@ispm.unibe.ch; andreas.d.haas@gmail.com

*** PLOT WEEKLY CONTACT RATES  
		
	* Dataset with weekly hospital admission and outpatient consultation rates
		use "$data/weekly", clear
				
	* Loop over conditions & type of care 
		foreach d in any org su smi dep anx oth sh alc {	
			foreach s in opd hos any {
		
			* Title of y-axis 
				if "`s'" =="hos" local ytitle "Percentage admitted for condition"
				if "`s'" =="opd" local ytitle "Percentage consulting for condition"
				if "`s'" =="any" local ytitle "Percentage admitted or consulting for condition"
				
			* Title of plots  
				if "`d'" == "any" local condition "{bf:Any mental disorder}"
				if "`d'" == "org" local condition "{bf:Organic mental disorders}"
				if "`d'" == "su" local condition "{bf:Substance use disorders}"
				if "`d'" == "smi" local condition "{bf:Serious mental disorders}"
				if "`d'" == "dep" local condition "{bf:Depression}"
				if "`d'" == "anx" local condition "{bf:Anxiety disorders}"
				if "`d'" == "oth" local condition "{bf:Other mental disorders}"
				if "`d'" == "sh" local condition "{bf:Self-harm}"
				if "`d'" == "alc" local condition "{bf:Alcohol withdrawal syndrome}"
				
			* Turn on legend in plot in top right corner in combined plot 
				if "`d'" =="su" local legend ""
				else local legend "legend(off)" 
				
			* Plot weekly rates 
				twoway /// 
					line `s'_prc_`d' cweek if cyear ==2017, lcolor("$blue%50") lwidth(*1.5) || ///
					line `s'_prc_`d' cweek if cyear ==2018, lcolor("$green%50") lwidth(*1.5) || ///
					line `s'_prc_`d' cweek if cyear ==2019, lcolor("$purple%50") lwidth(*1.5) || ///
					line `s'_prc_`d' cweek if cyear ==2020, lcolor("$red") lwidth(*1.5)  xlab(1.29 "Jan" 5.71 "Feb" 9.86 "Mar" 14.28 "Apr" 18.57 "May" 23 "Jun" 27.29 "Jul" 31.71 "Aug" 36.14 "Sep" 40.42 "Oct" 44.71 "Nov" 49.28 "Dec", angle(45))  ///
					legend(label(1 "2017") label(2 "2018") label(3 "2019") label(4 "2020")) graphregion(color(white)) ///
					xline(13.57, lcolor("$red") lpattern(dash)) xline(18.42, lcolor(gs4) lpattern(dash)) xline(23, lcolor(gs10) lpattern(dash)) ///
					ytitle("`ytitle'") subtitle(`condition') name(`s'_`d'_rate, replace) xtitle("Month") ysize(4) xsize(4) `legend'  legend(position(0) nobox bplacement(neast)) legend(size(*1)) legend(symxsize(*.5)) ///
					legend(rowgap (*.5) colgap(*.5))  legend(region(lstyle(none))) 
							
			}				
		}
			
	* Combine plots 
			
		* Graph close 
			graph close _all 
	
		* Hospital admissions 
			graph combine hos_any_rate hos_org_rate hos_su_rate hos_smi_rate hos_dep_rate hos_anx_rate hos_oth_rate hos_sh_rate hos_alc_rate , ///
			col(3) xsize(10) ysize(13.3333) iscale(*.5) graphregion(color(white)) graphregion(margin(l=-1 r=-1 t=-1 b=-1)) name(hos_rate, replace) subtitle("Simulated data", color(red))
			graph export "$figures/HOS_rates.pdf", as(pdf) name(hos_rate) replace
			
		* Outpatient care consultations 
			graph combine opd_any_rate opd_org_rate opd_su_rate opd_smi_rate opd_dep_rate opd_anx_rate opd_oth_rate opd_sh_rate opd_alc_rate,  ///
			col(3) xsize(10) ysize(13.3333) iscale(*.5) graphregion(color(white)) graphregion(margin(l=-1 r=-1 t=-1 b=-1)) name(opd_rate, replace) subtitle("Simulated data", color(red))
			graph export "$figures/OPD_rates.pdf", as(pdf) name(opd_rate) replace
			
		* Any care 
			graph combine any_any_rate any_org_rate any_su_rate any_smi_rate any_dep_rate any_anx_rate any_oth_rate any_sh_rate any_alc_rate, /// 
			col(3) xsize(10) ysize(13.3333) iscale(*.5) graphregion(color(white)) graphregion(margin(l=-1 r=-1 t=-1 b=-1)) name(any_rate, replace) subtitle("Simulated data", color(red))
			graph export "$figures/ANY_rates.pdf", as(pdf) name(any_rate) replace
								
	