split zhifadiyu, parse(",") gen(province)
drop zhifadiyu

duplicates drop xzid, force

drop if province1 == "None" & province2 == "None" & province3 == "None"
drop if province2 == "None" & province3 == "None"

summarize

 save"/Users/apple/Desktop/税收处罚与企业流动/temp/1_税务机构处罚.dta"
