/// DO FIRST

* Define global macros 
 	
	* Repository
		global repository "C:/Repositories/ECMHC"   
		
	* Subfolders 
		foreach folder in data code figures tables {  
			global `folder' "$repository/`folder'"
		}
			
* Generate folders 
		
	* Create folders   
		capture mkdir "$data" 		
		capture mkdir "$figures"
		capture mkdir "$tables"		
		capture mkdir "$code"		
			
* Working directory 
	cd "$data"

* Colors 
	global blue "0 155 196"
	global green "112 177 68"
	global purple "161 130 188"
	global red "185 23 70"
	
* Install packages 
	*ssc install regsave
		

		
