***** Title: ANES_Project_Execute
***** Author: Ulrick Mitton
***** Runs all project files in order
***** ANES Time Series Survey 2020 - 2024

*************************************************
* Setup
*************************************************
	cd "~/Documents/Projects/ANES_Paper"

*************************************************
* Run
*************************************************
	do ".\code\ANES_Project_01_Prep"
	clear all
	do ".\code\ANES_Project_02_Summarize"
	clear all
	do ".\code\ANES_Project_03_Estimate"