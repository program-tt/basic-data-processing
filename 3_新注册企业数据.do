drop 数据整理 原始来源
drop if 年份 == .
duplicates drop 年份 行政区划代码 地区, force

bysort 地区 年份: egen total_number = sum(当年企业注册数目)
bysort 地区: egen mean_number=mean (total_number) // 行业 规模 类型？ 年龄


