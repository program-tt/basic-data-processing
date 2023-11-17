* -------------------------------------------------------------------
** 税务机构税收相关处罚数据清理
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.16

*----------------文件基本设置--------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  原始数据清理   ---------------------------------------
use "$root/raw data/税务机构处罚.dta",clear  
//数据读取

split zhifadiyu, parse(",") gen(province) 
  rename province1 province
  rename province2 city
  rename province3 district
  sort zhifadiyu
  drop zhifadiyu
//将省市区变量进行分割并重新命名，便于后续merge

duplicates drop xzid year, force 
// 无数据被删除
    drop if province == "None" & city == "None" & district == "None"
//89 observations deleted

replace province = "广东省" in 1
replace city = "广州市" in 1
replace district = "库车县" in 2/7
replace city = "阿克苏地区" in 2/7
replace province = "新疆维吾尔自治区" in 2/7
replace district = "西咸新区" in 8/25
replace province = "陕西省" in 8/25
replace city = "北京市" in 26/54
replace province = "湖北省" in 55
replace city = "襄阳市" in 55
replace city = "龙岩市" in 56
replace province = "福建省" in 56
replace district = "潜山县" in 57/71
replace city = "潜山市" in 57/71
replace province = "安徽省" in 57/71
replace city = "咸阳市" in 72
replace city = "咸阳市" in 73
replace province = "陕西省" in 72
replace province = "陕西省" in 73
replace province = "重庆市" in 74/107
replace city = "重庆市" in 74/107
replace province = "福建省" in 108
replace city = "宁德市" in 108
replace province = "内蒙古自治区" in 109
replace city = "鄂尔多斯市" in 109
replace province = "青海省" in 110
replace city = "茫崖市" in 110
replace province = "湖北省" in 111/116
replace city = "武汉市" in 111/116
replace city = "上海市" in 117/1938
//部分数据存在问题，进行手动查询与调整

count if city== "None" & district == "None"     // 808
//计算精确度仅到省的数据的数量
count if city!= "None" & district == "None"     //7,812
//计算精确度仅到市的数据的数量

----------------输出一个统计性表格 excel-------------------------
ssc install estout
eststo mydata

save"$root/temp/1_税务机构处罚_sum.dta"

* 后续还将进行新变量定义
