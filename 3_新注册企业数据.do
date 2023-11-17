* -------------------------------------------------------------------
** 新注册企业数据基本处理
** 数据来源：天眼查    
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.17

** 存在问题：
   1.想要构建一个指标描述同一地区中该年份与2000年间total_number的差值作为change变量，感觉excel里很好操作，
     但数据量太大无法导出为excel,不太清楚在stata中应该如何操作（是要先转置再处理吗）---这里先没加
     【duplicates drop 年份 行政区划代码 地区, force】的命令，想针对对行业再构造些变量后再加上
   2.还是和前面一样sum/GDP或人数的问题

*--------------- 文件基本设置 ------------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

local Y   
local X1
local X2 
local X3  
*--------------  基本处理   ---------------------------------------
use "$root/税务机构处罚.dta",clear  
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

save"$root/temp/1_税务机构处罚_sum.dta"

** 新注册企业数据处理完毕




