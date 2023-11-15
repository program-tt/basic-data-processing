* -------------------------------------------------------------------
**  对原始数据的清理 税务机构税收相关处罚
**  数据来源：    数据位置：
** tangtang
** 时间


** 处理中存在的问题：
*     1.  
*     2. 

** 处理后的数据用途： XXXX.do


*--------------------------------------------------------------------

*****   文件基本设置
 global root "/Users/apple/Desktop/税收处罚与企业流动"

local Y   
local X1
local X2 
local X3  

*-----------       原始数据清理      -----------------------------------
* 数据读取？
use "$root/税务机构处罚.dta",clear


split zhifadiyu, parse(",") gen(province) //命名要更加直观
    drop zhifadiyu
    // 这个变量是不是有一些奇怪的地方？？？？

duplicates drop xzid year, force // 看一下，drop了多少？

    drop if province1 == "None" & province2 == "None" & province3 == "None"
    drop if province2 == "None" & province3 == "None" //？？？

summarize //？

* 输出一个统计性表格 excel
eststo
esttab 
asddoc？

//？是否进行进一步的清理

save"$root/temp/1_税务机构处罚_sum.dta"
