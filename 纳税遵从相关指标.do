* -------------------------------------------------------------------
** 纳税遵从指标构建
** 唐棠
** 时间：2024.1.14

*----------------文件基本设置--------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  原始数据清理   ---------------------------------------

use "$root/上市公司面板数据1391变量（1990-2022年）.dta"

****** ETR有效税率法：企业税收支出/税前收入 **********
**（1）:息税前利润（EBIT）/实际所得税
gen TA1 = F050601B/B140204_33
order TA1
sum TA1,d  //共57583，缺失20198

**（2）:税前总利润/实际所得税
gen TA2=B140101_33/B140204_33
order TA2
sum TA2,d  //共60379，缺失17402

count if TA1==. &TA2==. //17402


****** BTD账面-应税收入法 **********
//BTD=（税前会计利润-应纳税所得额）/期末总资产
//应纳税所得额=（所得税费用-延递所得税费用）/名义所得税税率
//TACC=（净利润-经营活动现金净流量）/总资产

lookfor "所得税"
gen 应纳税所得额=(B002100000 -A001222000)/F032801B 应纳税所得额=//（减：所得税费用-递延所得税资产）/所得税率
order 应纳税所得额

lookfor "税前利润"
gen BTD=(F050601B-应纳税所得额)/A100000_33  
//(息税前利润（EBIT）-应纳税所得额)/ 总资产-[专题-资本结构]
order BTD
 
lookfor "净利润"
gen TACC=(B002000000-D610000_33)/A100000_33 
//(净利润-经营活动产生的现金流量净额)/总资产
order TACC


**进行简单线性回归
reg BTD TACC 
predict resid, residuals // 基础回归模型，得到残差
bysort Stknme: egen mu_resid = mean(resid) // 计算每个公司的残差均值
gen resid_diff = resid - mu_resid // 计算残差与残差均值的偏离
reg BTD TACC mu_resid resid_diff // 将残差均值和残差偏离纳入回归方程
outreg se

**使用时间，个体固定效应
destring id_str,replace
xtset id_str year
xtreg BTD TACC i.year, fe
outreg se,m


----------------输出一个统计性表格 excel-------------------------
export
save"$root/temp/上市公司数据-纳税遵从指标.dta"



