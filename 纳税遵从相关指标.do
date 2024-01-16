* -------------------------------------------------------------------
** 纳税遵从指标构建
** 唐棠
** 时间：2024.1.14

**修改一稿时间：2024.1.16
**主要参考文献：
[1]叶康涛,刘行.公司避税活动与内部代理成本[J].金融研究,2014(09):158-176.
[2]汤晓建,张俊生,林斌.税收征管规范化降低了企业避税程度吗？−基于税务行政处罚裁量基准的准自然实验
[3] Desai,M.A.,and D.,Dharmapala.2006."Corporate Tax Avoidance and High-powered Incentives",
Journal of Financial Economics,79(1):145-179.

**存在问题
1.由于文献中给出实际所得税率计算公式，且上市公司数据库中存在实际所得税一项，因此通过上市公司数据库中数据计算出实际所得税率，
认为其中变量“所得税率”为名义所得税率（看到文献中名义所得税率基本来自于wind数据库）。
【但是感觉这里还是存在问题，在CSMAR数据库中查“所得税率”变量定义的时候没有明确表明是名义所得税率】

*----------------文件基本设置--------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  指标构建   ---------------------------------------
use "$root/上市公司面板数据1391变量（1990-2022年）.dta"

****************** 法1:实际所得税率及变体 *******************************
---------- 实际所得税率=企业税收支出/税前收入
gen ETR=B140101_33/B140204_33
  //实际所得税/税前总利润
order ETR
sum ETR,d  //共60379，缺失17402

---------- 实际所得税率变体1:名义所得税率-实际所得税率(RATE＿diff)
gen RATE＿diff = F032801B-ETR
  //所得税率-ETR
order RATE＿diff
sum RATE＿diff,d

---------- 实际所得税率变体2:多期实际税率的平均值（例：“名义所得税率与实际税率之差”的五年平均值(第t-4年至第t年)(LRATE＿diff)）
forval i = 0/4 {by id_str: gen  RATE＿diff_l`i' =  RATE＿diff[_n-`i']}
  //生成差值变量
egen LRATE_diff = rowmean(RATE＿diff_l0 RATE＿diff_l1 RATE＿diff_l2 RATE＿diff_l3 RATE＿diff_l4)
  //计算五年滚动平均
order LRATE_diff
sum LRATE_diff,d


***************** 法2:账面-应税收入法及其变体 ****************************
---------- BTD法:BTD=（税前会计利润-应纳税所得额）/期末总资产;应纳税所得额=（所得税费用-延递所得税费用）/名义所得税税率
lookfor "所得税"
gen 应纳税所得额=(B002100000 -A001222000)/F032801B 
  //（减：所得税费用-递延所得税资产）/所得税率
order 应纳税所得额

lookfor "税前利润"
gen BTD=(F050601B-应纳税所得额)/A100000_33  
  //(息税前利润（EBIT）-应纳税所得额)/ 总资产-[专题-资本结构]
order BTD
sum BTD,d

---------- DDBTD法：TACC=（净利润-经营活动现金净流量）/总资产
lookfor "净利润"
gen TACC=(B002000000-D610000_33)/A100000_33 
  //(净利润-经营活动产生的现金流量净额)/总资产
order TACC
sum TACC,d

reg BTD TACC 
predict resid, residuals 
  // 基础回归模型，得到残差
bysort Stknme: egen mu_resid = mean(resid) 
  // 计算每个公司的残差均值
gen resid_diff = resid - mu_resid 
  // 计算残差与残差均值的偏离
gen DDBTD = mu_resid+resid_diff
order DDBTD
sum DDBTD,d


----------------输出一个统计性表格 excel-------------------------
export
save"$root/temp/上市公司数据-纳税遵从指标.dta"



