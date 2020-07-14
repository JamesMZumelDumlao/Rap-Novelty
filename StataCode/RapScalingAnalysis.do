*************************************************************
* Spatial Scaling Analysis (Master's Thesis)
* - James M. Zumel Dumlao
*
*
* This do file will create graphics and tables for city Rap scaling analysis
*	
*************************************************************

*************************************************************

	global home		`"C:\Users\zumel\RapUrbAggPaper\LyricsCorpus\FULL CORPUS\LocalAnalysisFiles\MSAData"'

	clear matrix
	clear
	set more off
	
	
**********************************************
*** Code for Merge ***
// use "$home\GeoAnalysisDataset2018.dta", clear
// merge m:m msaid using "$home\MSAPop.dta"
//
// replace black = "." if black == "N"
// destring black, replace


use "$home\GeoPopAnalysis2018.dta", clear
//
// *** Want to compare ln(novelty) and ln(population) ***
//
// bysort msaid: egen AvgNovelty = mean(novelty)
// bysort msaid: egen MaxNovelty = max(novelty)
//
// gen lnAvgNovelty = ln(AvgNovelty)
// gen lnMaxNovelty = ln(MaxNovelty)
// gen lnPop = ln(totalpopulation)
//
// twoway (scatter lnAvgNovelty lnPop) (lfit lnAvgNovelty lnPop)
// graph save "$home\AvgNoveltyScaling2018.gph", replace
//
// twoway (scatter lnMaxNovelty lnPop) (lfit lnMaxNovelty lnPop), title("Innovation Capacity Scaling" "") ytitle("ln(Max Novelty)") xtitle("ln(Total Population)") legend(off)
// graph save "$home\MaxNoveltyScaling2018.gph", replace
//
//
// *** Now using only Black population ***
// gen lnBlack = ln(black)
//
// twoway (scatter lnAvgNovelty lnBlack) (lfit lnAvgNovelty lnBlack)
// graph save "$home\AvgNoveltyScalingBlack2018.gph", replace
//
// twoway (scatter lnMaxNovelty lnBlack) (lfit lnMaxNovelty lnBlack), title("Innovation Capacity Scaling" "Black/African-American Population") ytitle("ln(Max Novelty)") xtitle("ln(Black Population)") legend(off)
// graph save "$home\MaxNoveltyScalingBlack2018.gph", replace
//
//
// graph combine "$home\MaxNoveltyScaling2018.gph" "$home\MaxNoveltyScalingBlack2018.gph"
// graph export "C:\Users\zumel\RapUrbAggPaper\LyricsCorpus\FULL CORPUS\LocalAnalysisFiles\Figures\ScalingFigure2018.png", as(png) replace


*** Alternative Method, collapse by MSA and Artist, find artist average and then average my MSA" NOTE: This is what we use in the paper ***
use "$home\GeoPopAnalysis2018.dta", clear


collapse (mean) novelty resonance totalpopulation black, by(msaid artist_name)
drop if novelty == .
drop if msaid == .
collapse (max) novelty resonance totalpopulation black, by(msaid) // Capturing Max Novelty and Resonance from each MSA by artist averages

gen lnNovelty = ln(novelty)
gen lnTotalPop = ln(totalpopulation) 
gen lnBlackPop = ln(black)

twoway (scatter lnNovelty lnTotalPop) (lfit lnNovelty lnTotalPop), title("Maximum Novelty Scaling" " ") ytitle("ln(Max Novelty)") xtitle("ln(Total Population)") legend(off)
graph save "$home\altMaxNoveltyScaling2018.gph", replace

twoway (scatter lnNovelty lnBlack) (lfit lnNovelty lnBlack), title("Maximum Novelty Scaling" "Black/African-American Population") ytitle("ln(Max Novelty)") xtitle("ln(Black Population)") legend(off)
graph save "$home\altMaxNoveltyScalingBlack2018.gph", replace

graph combine "$home\altMaxNoveltyScaling2018.gph" "$home\altMaxNoveltyScalingBlack2018.gph", xcommon
graph export "C:\Users\zumel\RapUrbAggPaper\LyricsCorpus\FULL CORPUS\LocalAnalysisFiles\Figures\altScalingFigure2018.png", as(png) replace

*** log pop to regular novelty and resonance 
twoway (scatter novelty lnTotalPop) (lfit novelty lnTotalPop)
graph save "$home\LevelScaling1.gph", replace

twoway (scatter novelty lnBlack) (lfit novelty lnBlack)
graph save "$home\LevelScaling2.gph", replace

twoway (scatter resonance lnTotalPop) (lfit resonance lnTotalPop), title("Maximum Resonance Scaling" " ") ytitle("Max Resonance") xtitle("ln(Total Population)") legend(off)
graph save "$home\LevelScaling3.gph", replace

twoway (scatter resonance lnBlack) (lfit resonance lnBlack), title("Maximum Resonance Scaling" "Black/African-American Population") ytitle("Max Resonance") xtitle("ln(Black Population)") legend(off)
graph save "$home\LevelScaling4.gph", replace

graph combine "$home\LevelScaling3.gph" "$home\LevelScaling4.gph", xcommon ycommon
graph export "C:\Users\zumel\RapUrbAggPaper\LyricsCorpus\FULL CORPUS\LocalAnalysisFiles\Figures\ResonanceLevelScaling2018.png", as(png) replace

*** Scaling Regressions ***

reg lnNovelty lnTotalPop, vce(cluster msaid)
outreg2 using "$home\NoveltyScalingReg.xls", replace ctitle(ln(Max Novelty))
reg lnNovelty lnBlackPop, vce(cluster msaid)
outreg2 using "$home\NoveltyScalingReg.xls", append ctitle(ln(Max Novelty))
reg lnNovelty lnTotalPop lnBlackPop, vce(cluster msaid)

reg resonance lnTotalPop, vce(cluster msaid)
outreg2 using "$home\NoveltyScalingReg.xls", append ctitle(Max Resonance)
reg resonance lnBlack, vce(cluster msaid)
outreg2 using "$home\NoveltyScalingReg.xls", append ctitle(Max Resonance)
reg resonance lnTotalPop lnBlack, vce(cluster msaid)

* PARTIALLING OUT *
reg lnTotalPop lnBlackPop, vce(cluster msaid)
predict TotPopResid, resid

reg lnNovelty TotPopResid, vce(cluster msaid)
outreg2 using "$home\NoveltyScalingReg.xls", append ctitle(ln(Max Novelty))

reg resonance TotPopResid, vce(cluster msaid)
outreg2 using "$home\NoveltyScalingReg.xls", append ctitle(Max Resonance)

*** Relationship of Population and Number of Artists ***
// MERGE //
use "$home\GeoAnalysisDataset.dta", clear
merge m:m msaid using "$home\MSAPop.dta" // NOTE: Population data is from 2018 estimates, rapper counts is from 1994-2019

replace black = "." if black == "N"
destring black, replace

encode artist_name, gen(artist_id)
collapse (count) artist_id (mean) totalpopulation black, by(msaid)

drop if artist_id == 0
gen lnArtistCount = ln(artist_id)
gen lnTotalPop = ln(totalpopulation)
gen lnBlackPop = ln(black)

twoway (scatter lnArtistCount lnTotalPop) (lfit lnArtistCount lnTotalPop), title("Rapper Population Scaling" " ") ytitle("ln(# of Rappers)") xtitle("ln(Total Population)") legend(off)
graph save "$home\Figures\ArtistCountScaling.gph", replace

twoway (scatter lnArtistCount lnBlackPop) (lfit lnArtistCount lnBlackPop), title("Rapper Population Scaling" "Black/African-American Population") ytitle("ln(# of Rappers)") xtitle("ln(Black Population)") legend(off)
graph save "$home\Figures\ArtistCountScalingBlack.gph", replace

graph combine "$home\ArtistCountScaling.gph" "$home\ArtistCountScalingBlack.gph", xcommon
graph export "$home\Figures\ArtistCountScalingFigure.png", as(png) replace

reg lnArtistCount lnTotalPop, vce(cluster msaid)
outreg2 using "$home\Figures\RapperScalingReg.xls", replace ctitle(ln(# of Rappers))
reg lnArtistCount lnBlackPop, vce(cluster msaid)
outreg2 using "$home\Figures\RapperScalingReg.xls", append ctitle(ln(# of Rappers))
reg lnArtistCount lnTotalPop lnBlackPop, vce(cluster msaid)
outreg2 using "$home\Figures\RapperScalingReg.xls", append ctitle(ln(# of Rappers))

* PARTIALLING OUT *
reg lnBlackPop lnTotalPop, vce(cluster msaid)
predict BlackPopResid, resid

reg lnArtistCount BlackPopResid, vce(cluster msaid)
outreg2 using "$home\RapperScalingReg.xls", append ctitle(ln(# of Rappers))

*******************************************************

* Finding High Novelty and Resonance MSA's

*******************************************************

use "$home\GeoPopAnalysis2018.dta", clear

collapse (max) novelty resonance, by(origin)

gen negnov=-novelty
gen negres=-resonance

sort negnov
listtab origin novelty if _n <= 10 using ".\TopNovMSA.xls", delimiter(";") replace
sort negres
listtab origin resonance if _n <= 10 using ".\TopResMSA.xls", delimiter(";") replace
