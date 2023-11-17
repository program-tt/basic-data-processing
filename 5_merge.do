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
 global root "/Users/apple/Desktop/税收处罚与企业流动"

local Y   
local X1
local X2 
local X3  
*--------------  基本处理   ---------------------------------------
use "$root/税务机构处罚.dta",clear  
//数据读取

use "$root/企业地址流动.dta"
rename newdistrict district_1
save "/Users/apple/Desktop/税收处罚与企业流动/temp/1_企业地址流动.dta", replace

use "/Users/apple/Desktop/税收处罚与企业流动/temp/2_税务机关处罚.dta" 
rename province3 district_1

use "/Users/apple/Desktop/税收处罚与企业流动/temp/1_新注册企业.dta"
rename 地区 district_1
rename 年份 year

merge 1:m city_1 district_1 year using "/Users/apple/Desktop/税收处罚与企业流动/temp/1_企业地址流动.dta" // 谨慎检查？
drop _merge

merge m:m district_1 year using "/Users/apple/Desktop/税收处罚与企业流动/temp/1_新注册企业.dta" // 一般不用mm

save "/Users/apple/Desktop/税收处罚与企业流动/temp/merge.dta"


