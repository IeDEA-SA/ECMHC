* Andreas Haas, v1.0, Oct 7, 2020
	* andreas.haas@ispm.unibe.ch; andreas.d.haas@gmail.com
	
*** SIMULATE DATA
		
	* Setup 
		clear
		set obs 180

	* Week 
		gen week = 2963 + _n
		format week %tw
		
	* Analysis time (centered at end beginning of lockdown)
		gen time = 1 if week == 3133 // 2020w14 starting 30 March 2020 
		sort week
		replace time = time[_n-1] + 1 if time[_n-1] !=.
		gsort -week
		replace time = time[_n-1] - 1 if time==.
		sort week	
								
	* Lockdown 
		gen lockdown = 0 
		replace lockdown = 1 if time >0 & time !=.
		
	* Calendar year, month, and week 
		gen cyear =  year(dofw(week))
		gen cmonth = month(dofw(week))
		gen cweek = week(dofw(week))
								
	* Denominator 
		gen den = 4000000 + round(runiform(-10000, 10000))

	* Loop over conditions
		foreach d in any org su smi dep anx oth sh alc {
		
			* Number of health care contacts in week by type of care
			
				* Outpatient care 
					gen opd_`d' = 100 + round(runiform(-10, 10)) - lockdown * 25 // effect of lockdown
					replace opd_`d' = opd_`d' + time * 2 if lockdown ==1 // slope during lockdown
					replace opd_`d' = opd_`d' + _n * 0.2  // long-term time trend 					
										
				* Hospital admissions 
					gen hos_`d' = 10 + round(runiform(-1, 1)) - lockdown * 5 
					replace hos_`d' = hos_`d' + time * .5 if lockdown ==1 
					replace hos_`d' = hos_`d'  + _n * 0.02  // long-term time trend 	
						
				* Any care 
					gen any_`d' = opd_`d' + hos_`d'
					
			* Percentage of the population with health care contact in week 
				foreach s in opd hos any {
					gen `s'_prc_`d' = `s'_`d'/den*100 
					replace  `s'_`d' = round(`s'_`d')
				}	
		}
		
	* Save dataset with weekly hospital admission and outpatient consultation rates
		save "$data/weekly", replace
	
