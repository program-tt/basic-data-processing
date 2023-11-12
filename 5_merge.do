use "/Users/apple/Desktop/税收处罚与企业流动/temp/1_企业地址流动.dta"
rename newdistrict district_1
use "/Users/apple/Desktop/税收处罚与企业流动/temp/2_税务机关处罚.dta" 
rename province3 district_1
use "/Users/apple/Desktop/税收处罚与企业流动/temp/1_新注册企业.dta"
rename 地区 district_1
rename 年份 year

merge 1:m city_1 district_1 year using "/Users/apple/Desktop/税收处罚与企业流动/temp/1_企业地址流动.dta"
drop _merge

merge m:m district_1 year using "/Users/apple/Desktop/税收处罚与企业流动/temp/1_新注册企业.dta"

save "/Users/apple/Desktop/税收处罚与企业流动/temp/merge.dta"


