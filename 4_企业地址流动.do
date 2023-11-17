* -------------------------------------------------------------------
** 企业地址流动数据基本处理
** 数据来源：  
** 唐棠
** 时间：2023.11.14
** 修改一稿时间：2023.11.17

** 一稿存在问题：
   1.这里大部分的old_address变量与后面的oldprovince，oldcity，olddistrict变量不符合
   2.对于区县内流动企业与地址未改变的企业无法区分：一方面因为old_address变量不准确，另一方面这两种情况下
     oldprovince，oldcity，olddistrict与newprovince，newcity，newdistrict完全相同

*--------------- 文件基本设置 ------------------------------------------
 global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  基本处理   ---------------------------------------
use "$root/raw data/企业地址流动.dta",clear  
//数据读取

replace oldprovince = "陕西省" in 7
replace oldcity = "榆林市" in 7
replace olddistrict = "榆阳区" in 7
replace oldprovince = "陕西省" in 5
replace oldcity = "榆林市" in 5
replace olddistrict = "榆阳区" in 5

replace newprovince = "陕西省" in 7
replace newcity = "榆林市" in 7
replace newdistrict = "榆阳区" in 7
replace newprovince = "陕西省" in 6
replace newcity = "榆林市" in 6
replace newdistrict = "榆阳区" in 6
replace newprovince = "陕西省" in 5
replace newcity = "榆林市" in 5
replace newdistrict = "榆阳区" in 5
replace newprovince = "陕西省" in 4
replace newcity = "榆林市" in 4
replace newdistrict = "榆阳区" in 4
replace old_address = "陕西省榆阳区南郊市交通局家属院" in 4
replace old_address = "陕西省榆林市榆阳区马合镇东马合村" in 5
replace newprovince = "广州市" in 3
replace newprovince = "广东省" in 3
replace newcity = "广州市" in 3
replace newdistrict = "增城区" in 3
replace newprovince = "浙江省" in 1
replace newcity = "绍兴市" in 1
replace newdistrict = "柯桥区" in 1
replace newdistrict = "临泉县" in 2
replace newprovince = "安徽省" in 2
replace newcity = "阜阳市" in 2
//根据new_address和old_address进行缺失数据补充

count if newprovince == oldprovince  //285,899
//企业省内流动数量（包含未流动）
count if newcity== oldcity      //283,378
//企业市内流动数量（包含未流动）
count if newdistrict== olddistrict   //235,652
//企业区县内流动数量（包含未流动）

tab newprovince
//观察企业流动后各省（直辖市）企业数目
tab oldprovince
//观察企业流动前各省（直辖市）企业数目
tab newprovince oldprovince
//观察省级企业流向

duplicates drop newprovince newcity newdistrict oldprovince oldcity olddistrict year,force 
//将数据整理为区县级数据，便于后续合并

----------------输出一个统计性表格 excel-------------------------
eststo mydata

save"$root/temp/1_企业地址流动_sum.dta"

** 企业地址流动数据处理完毕，未涉及新变量构建
