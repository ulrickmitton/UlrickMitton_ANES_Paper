***** Title: ANES_Project_Summarize
***** Author: Ulrick Mitton
***** Creating summary statistics tables
***** ANES Time Series Survey 2020 - 2024

	    cd "~/Documents/Projects/ANES_Paper"
	    log using "./logs/ANES_Project_02_Summarize.smcl", replace 
	    use "./data/final_prepped.dta", clear

************************************************
* Generating coded age variable for summary stats
************************************************

		egen age_group = cut(age), at(18, 24, 40, 56, 75, 81) label
		label define age_lbl ///
		0 "18–23 (Gen Z)" ///
		1 "24–39 (Millennials)" ///
		2 "40–55 (Gen X)" ///
		3 "56–74 (Boomers)" ///
		4 "75–80+ (Silent+)"
		label values age_group age_lbl
  
************************************************
* Tabulating summary statistics for coded variables
************************************************
  
	* tabulating variables
		tabulate voted, generate(v)
		tabulate pre_reg, generate(pre)
		tabulate post_reg, generate(post)
		tabulate party_id, generate(p)
		tabulate pol_attention, generate(pol)
		tabulate educ, generate(e) 
		tabulate race, generate(r) 
		tabulate female, generate(f)  
		tabulate fb_freq, generate(fb) 
		tabulate fb_freq_cat, generate(fbc) 
		tabulate fb_use, generate(fbu) 
		tabulate x_freq, generate(tw)
		tabulate x_freq_cat, generate(xfc) 
		tabulate x_use, generate(xu) 
		tabulate age_group, generate(a) 
		tabulate year, generate(y)
		
	* storing variables
		eststo sum_vote: estpost summarize v1-v2
		eststo sum_pre: estpost summarize pre1-pre2
		eststo sum_post: estpost summarize post1-post2
		eststo sum_pol: estpost summarize post1-post2
		eststo sum_party: estpost summarize p1-p7
		eststo sum_gender: estpost summarize f1-f2
		eststo sum_race: estpost summarize r1-r6 
		eststo sum_age: estpost summarize a1-a5
		eststo sum_educ: estpost summarize e1-e8
		eststo sum_fb: estpost summarize fb1-fb8 fbu1-fbu2
		eststo sum_fbc: estpost summarize fbc1-fbc4 fbu1-fbu2
		eststo sum_tw: estpost summarize tw1-tw8 xu1-xu2
		eststo sum_xfc: estpost summarize xfc1-xfc4 xu1-xu2
		eststo sum_pol: estpost summarize pol1-pol5

**********************************************
* TABLE 1: Demographics (Non-Political)
**********************************************

		eststo clear
		estpost summarize age female educ, detail
		esttab . using "./results/tab1_demographics.tex", replace ///
			cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))") ///
			title("Sample Demographics") ///
			label ///
			collabels("N" "Mean" "SD" "Min" "Max") ///
			noobs ///
			nomtitle ///
			booktabs ///
			varlabels(age "Age (years)" ///
					  female "Female" ///
					  educ "Education Level (1-8)") ///
			nonotes ///
			addnotes("Sample: 9,093 respondents from ANES 2020 and 2024 (2020: 5,518; 2024: 3,575)." ///
				 "Female is binary indicator (1=female, 0=male)." ///
				 "Education: 1=less than high school, 8=professional/doctoral degree." ///
				 "Mean education (4.81) corresponds to some college." ///
				 "Race/Ethnicity: 76.7\% White, 11.8\% Black, 6.2\% Hispanic, 3.5\% Asian, 1.9\% Other.")
 
***********************************************
* TABLE 2: Political Attitudes and Engagement
**********************************************

		eststo clear
		estpost summarize party_id dem_thermo rep_thermo aff_polar pol_attention, detail
		esttab . using "./results/tab2_political.tex", replace ///
			cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))") ///
			title("Political Attitudes and Engagement") ///
			label ///
			collabels("N" "Mean" "SD" "Min" "Max") ///
			noobs ///
			nomtitle ///
			booktabs ///
			varlabels(party_id "Party Identification (1-7)" ///
					  dem_thermo "Democratic Party Thermometer (0-100)" ///
					  rep_thermo "Republican Party Thermometer (0-100)" ///
					  aff_polar "Affective Polarization" ///
					  pol_attention "Political Attention (1-5)") ///
			nonotes ///
			addnotes("Sample: 9,093 respondents from ANES 2020 and 2024." ///
					 "Party ID: 1=Strong Democrat, 4=Independent, 7=Strong Republican." ///
					 "Mean party ID (3.84) indicates slight Democratic lean in sample." ///
					 "Thermometers: 0=coldest feelings, 100=warmest feelings toward party." ///
					 "Affective polarization: absolute difference between party thermometers." ///
					 "Political attention: 1=always pay attention, 5=never. Mean (2.22) = most of the time.")
 
**********************************************
* TABLE 3: Social Media Usage
**********************************************

		eststo clear

		estpost summarize voted fb_use x_use fb_freq_cat x_freq_cat, detail

		esttab . using "./results/tab3_socialmedia.tex", replace ///
			cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))") ///
			title("Political Participation and Social Media Usage") ///
			label ///
			collabels("N" "Mean" "SD" "Min" "Max") ///
			noobs ///
			nomtitle ///
			booktabs ///
			varlabels(voted "Voted in Presidential Election" ///
					  fb_use "Uses Facebook" ///
					  x_use "Uses X (Twitter)" ///
					  fb_freq_cat "Facebook Usage Frequency (0-3)" ///
					  x_freq_cat "X Usage Frequency (0-3)") ///
			refcat(voted "\textit{Outcome Variable}" ///
				   fb_use "\textit{Social Media Usage}", nolabel) ///
			nonotes ///
			addnotes("Sample: 9,093 respondents from ANES 2020 and 2024." ///
					 "Voted and platform usage (fb\_use, x\_use) are binary indicators." ///
					 "98.8\% of sample voted (N=8,985), compared to 66\% national turnout." ///
					 "75.1\% use Facebook; 30.8\% use X." ///
					 "Usage frequency categories: 0=not at all, 1=infrequent (less than weekly)," ///
					 "2=weekly (1-4 times/week), 3=daily or more (once+ per day)." ///
					 "Mean FB frequency (1.90) = between infrequent and weekly." ///
					 "Mean X frequency (0.58) = between non-user and infrequent.")
					 		
**********************************************
* FIGURE: Facebook usage - collapsed categories
**********************************************
		
		graph bar (percent), over(fb_freq_cat, label(labsize(small))) ///
			title("Facebook Usage Frequency", size(medium)) ///
			subtitle("ANES 2020-2024", size(small)) ///
			ytitle("Percent of Sample") ///
			ylabel(0(10)60) ///
			bar(1, color(navy)) ///
			blabel(total, format(%3.1f) position(outside)) ///
			note("Source: American National Election Studies 2020, 2024", size(vsmall))
			graph export "./figures/facebook_frequency.png", replace width(800) height(600)
			
**********************************************
* FIGURE: X usage - collapsed categories  
**********************************************

		graph bar (percent), over(x_freq_cat, label(labsize(small))) ///
			title("X (Twitter) Usage Frequency", size(medium)) ///
			subtitle("ANES 2020-2024", size(small)) ///
			ytitle("Percent of Sample") ///
			ylabel(0(10)70) ///
			bar(1, color(black)) ///
			blabel(total, format(%3.1f) position(outside)) ///
			note("Source: American National Election Studies 2020, 2024", size(vsmall))
			graph export "./figures/x_frequency.png", replace width(800) height(600)
			
**********************************************
* FIGURE: Pol Attention/Interest usage - collapsed categories  
**********************************************

		graph bar (percent), over(pol_attention, label(labsize(vsmall))) /// pol attention
			title("Political Attention/Interest", size(medium)) ///
			subtitle("ANES 2020-2024", size(small)) ///
			ylabel(0(10)50) ///
			bar(1, color(forest_green)) ///
			blabel(total, format(%3.1f) position(outside) size(small)) ///
			note("Source: American National Election Studies 2020, 2024")
			graph export "./figures/political_attention.png", replace width(800) height(600)

 capture log close 