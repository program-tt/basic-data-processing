* -------------------------------------------------------------------
** 税务机构税收相关处罚变量构建
** 数据来源：    数据位置：
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.17

** 存在问题：
   1.在构建country_level_penalty时进行统一化的过程中如何获取GDP，人数数据呢，是需要自己进行爬取吗
   2.41行duplicates drop后每一区县年份是随意留下一组，那么对应的devia_penalty也是随机留下一组，这个变量是否意义就不大了呢

*--------------- 文件基本设置 ------------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

local Y   
local X1
local X2 
local X3  
*--------------  变量构建   ---------------------------------------
use "$root/税务机构处罚.dta",clear  
//数据读取

destring amount_in_num, replace
//将amount_in_num调整为数值格式，便于后续进行运算处理

bysort province city district year: egen country_level_penalty = sum(amount_in_num)
sort country_level_penalty
//相对值 人数、GDP、次数、行业内计算次数
 
bysort province city district year: egen mean_penalty = mean(amount_in_num) 
//构建区县层面罚款均值数据
 
bysort province city district year: egen sd_penalty = sd(amount_in_num) 
//构建区县层面罚款标准差数据，衡量罚款波动程度
recode sd_penalty (.=0)
//将缺失值处理为0：3115 changes made

bysort province city district year: gen devia_penalty = amount_in_num - mean_penalty 
//构建区县层面罚款离差数据，衡量罚款偏离程度

duplicates drop province city district year, force
//将数据处理为区县，年份一一对应，为后续merge作准备：35,727 observations deleted

sum mean_penalty ,d
histogram mean_penalty
sum sd_penalty ,d
histogram sd_penalty
count if sd_penalty==0     //  3,844

----------------输出一个统计性表格 excel-------------------------
eststo mydata

save"$root/temp/1_税务机构处罚_sum.dta"

** 税务机关处罚数据处理完毕
