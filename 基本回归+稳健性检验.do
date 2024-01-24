* -------------------------------------------------------------------
** 基本回归：lnDDBTD
   稳健性检验
** 唐棠
** 时间：2024.1.24
** 一稿修改时间：2024.1.25
** 修改内容：
1.根据显著性，被解释变量仅保留lnDDBTD
2.平行趋势检验那里仍有疑问，正在修改中：加了一版修改原稿、缩尾、增加政策后时间的代码，但好像效果还是不太好
3.稳健性检验部分删除不显著的方法，对显著的方法进行简单补充修改

*----------------文件基本设置--------------------------------------
global root "/Users/apple/Desktop/税收处罚与企业流动"

*--------------  对裁量权数据进行基本处理构建   ---------------------------------------
use "$root/merge1.dta"

*******************描述性统计******************************************************
logout,save(描述性统计) word replace:sum lnETR lnRATE_diff lnLRATE_diff lnBTD lnDDBTD DID ROE MB LEV REC INV FIXED size ADM Bdsize big4 First10 SOE
asdoc sum lnETR lnRATE_diff lnLRATE_diff lnBTD lnDDBTD DID ROE MB LEV REC INV FIXED size ADM Bdsize big4 First10 SOE, dec(6), save(表1描述性统计.doc) 


***基准回归：税收征管规范化与企业投资效率************************
global xlist ROE MB LEV REC INV FIXED size ADM Bdsize big4 First10 SOE
xtset id year 
reg lnDDBTD DID
estadd local 个体固定效应 "No" 
estadd local 时间固定效应 "No" 
estadd local 行业固定效应 "No"  
est store m1

***加固定效应************************************************
xtreg lnDDBTD DID  i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store m2

***加控制变量************************************************
xtreg lnDDBTD DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store m3

esttab m1 m2 m3 using 基准回归分析.rtf, ar2 scalar( N 个体固定效应 时间固定效应 行业固定效应 )drop(__0000*) compress star(* 0.1 ** 0.05 *** 0.01) nogap b(3) t(2) replace



*************   平行趋势检验    *******************************************
gen G=0
replace G=1 if disctetion_year <2050
gen event = year - disctetion_year if G==1
tab event
replace event = -4 if event <= -4
replace event = 3 if event >= 3
replace event =. if G==0
tab event

forvalues i=4(-1)1{
gen pre_`i'=(event==-`i'&G==1)
}
gen current=(event==0)
forvalues i=1(1)3{
gen las_`i'=(event==`i'&G==1)
}

xtreg lnDDBTD pre_4 pre_3 pre_2  current las_1 las_2 las_3 $xlist i.year i.Sic2 ,fe vce(cluster province)
coefplot, baselevels keep( pre_* current las_*) omitted vertical recast(connect) yline(0) ytitle("政策动态效应")  ///
xtitle("政策实施的相对时间") xlabel(1 "-4" 2"-3" 3"-2" 4"0" 5"1" 6"2" 7"3" )ciopts(recast(rcap)) scheme(s1mono) levels(95) 
graph export "平行趋势检验.png",as(png) replace width(800) height(600)
--------------------------------
winsor2 DDBTD, cut(5 95)
gen lnDDBTD1=ln(DDBTD)
 
gen G=0
replace G=1 if disctetion_year <2050
gen event = year - disctetion_year if G==1
tab event
replace event = -4 if event <= -4
replace event = 7 if event >= 7
replace event =. if G==0
tab event

forvalues i=4(-1)1{
gen pre_`i'=(event==-`i'&G==1)
}
gen current=(event==0)
forvalues i=1(1)7{
gen las_`i'=(event==`i'&G==1)
}

xtreg lnDDBTD pre_4 pre_3 pre_2  current las_1 las_2 las_3 las_4 las_5 las_6 las_7 $xlist i.year i.Sic2 ,fe vce(cluster province)
coefplot, baselevels keep( pre_* current las_*) omitted vertical recast(connect) yline(0) ytitle("政策动态效应") xtitle("政策实施的相对时间") ///
xlabel(1 "-4" 2"-3" 3"-2" 4"0" 5"1" 6"2" 7"3" 8"4" 9"5" 10"6" 11"7")ciopts(recast(rcap)) scheme(s1mono) levels(95) 
graph export "平行趋势检验.png",as(png) replace width(800) height(600)
 
 
 
**********************     稳健性检验   ****************************************************

*** 异质性DID *********************
***无协变量的培根分解
ddtiming lnDDBTD DID ,i( id ) t(year)
***计算稳健估计量
csdid lnDDBTD $xlist ,ivar( id ) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province) agg(simple)
est store m1

csdid lnDDBTD $xlist ,ivar( id ) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province) notyet agg(simple)
est store m2

**动态平均处理效应
csdid lnDDBTD $xlist ,ivar(id) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province)  agg(event)
est store m3

esttab m1 m2 m3 using 异质性did.rtf, ar2 scalar(N ) compress star(* 0.1 ** 0.05 *** 0.01) nogap b(3) t(2) replace


***安慰剂检验 提前两年  
gen post2 = 0
replace post2 = 1 if treat == 1 & year >= disctetion_year+2
 
xtreg lnDDBTD post2 $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes"  
est store a1

***更换被解释变量
xtreg lnETR DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store a2

***排除干扰性因素营改增的影响 
gen ind2 = substr(Sicda_str, length(Sicda_str)-1, 2)
destring ind2,replace
order ind2

drop if ind2 == 54|  ind2 == 55|  ind2 == 56|  ind2 == 57|  ind2 == 58|  ind2 == 59|  ind2 == 63|  ind2 == 64|  ind2 == 65|  ind2 == 71|  ind2 == 72|  ind2 == 73|  ind2 == 74|  ind2 == 75|  ind2 == 81|  ind2 == 86
xtreg lnDDBTD DID $xlist i.year i.Sic2 ,fe  vce(cluster province) 
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes"
est store a3
esttab a1 a2 a3 using 稳健性检验2.rtf, ar2 scalar(N 个体固定效应 时间固定效应 行业固定效应) drop(__0000*) compress star(* 0.1 ** 0.05 *** 0.01) nogap b(3) t(2) replace


