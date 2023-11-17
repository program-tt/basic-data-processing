* -------------------------------------------------------------------
** 税务机关处罚、新注册企业、企业地址流动数据在区县层面上合并
** 数据来源：  
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.17

** 存在问题：
   1.
   2.

*--------------- 文件基本设置 ------------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动/temp"

local Y   
local X1
local X2 
local X3  
*--------------  变量名称修改   ---------------------------------------
use "$root/1_税务机构处罚_sum.dta",clear  
   rename city city_1
   rename district district_1
   save "$root/2_税务机构处罚.dta", replace
use "$root/1_企业地址流动_sum.dta"
   rename newcity city_1
   rename newdistrict district_1
   save "$root/2_企业地址流动.dta", replace
use "$root/1_新注册企业_sum.dta"
   rename 地区 district_1
   rename 年份 year
   save "$root/2_新注册企业.dta", replace
//将数据集中merge的依据变量名称进行修改，便于合并

*--------------  数据集合并   ---------------------------------------
use "$root/2_税务机构处罚.dta",clear
merge 1:m city_1 district_1 year using "$root/2_企业地址流动.dta" 
tab _merge
count if _merge!=2
drop _merge
save "$root/1_merge.dta",replace
//进行前两组数据的合并，并检查成功合并的数据数量

use "$root/1_merge.dta",clear  
merge m:1 district_1 year using "$root/2_新注册企业.dta" 

save "/Users/apple/Desktop/税收处罚与企业流动/temp/merge.dta"


