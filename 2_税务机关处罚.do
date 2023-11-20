* -------------------------------------------------------------------
** 税务机构税收相关处罚变量构建
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.17
** 修改二稿时间：2023.11.20

** 二修改部分：
   1.构建新country_level_penalty（GDP/人口），并检查变量
   2.删除devia_penalty
   3.输出描述性统计表格

*--------------- 文件基本设置 ------------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"
 
*--------------  变量构建   ---------------------------------------
use "$root/raw data/税务机构处罚.dta",clear  
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

*——————————————————— 数据检查 ——————————————————————————————————————————
sum mean_penalty ,d
histogram mean_penalty
graph box mean_penalty

sum sd_penalty ,d
histogram sd_penalty
graph box sd_penalty 
 count if sd_penalty==0     //  3,844
//对两个变量进行描述性统计并画图检查是否有不合要求的数据

*----------------输出一个统计性表格 excel-------------------------
eststo mydata

save"$root/temp/1_税务机构处罚_sum.dta"

** 税务机关处罚数据处理完毕
