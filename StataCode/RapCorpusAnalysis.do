*************************************************************
* Corpus Level Analysis (Master's Thesis)
* - James M. Zumel Dumlao
* - 10 April 2020
*
* This do file will create graphics and tables for corpus level analysis
*	
*************************************************************

	global home		`"C:\Users\zumel\RapUrbAggPaper\LyricsCorpus\FULL CORPUS\LocalAnalysisFiles"'

	clear matrix
	clear
	set more off
	
	
**********************************************

use "$home\AnalysisDataset.dta", clear

***************************************************************

* Corpus-level Novelty vs. Transience and Novelty vs. Resonance

***************************************************************

twoway (lpolyci transience novelty), title("Novelty vs. Transience") ytitle("Transience") xtitle("Novelty") legend(off)
graph export "$home\Figures\CorpusNvT.png", replace

twoway (lpolyci resonance novelty), title("Novelty vs. Resonance") ytitle("Resonance") xtitle("Novelty") legend(off)
graph export "$home\Figures\CorpusNvR.png", replace



***************************************************************

* Corpus-level Average Novelty and Resonance Over Time

***************************************************************

bysort year: egen AvgNovelty = mean(novelty)
bysort year: egen AvgResonance = mean(resonance)


twoway (lpolyci AvgNovelty year, bwidth(2))
graph save "$home\AvgNoveltyTS.gph", replace
graph export "$home\Figures\AvgNoveltyTS.png", replace

twoway (lpolyci AvgResonance year, bwidth(2))
graph save "$home\AvgResonanceTS.gph", replace
graph export "$home\Figures\AvgResonanceTS.png", replace

***************************************************************

* Corpus-level Max Novelty and Resonance Over Time

***************************************************************

bysort year: egen MaxNovelty = max(novelty)
bysort year: egen MaxResonance = max(resonance)


twoway (lpolyci MaxNovelty year, bwidth(2)), title("Maximum Novelty Over Time") ytitle("Max Novelty") xtitle("Year") legend(off)
graph save "$home\MaxNoveltyTS.gph", replace
graph export "$home\Figures\MaxNoveltyTS.png", replace

twoway (lpolyci MaxResonance year, bwidth(2)), title("Maximum Resonance Over Time") ytitle("Max Resonance") xtitle("Year") legend(off)
graph save "$home\MaxResonanceTS.gph", replace
graph export "$home\Figures\MaxResonanceTS.png", replace

graph combine "$home\MaxNoveltyTS.gph" "$home\MaxResonanceTS.gph" 
graph export "$home\Figures\MaxNovResTS.png",replace
//
// graph combine "$home\AvgNoveltyTS.gph"  "$home\MaxNoveltyTS.gph", ycommon
// graph export "$home\Figures\AvgMaxNoveltyTS.png", replace
//
// graph combine "$home\AvgResonanceTS.gph" "$home\MaxResonanceTS.gph", ycommon
// graph export "$home\Figures\AvgMaxResonanceTS.png", replace

***************************************************************

* Region-level Average Novelty and Resonance Over Time

***************************************************************
gen region = 0
label var region "=1 if West, =2 if East, =3 if South, =4 if Midwest, =5 if MVD, =6 if PNW"

replace region = 1 if origin_state == "CA" |  origin_state == "AZ" |  origin_state == "CO" |  origin_state == "MT" |  origin_state == "NV" |  origin_state == "UT" |  origin_state == "WY" |  origin_state == "NM" |  origin_state == "HI" |  origin_state == "AK"
replace region = 2 if origin_state == "NY" |  origin_state == "CT" |  origin_state == "ME" |  origin_state == "MA" |  origin_state == "NH" |  origin_state == "RI" |  origin_state == "VT" |  origin_state == "DE" |  origin_state == "NJ" |  origin_state == "PA"
replace region = 3 if origin_state == "GA" |  origin_state == "AL" |  origin_state == "AR" |  origin_state == "FL" |  origin_state == "KY" |  origin_state == "LA" |  origin_state == "MS" |  origin_state == "MO" |  origin_state == "NC" |  origin_state == "SC" |  origin_state == "TN" |  origin_state == "WV" |  origin_state == "OK" |  origin_state == "TX"
replace region = 4 if origin_state == "IL" |  origin_state == "IN" |  origin_state == "IA" |  origin_state == "KS" |  origin_state == "MI" |  origin_state == "MN" |  origin_state == "NE" |  origin_state == "ND" |  origin_state == "OH" |  origin_state == "SD" |  origin_state == "WI"
replace region = 5 if origin_state == "MD" |  origin_state == "VA" |  origin_state == "DC"
replace region = 6 if origin_state == "ID" |  origin_state == "OR" |  origin_state == "WA"

label define regionlabel 1 "West" 2 "East" 3 "South" 4 "Midwest" 5 "MVD" 6 "PNW" 
label values region regionlabel

bysort region year: egen avgregionNovelty = mean(novelty)
bysort region year: egen avgregionTransience = mean(transience)
bysort region year: egen avgregionResonance = mean(resonance)

**********************************************

* Smooth Region Graphs

**********************************************

*** NOVELTY ***
twoway (lpolyci avgregionNovelty year if region == 1,  bwidth(2) clcolor(red)), legend(label(2 "West"))
graph save "$home\WestNovelty.gph", replace
graph export "$home\Figures\WestNovelty.png", replace

twoway (lpolyci avgregionNovelty year if region == 2,  bwidth(2) clcolor(blue)), legend(label(2 "East"))
graph save "$home\EastNovelty.gph", replace
graph export "$home\Figures\EastNovelty.png", replace

twoway (lpolyci avgregionNovelty year if region == 3,  bwidth(2) clcolor(orange)), legend(label(2 "South"))
graph save "$home\SouthNovelty.gph", replace
graph export "$home\Figures\SouthNovelty.png", replace

twoway (lpolyci avgregionNovelty year if region == 4,  bwidth(2) clcolor(brown)), legend(label(2 "Midwest"))
graph save "$home\MidwestNovelty.gph", replace
graph export "$home\Figures\MidwestNovelty.png", replace

twoway (lpolyci avgregionNovelty year if region == 5,  bwidth(2) clcolor(purple)), legend(label(2 "MVD"))
graph save "$home\MVDNovelty.gph", replace
graph export "$home\Figures\MVDNovelty.png", replace

twoway (lpolyci avgregionNovelty year if region == 6,  bwidth(2) clcolor(forest_green)), legend(label(2 "PNW"))
graph save "$home\PNWNovelty.gph", replace
graph export "$home\Figures\PNWNovelty.png", replace


graph combine "$home\EastNovelty.gph" "$home\WestNovelty.gph" "$home\SouthNovelty.gph" "$home\MidwestNovelty.gph" "$home\MVDNovelty.gph" "$home\PNWNovelty.gph", ycommon

graph export "$home\Figures\RegionNovelty.png", replace


*** RESONANCE ***
twoway (lpolyci avgregionResonance year if region == 1,  bwidth(2) clcolor(red)), legend(label(2 "West"))
graph save "$home\WestResonance.gph", replace
graph export "$home\Figures\WestResonance.png", replace

twoway (lpolyci avgregionResonance year if region == 2,  bwidth(2) clcolor(blue)), legend(label(2 "East") )
graph save "$home\EastResonance.gph", replace
graph export "$home\Figures\EastResonance.png", replace

twoway (lpolyci avgregionResonance year if region == 3,  bwidth(2) clcolor(orange)), legend(label(2 "South") )
graph save "$home\SouthResonance.gph", replace
graph export "$home\Figures\SouthResonance.png", replace

twoway (lpolyci avgregionResonance year if region == 4,  bwidth(2) clcolor(brown)), legend(label(2 "Midwest"))
graph save "$home\MidwestResonance.gph", replace
graph export "$home\Figures\MidwestResonance.png", replace

twoway (lpolyci avgregionResonance year if region == 5,  bwidth(2) clcolor(purple)), legend(label(2 "MVD"))
graph save "$home\MVDResonance.gph", replace
graph export "$home\Figures\MVDResonance.png", replace

twoway (lpolyci avgregionResonance year if region == 6,  bwidth(2) clcolor(forest_green)), legend(label(2 "PNW"))
graph save "$home\PNWResonance.gph", replace
graph export "$home\Figures\PNWResonance.png", replace


graph combine "$home\EastResonance.gph" "$home\WestResonance.gph" "$home\SouthResonance.gph" "$home\MidwestResonance.gph" "$home\MVDResonance.gph" "$home\PNWResonance.gph", ycommon

graph export "$home\Figures\RegionResonance.png", replace

*******************************************************

* Finding High Novelty and resonance States and Rappers

*******************************************************

*** TOP STATES ***

use "$home\AnalysisDataset.dta", clear

collapse (mean) novelty resonance, by(origin_state)
* Negative values help sort descending *
gen negnov=-novelty 
gen negres=-resonance

sort negnov
listtab origin_state novelty if _n <= 50 using ".\TopNovStates.xls", delimiter(";") replace
sort negres
listtab origin_state resonance if _n <= 50 using ".\TopResStates.xls", delimiter(";") replace


*** TOP RAPPERS ***
use "$home\AnalysisDataset.dta", clear

collapse (mean) novelty resonance, by(artist_name)
gen negnov=-novelty 
gen negres=-resonance

sort negnov
listtab artist_name novelty if _n <= 50 using ".\TopNovArtists.xls", delimiter(";") replace
sort negres
listtab artist_name resonance if _n <= 50 using ".\TopResArtists.xls", delimiter(";") replace

*** TOP RAPPERS AMONG 250 MOST PRODUCTIVE RAPPERS ***
use "$home\AnalysisDataset.dta", clear

bysort artist_name: egen quantity = count(origin_city)
gen negquant = -quantity

collapse (max) novelty resonance negquant, by(artist_name)
sort negquant
keep if _n <= 250
gen negnov=-novelty
gen negres=-resonance

sort negnov
listtab artist_name novelty if _n <= 50 using ".\TopNovTop250Artists.xls", delimiter(";") replace
sort negres
listtab artist_name resonance if _n <= 50 using ".\TopResTop250Artists.xls", delimiter(";") replace
