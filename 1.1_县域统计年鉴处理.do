* -------------------------------------------------------------------
** 中国县域统计年鉴清理
** 唐棠
** 时间：2023.11.21

*----------------文件基本设置--------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  原始数据清理   ---------------------------------------
import excel "$root/【更新21数据】县域统计年鉴面板（2001-2022版）.xls",firstrow  clear
//数据导入

drop 乡及镇个数个 乡个数个 镇个数个 街道办事处个数个 村民委员会个数个 城镇单位在岗职工人数人 
      年末单位从业人员人 年末第二产业单位从业人员人 年末第三产业单位从业人员人 农林牧渔业从业人员数人 
      乡村从业人员数人 农业机械总动力万千瓦特 第一产业增加值万元 第二产业增加值万元 工业增加值万元 
      第三产业增加值万元 农业增加值万元 牧业增加值万元 城镇单位在岗职工平均工资元 城镇居民人均可支配收入元 
      农村居民人均可支配收入元 出口额美元 年末金融机构各项贷款余额万元 城乡居民储蓄存款余额万元 
      常用耕地面积公顷 机收面积公顷 设施农业占地面积公顷 农用机械总动力千万瓦 粮食总产量吨 棉花产量吨 
      油料产量吨 肉类总产量吨 农林牧渔业总产值万元 规模以上工业企业数个 城镇固定资产投资完成额万元 
      全社会固定资产投资万元 社会消费品零售总额万元 房地产开发投资亿元 普通小学学校数个 普通中学学校数个
      普通小学专任教师数人 普通中学专任教师数人 普通小学在校生数人 普通中学在校学生数人 中等职业教育学校在校学生数人 
      医院卫生院床位数床 医院和卫生院卫生人员数_卫生技术人员人 医院和卫生院卫生人员数_执业医师人 各种社会福利收养性单位数个
      各种社会福利收养性单位床位数床 全社会用电量万千瓦时 城乡居民生活用电量万千瓦时 废气中氮氧化物排放量吨 废气中烟尘排放量吨 
      工业废气中二氧化硫排放量吨 公共图书馆总藏量千册 艺术表演场馆数_剧场影剧院个 体育场馆机构数个 固定电话用户户 
      移动电话用户数户 宽带接入用户数户 行政区域土地面积平方公里 乡村户数户 乡村人口万人 各项税收万元 实际利用外资金额美元 
      农作物总播种面积千公顷 年末总户数户 规模以上工业总产值万元 地方财政一般预算支出万元 地方财政一般预算收入万元 人均地区生产总值元人
//删去无关变量

rename 地区名称 district_1
rename 年份 year
rename 所属城市 city_1
rename 所属省份 province
rename 地区生产总值万元 GDP
//调整变量名称，便于后续merge

order province city_1
sort province city_1 district_1 year

drop in 1/9543 
//由于是excel导入，前9543为空行

replace city_1 = "上海市" in 1/352
replace city_1 = "天津市" in 10803/11154
replace city_1 = "重庆市" in 50382/51217
replace city_1 = "潜江市" in 36632/36653
replace city_1 = "天门市" in 36610/36631
replace city_1 = "仙桃市" in 36588/36609
replace city_1 = "琼海市" in 36478/36499
replace city_1 = "五指山市" in 36302/36323
replace city_1 = "东方市" in 36236/36257
replace city_1 = "万宁市" in 36214/36235

replace city_1 = "海南省" in 1/44
replace city_1 = "新疆维吾尔自治区" in 45/66
replace city_1 = "海南省" in 67/88
replace city_1 = "新疆维吾尔自治区" in 89/110
replace city_1 = "北京市" in 111/132
replace city_1 = "海南省" in 133/154
replace city_1 = "北京市" in 155/176
replace city_1 = "海南省" in 177/198
replace city_1 = "北京市" in 199/264
replace city_1 = "海南省" in 265/308
replace city_1 = "济源市" in 309/330
replace city_1 = "海南省" in 331/396
replace city_1 = "新疆维吾尔自治区" in 397/418
replace city_1 = "湖北省" in 419/440
replace city_1 = "新疆维吾尔自治区" in 441/462
replace city_1 = "海南省" in 463/484
//部分数据存在对应不准确问题，进行手动调整

count if GDP==. //6,835
count if 年末总人口万人==. //8,145
count if 户籍人口数万人==. //2,651
//查看三个变量的缺失值数量

 replace district_1 =strtrim(district_1)
//0 
replace city_1 =strtrim(city_1)
//0
replace province =strtrim(province)
//0


----------------输出一个统计性表格 excel-------------------------
sum GDP,d
sum 年末总人口万人,d
sum 户籍人口数万人,d
export
save"$root/temp/县域统计年鉴2000-2021.dta"


