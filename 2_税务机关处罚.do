destring amount_in_num, replace

** 计算区县层面的 行政处罚金额
bysort province1 province2 province3 year: egen country_level_penalty = sum(amount_in_num) //相对值 人数、GDP、次数、行业内计算次数
order country_level_penalty year province1 province2 province3
sort country_level_penalty
 
bysort province1 province2 province3 year: egen mean_penalty = mean(amount_in_num)
order mean_penalty

bysort province1 province2 province3 year: egen sd_penalty = sd(amount_in_num)
order sd_penalty
recode sd_penalty (.=0)

bysort province1 province2 province3 year: gen devia_penalty = amount_in_num - mean_penalty 
order devia_penalty

duplicates drop province1 province2 province3 year, force

save "/Users/apple/Desktop/税收处罚与企业流动/temp/2_税务机关处罚"
