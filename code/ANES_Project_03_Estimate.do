***** Title: ANES_Project_Estmimate
***** Author: Ulrick Mitton
***** Running regressions on voting and social media 
***** ANES Time Series Survey 2020 - 2024

		cd "~/Documents/Projects/ANES_Paper"
		log using "./logs/ANES_Project_03_Estimate.smcl", replace 
		use "./data/final_prepped.dta", clear

**********************************************
* Initial overview of dataset
**********************************************
		describe
		summarize
		tab fb_freq_cat year
		tab x_freq_cat year
		tab voted year

**********************************************
* Initial regresson: voter registration
**********************************************

		eststo clear

		eststo prereg: quietly logit pre_reg fb_use x_use i.year ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
			[pw = pre_weight], robust 
			
		eststo prereg_mfx: margins, dydx(fb_use x_use) post


**********************************************
* Regressions on voting and use
**********************************************

	* binary usage, no controls
		eststo vote_binary1: quietly logit voted fb_use x_use i.year ///
			[pw = post_weight], robust
		eststo vote_binary1_mfx: margins, dydx(fb_use x_use) post

	* binary usage + political controls
		eststo vote_binary2: quietly logit voted fb_use x_use i.year ///
			i.pol_attention i.party_id ///
			[pw = post_weight], robust
		eststo vote_binary2_mfx: margins, dydx(fb_use x_use) post

	* Binary usage + full controls
		eststo vote_binary3: quietly logit voted fb_use x_use i.year ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
			[pw = post_weight], robust
		eststo vote_binary3_mfx: margins, dydx(fb_use x_use) post


**********************************************
* Regressions on voting and frequency of use
**********************************************

	* collapsed frequency + political controls
		eststo vote_freq1: quietly logit voted i.fb_freq_cat i.x_freq_cat i.year ///
			i.pol_attention i.party_id ///
		[pw = post_weight], robust
		eststo vote_freq1_mfx: margins, dydx(i.fb_freq_cat i.x_freq_cat) post

	* testing joint significance
		quietly logit voted i.fb_freq_cat i.x_freq_cat i.year ///
			i.pol_attention i.party_id ///
			[pw = post_weight], robust
		testparm i.fb_freq_cat
		testparm i.x_freq_cat

	* collapsed frequency + full controls
		eststo vote_freq2: quietly logit voted i.fb_freq_cat i.x_freq_cat i.year ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
			[pw = post_weight], robust
		eststo vote_freq2_mfx: margins, dydx(i.fb_freq_cat i.x_freq_cat) post

	* testing joint significance
		quietly logit voted i.fb_freq_cat i.x_freq_cat i.year ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
			[pw = post_weight], robust
		testparm i.fb_freq_cat
		testparm i.x_freq_cat


**********************************************
* Year x Use Interactions
**********************************************

	* interaction with binary usage
		eststo vote_interact: quietly logit voted i.year##i.fb_use i.year##i.x_use ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
		[pw = post_weight], robust

	* testing joint significance
		testparm i.year#i.fb_use
		testparm i.year#i.x_use

	* marginal effects by year
		margins year, dydx(fb_use)
		eststo fb_by_year: margins year, dydx(fb_use) post

		quietly logit voted i.year##i.fb_use i.year##i.x_use ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
			[pw = post_weight], robust
    
		margins year, dydx(x_use)
		eststo x_by_year: margins year, dydx(x_use) post

	* getting predicted probabilities for visualization
		quietly logit voted i.year##i.fb_use i.year##i.x_use ///
			i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
		[pw = post_weight], robust

		margins year#fb_use
		marginsplot, ///
			title("Facebook Usage and Voting Probability by Year") ///
			ytitle("Predicted Probability of Voting") ///
			xlabel(2020 2024) ///
			legend(order(1 "Non-user" 2 "User"))
		graph export "./results/fb_interact.png", replace

		margins year#x_use
		marginsplot, ///
			title("X Usage and Voting Probability by Year") ///
			ytitle("Predicted Probability of Voting") ///
			xlabel(2020 2024) ///
			legend(order(1 "Non-user" 2 "User"))
		graph export "./results/x_interact.png", replace




**********************************************
* Year x Frequency Interactions
**********************************************

		eststo vote_freq_interact: quietly logit voted i.year##i.x_freq_cat ///
			i.fb_freq_cat i.pol_attention i.party_id ///
			i.educ i.state i.race age female ///
			[pw = post_weight], robust

	* testing interaction
		testparm i.year#i.x_freq_cat

	* marginal effects of X frequency by year
		margins year, dydx(i.x_freq_cat)

**********************************************
* Exporting Tables
**********************************************

	* Table 4: main results - binary usage
		esttab vote_binary1_mfx vote_binary2_mfx vote_binary3_mfx ///
			using "./results/tab4_main_binary.tex", replace ///
			star(* 0.10 ** 0.05 *** 0.01) ///
			b(3) se(3) ///
			stats(N, fmt(%9.0fc) labels("Observations")) ///
			title("Effect of Social Media Usage on Voting (Average Marginal Effects)") ///
			mtitles("Base" "Political" "Full") ///
			coeflabels(fb_use "Facebook User" x_use "X User") ///
			booktabs ///
			note("Standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. Base model includes year fixed effect. Political controls add political attention and party identification. Full controls add education, race, state fixed effects, age, and sex.")

	* Table 5: frequency results
	esttab vote_freq1_mfx vote_freq2_mfx ///
		using "./results/tab5_frequency.tex", replace ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		b(3) se(3) ///
		stats(N, fmt(%9.0fc) labels("Observations")) ///
		title("Social Media Usage Frequency and Voter Turnout") ///
		mtitles("Political Controls" "Full Controls") ///
		coeflabels(1.fb_freq_cat "Facebook: Infrequent" ///
				   2.fb_freq_cat "Facebook: Weekly" ///
				   3.fb_freq_cat "Facebook: Daily+" ///
				   1.x_freq_cat "X: Infrequent" ///
				   2.x_freq_cat "X: Weekly" ///
				   3.x_freq_cat "X: Daily+") ///
		booktabs ///
		addnotes("Average marginal effects from logit models." ///
             "Reference category: Non-users of each platform." ///
             "Infrequent = less than weekly; Weekly = 1-4 times/week; Daily+ = once or more per day." ///
             "\textit{Political Controls}: year FE, political attention, party identification." ///
             "\textit{Full Controls}: adds age, sex, education, race, and state fixed effects." ///
             "Standard errors in parentheses. * p\$<\$0.10, ** p\$<\$0.05, *** p\$<\$0.01")

capture log close