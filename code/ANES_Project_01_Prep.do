***** Title: ANES_Project_Prep
***** Author: Ulrick Mitton
***** Preparing ANES data files
***** ANES Time Series Survey 2020 - 2024

		cd "~/Documents/Projects/ANES_Paper"
		log using "./logs/ANES_Project_01_Prep.smcl", replace 

************************************************
* Preparing 2020 data for append
************************************************
	
		use "./data/anes_timeseries_2020_stata_20220210.dta", clear
  
	*  dropping unecessary variables
	   keep V201025x V202051 V202072 V201156 V201157  V202542 V202543 V202544  ///
	   V202545 V201600 V201507x V201549x V201507x V203001 V201510 V201231x V201549x ///
	   V201005 V200010a V200010b
	   
	* renaming variables
	   rename V201025x pre_reg
	   rename V202051 post_reg
	   rename V202072 voted
	   rename V201231x party_id
	   rename V201156 dem_thermo
	   rename V201157 rep_thermo
	   rename V202542 fb_freq
	   rename V202543 fb_post
	   rename V202544 x_freq
	   rename V202545 x_post
	   rename V201005 pol_attention
	   rename V201600 female
	   rename V201507x age
	   encode V203001, generate(state)
	   rename V201510 educ
	   rename V201549x race
	   rename V200010a pre_weight
	   rename V200010b post_weight
	   
	* dropping missing/unknown/refused
		drop if pre_reg == -4 
		drop if post_reg == -9 | post_reg == -7 | post_reg == -6
		drop if voted == -9 | voted == -1
		drop if missing(dem_thermo) | dem_thermo == -9 | dem_thermo == 998
		drop if missing(rep_thermo) | rep_thermo == -9 | rep_thermo == 998
		drop if party_id == -8 | party_id == -9
		drop if pol_attention == -1 | pol_attention == -9
		drop if age < 0
		drop if inlist(educ, -1, -8, -9, 95)
		drop if inlist(race, -8, -9)
		drop if inlist(female, -4, -8, -9)
		drop if fb_freq < -1
		drop if fb_post < -1
		drop if x_freq < -1
		drop if x_post < -1
	 
	 * recoding binary variables
	   replace pre_reg = 0 if inlist(pre_reg, 1, 2)
	   replace pre_reg = 1 if inlist(pre_reg, 3, 4)
	   label define prereg_lbl ///
	   0 "No" ///
	   1 "Yes"
	   label values pre_reg prereg_lbl
	   
	   replace post_reg = 0 if post_reg == 3
	   replace post_reg = 1 if inlist(post_reg, -1, 1, 2)
	   label define postreg_lbl ///
	   0 "No" ///
	   1 "Yes"
	   label values post_reg postreg_lbl
	   
	   replace voted = 0 if voted == 2
	   label define voted_lbl ///
	   0 "No, didn't vote for President" ///
	   1 "Yes, voted for President"
	   label values voted voted_lbl
	   
	* generating year variable
	   generate year = 2020
	   save "./data/2020_prepped.dta", replace

************************************************
* Preparing 2024 data for append
************************************************
	
		use "./data/anes_timeseries_2024_stata_20250430", clear
   
	* dropping unecessary variables
	   keep V241012 V242051 V242066 V241227x V241166 V241167 V242578 V242579 V242580 V242581 ///
	   V241004 V241550 V243001 V241463 V241458x V241501x V240107a V240107b
	   
	* renaming variables
	   rename V241012 pre_reg
	   rename V242051 post_reg
	   rename V242066 voted
	   rename V241227x party_id
	   rename V241166 dem_thermo
	   rename V241167 rep_thermo
	   rename V242578 fb_freq
	   rename V242579 fb_post
	   rename V242580 x_freq
	   rename V242581 x_post
	   rename V241004 pol_attention
	   rename V241550 female
	   rename V241458x age
	   encode V243001, generate(state)
	   rename V241463 educ
	   rename V241501x race
	   rename V240107a pre_weight
	   rename V240107b post_weight
		
	* dropping missing/unknown/refused
		drop if inlist(pre_reg, -8, -1)
		drop if inlist(post_reg, -9, -7, -6)
		drop if inlist(voted, -9, -1)
		drop if missing(dem_thermo) | dem_thermo == -9 | dem_thermo == 998
		drop if missing(rep_thermo) | rep_thermo == -9 | rep_thermo == 998
		drop if inlist(party_id, -8, -9)
		drop if inlist(pol_attention, -1, -9)
		drop if age < 0
		drop if inlist(educ, -1, -8, -9, 95)
		drop if inlist(race, -8, -9)
		drop if inlist(female, -4, -8, -9)
		drop if fb_freq < -1
		drop if fb_post < -1
		drop if x_freq < -1
		drop if x_post < -1
		
	* recoding binary variables
	   replace pre_reg = 0 if pre_reg == 2
	   label define prereg_lbl ///
	   0 "No" ////
	   1 "Yes"
	   label values pre_reg prereg_lbl
	   
	   replace post_reg = 0 if post_reg == 2
	   replace post_reg = 1 if post_reg == -1
	   label define postreg_lbl ///
	   0 "No" ////
	   1 "Yes"
	   label values post_reg postreg_lbl
	   
	   replace voted = 0 if voted == 2
	   label define voted_lbl ///
	   0 "No, didn't vote for President" ////
	   1 "Yes, voted for President"
	   label values voted voted_lbl
	   
	* recoding education variable
	  replace educ = 1 if educ < 9
	  replace educ = 2 if educ == 9
	  replace educ = 3 if educ == 10
	  replace educ = 4 if educ == 11
	  replace educ = 5 if educ == 12
	  replace educ = 6 if educ == 13
	  replace educ = 7 if educ == 14
	  replace educ = 8 if educ > 14
	* generating year variable
	   generate year = 2024
	   save "./data/2024_prepped.dta", replace
	

************************************************
* Appending .dta files and recoding variables
************************************************

		use "./data/2020_prepped.dta", clear
		append using "./data/2024_prepped.dta"
  
	 * recoding use and post frequency variables
		recode fb_freq ///
			(-1=0 "Not at all") ///
			(7=1 "Less than once a month") ///
			(6=2 "Once or twice a month") ///
			(5=3 "About once a week") ///
			(4=4 "A few times each week") ///
			(3=5 "About once a day") ///
			(2=6 "A few times every day") ///
			(1=7 "Many times every day"), ///
			gen(fb_freq_new)
		   
		recode x_freq ///
			(-1=0 "Not at all") ///
			(7=1 "Less than once a month") ///
			(6=2 "Once or twice a month") ///
			(5=3 "About once a week") ///
			(4=4 "A few times each week") ///
			(3=5 "About once a day") ///
			(2=6 "A few times every day") ///
			(1=7 "Many times every day"), ///
			gen(x_freq_new)
			
		recode fb_post ///
			(-1=0 "Not a user") ///
			(5=1 "User, but never posts") ///
			(4=2 "Sometimes") ///
			(3=3 "About half of the time") ///
			(2=4 "Most of the time") ///
			(1=5 "Always"), ///
			gen(fb_post_new)
			
		recode x_post ///
			(-1=0 "Not a user") ///
			(5=1 "User, but never posts") ///
			(4=2 "Sometimes") ///
			(3=3 "About half of the time") ///
			(2=4 "Most of the time") ///
			(1=5 "Always"), ///
			gen(x_post_new)

		drop fb_freq x_freq fb_post x_post
		rename fb_freq_new fb_freq
		rename x_freq_new x_freq
		rename fb_post_new fb_post
		rename x_post_new x_post

	* adding labels
		label variable fb_freq "Facebook usage frequency (0=not at all, 7=many times daily)"
		label variable x_freq "X usage frequency (0=not at all, 7=many times daily)"
		label variable fb_post "Facebook political post frequency (0 = Never/Not a User, 7=Always)"
		label variable x_post "X political post frequency (0 = Never/Not a User, 7=Always)"
	

************************************************
* Creating collapsed frequency catergories 
************************************************
* creating collapsed frequency categories for cleaner analysis
* 0 = Not at all, 1 = Infrequent (less than weekly), 
* 2 = Weekly, 3 = Daily or more
************************************************

	* generating collapsed frequency variables
		gen fb_freq_cat = .
		replace fb_freq_cat = 0 if fb_freq == 0  // Not at all
		replace fb_freq_cat = 1 if inrange(fb_freq, 1, 2)  // Less than once a month, once or twice a month
		replace fb_freq_cat = 2 if inrange(fb_freq, 3, 4)  // About once a week, few times each week
		replace fb_freq_cat = 3 if inrange(fb_freq, 5, 7)  // About once a day or more
			
		gen fb_post_cat = .
		replace fb_post_cat = 0 if fb_post == 0 // Non-user
		replace fb_post_cat = 1 if fb_post == 1 // Never posts (but is user)
		replace fb_post_cat = 2 if inrange(fb_post, 2, 3) // Sometimes/about half
		replace fb_post_cat = 3 if inrange(fb_post, 4, 5) // Most of time/always
			
			
		gen x_freq_cat = .
		replace x_freq_cat = 0 if x_freq == 0 // Not at all
		replace x_freq_cat = 1 if inrange(x_freq, 1, 2) // Less than once a month, once or twice a month
		replace x_freq_cat = 2 if inrange(x_freq, 3, 4) // About once a week, few times each week
		replace x_freq_cat = 3 if inrange(x_freq, 5, 7) // About once a day or more
			
		gen x_post_cat = .
		replace x_post_cat = 0 if x_post == 0  // Non-user
		replace x_post_cat = 1 if x_post == 1  // Never posts (but is user)
		replace x_post_cat = 2 if inrange(x_post, 2, 3)  // Sometimes/about half
		replace x_post_cat = 3 if inrange(x_post, 4, 5)  // Most of time/always
			
	* labeling variables
		label define freq_cat_lbl ///
			0 "Not at all" ///
			1 "Infrequent (less than weekly)" ///
			2 "Weekly" ///
			3 "Daily or more"
				
		label define post_cat_lbl ///
			0 "Non-user/Never posts" ///
			1 "User, never posts political content" ///
			2 "Occasional political posting" ///
			3 "Frequent political posting"
				
		label values fb_freq_cat freq_cat_lbl
		label variable fb_freq_cat "Facebook usage (collapsed categories)"
		label values fb_post_cat post_cat_lbl
		label variable fb_post_cat "Political post frequency (collapsed categories)"
		
		label values x_freq_cat freq_cat_lbl
		label variable x_freq_cat "X usage (collapsed categories)"
		label values x_post_cat post_cat_lbl
		label variable x_post_cat "Political post frequency (collapsed categories)"

	* verification
		tab fb_freq fb_freq_cat, missing
		tab x_freq x_freq_cat, missing
		tab fb_freq_cat
		tab x_freq_cat
		bysort fb_freq_cat: summ fb_freq
		bysort x_freq_cat: summ x_freq
		
************************************************
* Creating and labeling binary variables
************************************************

		gen fb_use = (fb_freq > 0) if !missing(fb_freq)
		label variable fb_use "Uses Facebook (any frequency)"
		label define fbuse_lbl 0 "Not a Facebook user" 1 "Facebook User"
		label values fb_use fbuse_lbl

		gen x_use = (x_freq > 0) if !missing(x_freq)	
		label variable x_use "Uses X (any frequency)"
		label define xuse_lbl 0 "Not a X user" 1 "X user"
		label values x_use xuse_lbl

	* coding gender dummy
	   replace female = female - 1
	   label define fem_lbl ///
	   0 "Male" ///
	   1 "Female"
	   label values female fem_lbl
   
*************************************************
* Creating polarization variable
*************************************************
* measures absolute difference in feeling thermometers
* higher values = greater difference in party evaluations
*************************************************

	   gen aff_polar = . 
	   replace aff_polar = abs(dem_thermo - rep_thermo) if inlist(party_id, 1,2,3,4)  // Democrats and Independents
	   replace aff_polar = abs(rep_thermo - dem_thermo) if inlist(party_id, 5,6,7)  // Republicans
		   
*************************************************
* Saving dataset
*************************************************
		save "./data/final_prepped.dta", replace
		capture log close 



  
