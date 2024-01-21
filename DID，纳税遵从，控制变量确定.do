* -------------------------------------------------------------------
** 回归指标构建：被解释变量ETR,RATE_diff,LRATE_diff,BTD,DDBTD1
	       解释变量DID
	       控制变量ROE MB LEV REC INV FIXED size ADM Bdsize big4 First10 SOE
** 唐棠
** 时间：2024.1.21

**主要参考文献：
[1]叶康涛,刘行.公司避税活动与内部代理成本[J].金融研究,2014(09):158-176.
[2]汤晓建,张俊生,林斌.税收征管规范化降低了企业避税程度吗？−基于税务行政处罚裁量基准的准自然实验
[3] Desai,M.A.,and D.,Dharmapala.2006."Corporate Tax Avoidance and High-powered Incentives",
Journal of Financial Economics,79(1):145-179.

*----------------文件基本设置--------------------------------------
global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  对裁量权数据进行基本处理构建   ---------------------------------------
use "$root/政府_裁量权.dta"

rename city_county county_reg
rename city city_reg
destring disctetion_year, replace

gen length = strlen(city)
gsort length
replace city_county = udsubstr(city_county, 4, .) in 32/2301
replace city_county = udsubstr(city_county, 5, .) in 2302/2505
replace city_county = udsubstr(city_county, 6, .) in 2506/2598
replace city_county = udsubstr(city_county, 8, .) in 2599/2706
replace city_county = udsubstr(city_county, 9, .) in 2707/2729
replace city_county = udsubstr(city_county, 10, .) in 2730/2766
replace city_county = udsubstr(city_county, 11, .) in 2767/2835
replace city_county = udsubstr(city_county, 12, .) in 2836/2847
drop length
	//删除区县中含有市的部分

replace strvar = regexr(strvar, "\([^)]*\)", "")
	//删除区县中带有括号的部分

replace city_county = "中山市" in 108
replace city_county = "儋州市" in 885
replace city_county = "东莞市" in 1268
replace city_county = "嘉峪关市" in 2424
	//填补区县缺失值

duplicates report city county_reg
	//检查是否有重复

	
*--------------  裁量权与上市公司数据合并，构建解释变量DID   ---------------------------------------
merge 1:m county_reg city_reg using "/Users/apple/Desktop/行政裁量与企业/上市公司面板数据1391变量（1990-2022年）.dta"

gen treat =cond(missing(disctetion_year), 0, 1)
	//根据disctetion_year生成treat变量
gen post = 0
replace post = 1 if treat == 1 & year >= disctetion_year
	//生成post变量
gen DID= treat*post
	//生成DID变量
	
order post
order treat
order year
order DID
sort id year
tab post
tab treat
tab DID

*--------------  构建被解释变量纳税遵从指标（5个）   ---------------------------------------
***************** 法1:实际所得税率（ETR）及其变体 ****************************
---------- 实际所得税率（ETR）=企业税收支出/税前收入
gen ETR=B140101_33/B140204_33
  //实际所得税/税前总利润
sum ETR,d  

---------- 实际所得税率变体1:名义所得税率-实际所得税率(RATE_diff)
gen RATE_diff = F032801B-ETR
  //所得税率-ETR
sum RATE_diff,d

---------- 实际所得税率变体2:多期实际税率的平均值（例："名义所得税率与实际税率之差"的五年平均值(第t-4年至第t年)(LRATE_diff)）
forval i = 0/4 {
	bysort id_str: gen  RATE_diff_l`i' =  RATE_diff[_n-`i']
	}
  //生成差值变量
egen LRATE_diff = rowmean(RATE_diff_l0 RATE_diff_l1 RATE_diff_l2 RATE_diff_l3 RATE_diff_l4)
sum LRATE_diff,d


***************** 法2:账面-应税收入法（BTD）及其变体 ****************************
---------- BTD法：BTD=（税前会计利润-应纳税所得额）/期末总资产;应纳税所得额=（所得税费用-延递所得税费用）/名义所得税税率
lookfor "所得税"
gen 应纳税所得额=(B002100000 -A001222000)/F032801B 
  //（减：所得税费用-递延所得税资产）/所得税率

lookfor "税前利润"
gen BTD=(B140204_33-应纳税所得额)/A100000_33  
  //(税前总利润-应纳税所得额)/ 总资产-[专题-资本结构]
sum BTD,d

---------- DDBTD法：TACC=（净利润-经营活动现金净流量）/总资产
lookfor "净利润"
gen TACC=(B002000000-D610000_33)/A100000_33 
  //(净利润-经营活动产生的现金流量净额)/总资产
sum TACC,d

reg BTD TACC 
predict resid, residuals 
  // 基础回归模型，得到残差
bysort Stknme: egen mu_resid = mean(resid) 
  // 计算每个公司的残差均值
gen resid_diff = resid - mu_resid 
  // 计算残差与残差均值的偏离
gen DDBTD = mu_resid+resid_diff
sum DDBTD,d


*--------------  构建/寻找控制变量   ---------------------------------------
//净资产收益率（ROE），账面市价比（MB），资产负债率（LEV），应收账款占比（REC），存货占比（INV），
固定资产占比（FIXED），公司规模（size），管理费用占比（ADM），董事会规模（Bdsize），
是否“四大”审计（big4），前十大股东持股比例之和（First10），企业性质（SOE）

lookfor "净资产收益率" 
rename roe ROE

lookfor "市值"
rename F101001A MB

lookfor "资产负债率"
rename F011201A LEV

lookfor "应收账款"
lookfor "资产总额"
gen REC=A001111000 /A100000_32  

lookfor "存货"
gen INV=A001123000 /A100000_32  

lookfor "固定资产"
rename F030801A FIXED

lookfor "公司规模" //size

lookfor "管理费用"
rename F051801B ADM

lookfor "董事会规模"
rename BoardScale_57 Bdsize

lookfor "四大" //big4

lookfor "前十大股东"
rename TopTenHolders~e First10

lookfor "公司性质"
rename Ownership_101 SOE

order ROE MB LEV REC INV FIXED size ADM Bdsize big4 First10 SOE
order ETR RATE_diff LRATE_diff BTD DDBTD DID

*----------------输出一个统计性表格 excel-------------------------
export
save"$root/temp/merge1.dta"



