* -------------------------------------------------------------------
** 税务机构税收相关处罚数据清理
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.16
** 修改二稿时间：2023.11.20

** 二稿修改部分：
   1.输出excel统计性表格部分
   2.去除字符串前后空格
   2.与gdp数据合并，并检查

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

replace city_1 = "重庆市" in 16/20
replace city_1 = "万宁市" in 9/14
replace district_1 = "上虞区" in 76/78
replace city_1 = "海南省" in 138/142
replace city_1 = "重庆市" in 235/236

sort province city_1 district_1 year
replace district_1 = "崇明区" in 26/28
replace city_1 = "新疆维吾尔自治区" in 3315/3333
replace district_1 = "清苑区" in 4254/4257
replace district_1 = "满城区" in 4261/4263
replace district_1 = "永年区" in 4673/4677
replace district_1 = "肥乡区" in 4687/4690
replace city_1 = "济源市" in 5082/5084
replace city_1 = "海南省" in 5603/5669
replace city_1 = "湖北省" in 5811/5814
replace city_1 = "襄阳市" in 5848/5867
replace city_1 = "重庆市" in 6934/7069
//部分数据存在问题，进行手动查询与调整

duplicates report province city_1 district_1 year //0

count if city== "None" & district == "None"     // 808
//计算精确度仅到省的数据的数量
count if city!= "None" & district == "None"     //7,812
//计算精确度仅到市的数据的数量

replace district_1 =strtrim(district_1) //5,511
replace city_1 =strtrim(city_1) //5,439 

duplicates report province city_1 district_1 year //383
duplicates drop province city_1 district_1 year, force //383


tab district 

----------------输出一个统计性表格 excel-------------------------
sum
export
save"$root/temp/1_税务机构处罚_sum.dta"

* 后续还将进行新变量定义
