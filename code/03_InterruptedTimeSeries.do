* Andreas Haas, v1.0, Oct 7, 2020
	* andreas.haas@ispm.unibe.ch; andreas.d.haas@gmail.com

*** INTERRUPTED TIME SERIES ANALYSIS 
				
	* Generate empty dataset to stored resutls  
		clear 
		gen var = ""
		save "$data/results", replace
		
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
					
			* Interrupted time series analysis 
				qui glm `s'_`d' c.time i.cmonth i.lockdown c.time#i.lockdown if !inlist(week, 3131, 3132), link(logit) family(binomial den) vce(robust) eform cformat(%8.7fc) 
				
			* Save, clean & append estimates to results dataset 
				preserve 
				qui regsave, ci  // save 
				qui keep if inlist(var, "`s'_`d':1.lockdown", "`s'_`d':1.lockdown#c.time") // clean 
				quietly gen c = "`d'"
				quietly gen condition = "`condition'"
				quietly  gen slope = var == "`s'_`d':1.lockdown#c.time"
				qui gen source = "`s'"
				foreach var in coef ci_lower ci_upper {
					quietly replace `var' = exp(`var')
					format `var' %3.2fc
					qui tostring `var', usedi gen(`var'_s) force
				}
				qui gen est = coef_s + " (" + ci_lower_s + "-" + ci_upper_s + ")" 
				sort slope 
				local step = est[1]
				local slope =est[2] 
				qui append using "$data/results"
				qui save "$data/results", replace 
				restore 
								
			* Predict odds, transform to proportions with CIs 
				qui predict logodds, xb
				qui predict logse, stdp  
				qui gen logcil = logodds-invnormal(0.975)*logse
				qui gen logciu = logodds+invnormal(0.975)*logse
				qui gen odds = exp(logodds)
				qui gen cil = exp(logcil)
				qui gen ciu = exp(logciu)
				qui gen prc = (odds/(1+odds))*100
				qui gen prc_l = (cil/(1+cil))*100
				qui gen prc_u = (ciu/(1+ciu))*100
						
			* Plot 
				twoway /// 
				rarea prc_l prc_u cweek if cyear ==2020 & cweek <=12, bcolor(gs14) lwidth(none) || ///
				line prc cweek if cyear ==2020 & cweek <=12, clcolor("$red") clwidth(medthick) || /// 
				rarea prc_l prc_u cweek if cyear ==2020 & cweek >=14, bcolor(gs14) lwidth(none) || ///
				line prc cweek if cyear ==2020 & cweek >=14, clcolor("$red") clwidth(medthick) || /// 				
				line `s'_prc_`d' cweek if cyear ==2020, lcolor(gs9) ///
				xline(18.42, lcolor(gs4) lpattern(dash))  ///
				xtitle("Month", size(*1.3)) ytitle("`ytitle'", size(*1.3)) graphregion(color(white)) legend(off) ///
				xline(12, lcolor(gs10) lpattern(dash)) xline(14, lcolor("$red") lpattern(dash)) ///
				xlab(1.29 "Jan" 5.71 "Feb" 9.86 "Mar" 14.28 "Apr" 18.57 "May" 23 "Jun", angle(45)  labsize(*1.3)) ysize(4) xsize(4) ///
				title(`condition') name(`s'_`d'_its, replace)  /// 
				subtitle("Lockdown: `step'" "Weekly change: `slope'", size(*1.18)) 
				
			* Clean 
				drop logodds logse logcil logciu odds cil ciu prc prc_l prc_u
				
			}				
		}
			
	* Combine plots 
			
		* Graph close 
			graph close _all 
	
		* Hospital admissions 
			graph combine hos_any_its hos_org_its hos_su_its hos_smi_its hos_dep_its hos_anx_its hos_oth_its hos_sh_its hos_alc_its, /// Hospital admissions 
			col(3) xsize(10) ysize(13.3333) iscale(*.5) graphregion(color(white)) graphregion(margin(l=-1 r=-1 t=-1 b=-1)) name(hos_its, replace) subtitle("Simulated data", color(red))
			graph export "$figures/HOS_ITS.pdf", as(pdf) name(hos_its) replace
			
		* Outpatient care consultations 
			graph combine opd_any_its opd_org_its opd_su_its opd_smi_its opd_dep_its opd_anx_its opd_oth_its opd_sh_its opd_alc_its, /// Outpatient care consultations 
			col(3) xsize(10) ysize(13.3333) iscale(*.5) graphregion(color(white)) graphregion(margin(l=-1 r=-1 t=-1 b=-1)) name(opd_its, replace) subtitle("Simulated data", color(red))
			graph export "$figures/OPD_ITS.pdf", as(pdf) name(opd_its) replace
				
		* Any care  
			graph combine any_any_its any_org_its any_su_its any_smi_its any_dep_its any_anx_its any_oth_its any_sh_its any_alc_its, /// Any care 
			col(3) xsize(10) ysize(13.3333) iscale(*.5) graphregion(color(white)) graphregion(margin(l=-1 r=-1 t=-1 b=-1)) name(any_its, replace) subtitle("Simulated data", color(red))
			graph export "$figures/ANY_ITS.pdf", as(pdf) name(any_its) replace

	* Table with estimates 
		
		* Clean results 
			use results, clear	
			replace condition = regexr(condition, "{bf:", "")
			replace condition = regexr(condition, "}", "")
			list condition est slope source, sepby(source)
		
		* Reshape 
			keep condition slope source est c
			gen id = . if c ==""
			local counter = 1 
			foreach j in any org su smi dep anx oth sh alc {
				replace id = `counter' if c =="`j'"
				local counter = `counter' + 1
			}
			gen s = 1 if source =="hos"
			replace s = 2 if source =="opd"
			replace s = 3 if source =="any"
			sort id s slope 
			drop c source 
			reshape wide est, i(id slope) j(s)
			order condition id slope
			format %-32s condition
			expand 2 if slope == 1, gen(temp)
			replace slope = -1 if temp==1
			forvalues j = 1/3 {
				replace est`j' = "" if temp ==1
			}
			drop temp
			sort id slope 
			replace condition = "" if est1 !=""
			replace condition = "   Lockdown" if slope ==0
			replace condition = "   Weekly change" if slope ==1		
			rename est1 hos
			rename est2 opd
			rename est3 any
			list condition hos opd any, sepa(`=_N')
		

		
	