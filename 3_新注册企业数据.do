* -------------------------------------------------------------------
** 新注册企业数据基本处理
** 数据来源：天眼查    
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.17
** 修改二稿时间：2023.11.20

** 二稿修改部分：
   1.一阶差分构建change变量
   2.与gdp和人口数据合并，构建新total_number变量并检查
   3.输出描述统计性表格

*--------------- 文件基本设置 ------------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  基本处理   ---------------------------------------
use "$root/raw data/新注册企业数据.dta",clear  
//数据读取

drop 数据整理 原始来源
drop if 年份 == .       //2 observations deleted
//删除无关变量与缺失值

count if 当年企业注册数目==0     // 292,601
count if 当年企业注册数目>=10000  // 2,054
count if 当年企业注册数目>=100000  // 26

*--------------- 变量构建 --------------------------------------------
bysort 地区 年份: egen total_number = sum(当年企业注册数目)/GDP或人数
//计算同一地区、同一年份下各行业总注册数目
bysort 地区 年份: egen max_number = max(当年企业注册数目)
//计算同一地区、同一年份下行业中最大注册数目
bysort 行业代码 年份:egen industry_total_number=sum(当年企业注册数目)
//计算同一年份下，每一行业在全国注册的总数

*---------------- 数据检查 ——-----------------------------------------
sum max_number,d
histogram max_number
graph box max_number
 count if max_number>=10000  //40,600
 count if max_number>=100000 //500
sum industry_total_number,d
histogram industry_total_number
graph box industry_total_number
//进行描述性统计并画图检查是否有不合要求的数据

----------------输出一个统计性表格 excel-------------------------
eststo mydata

save"$root/temp/1_新注册企业数据_sum.dta"

** 新注册企业数据处理完毕




