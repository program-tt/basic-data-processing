* -------------------------------------------------------------------
** 基本回归：lnBTD,lnDDBTD
   稳健性检验
** 唐棠
** 时间：2024.1.24

**存在问题：
1.培根分解部分stata显示没有ddtiming的命令（这一部分是必须的吗）
2.排除金税三期影响的稳健性分析那里还需要构建金税三期的DID，但是我们的数据里好像没包含这部分我就直接删掉了

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
reg lnBTD DID
estadd local 个体固定效应 "No" 
estadd local 时间固定效应 "No" 
estadd local 行业固定效应 "No"  
est store m1
reg lnDDBTD DID
estadd local 个体固定效应 "No" 
estadd local 时间固定效应 "No" 
estadd local 行业固定效应 "No"  
est store m2

***加固定效应************************************************
xtreg lnBTD DID  i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store m3
xtreg lnDDBTD DID  i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store m4

***加控制变量************************************************
xtreg lnBTD DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store m5
xtreg lnDDBTD DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store m6

esttab m1 m2 m3 m4 m5 m6 using 基准回归分析.rtf, ar2 scalar( N 个体固定效应 时间固定效应 行业固定效应 )drop(__0000*) compress star(* 0.1 ** 0.05 *** 0.01) nogap b(3) t(2) replace




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


xtreg lnBTD pre_4 pre_3 pre_2  current las_1 las_2 las_3 $xlist i.year i.Sic2 ,fe vce(cluster province)
xtreg lnDDBTD pre_4 pre_3 pre_2  current las_1 las_2 las_3 $xlist i.year i.Sic2 ,fe vce(cluster province)
coefplot, baselevels keep( pre_* current las_*) omitted vertical recast(connect) yline(0) ytitle("政策动态效应")  ///
xtitle("政策实施的相对时间") xlabel(1 "-4" 2"-3" 3"-2" 4"0" 5"1" 6"2" 7"3" )ciopts(recast(rcap)) scheme(s1mono) levels(95) 
graph export "平行趋势检验.png",as(png) replace width(800) height(600)
 
 

**********************     稳健性检验   ****************************************************

***  异质性DID *********************
***无协变量的培根分解
ddtiming lnBTD DID ,i( id ) t(year)
ddtiming lnDDBTD DID ,i( id ) t(year)
***计算稳健估计量
csdid lnBTD $xlist ,ivar( id ) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province) agg(simple)
est store m1
csdid lnDDBTD $xlist ,ivar( id ) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province) agg(simple)
est store m2

csdid lnBTD $xlist ,ivar( id ) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province) notyet agg(simple)
est store m3
csdid lnDDBTD $xlist ,ivar( id ) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province) notyet agg(simple)
est store m4

**动态平均处理效应
csdid lnBTD $xlist ,ivar(id) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province)  agg(event)
est store m5
csdid lnDDBTD $xlist ,ivar(id) time(year) gvar(disctetion_year) method(stdipw)vce(cluster province)  agg(event)
est store m6

esttab m1 m2 m3 m4 m5 m6 using 异质性did.rtf, ar2 scalar(N ) compress star(* 0.1 ** 0.05 *** 0.01) nogap b(3) t(2) replace


***安慰剂检验 提前两年  
gen post2 = 0
replace post2 = 1 if treat == 1 & year >= disctetion_year+2

xtreg lnBTD post2 $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes"  
est store a1
xtreg lnDDBTD post2 $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes"  
est store a2


***更换被解释变量
xtreg  lnETR DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store a3

xtreg lnRATE_diff DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
**# Bookmark #1
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store a4
 
xtreg lnLRATE_diff DID $xlist i.year i.Sic2 ,fe vce(cluster province)
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes" 
est store a5


*排除干扰性因素营改增的影响 
gen ind2 = substr(Sicda_str, length(Sicda_str)-1, 2)
destring ind2,replace
order ind2

drop if ind2 == 54|  ind2 == 55|  ind2 == 56|  ind2 == 57|  ind2 == 58|  ind2 == 59|  ind2 == 63|  ind2 == 64|  ind2 == 65|  ind2 == 71|  ind2 == 72|  ind2 == 73|  ind2 == 74|  ind2 == 75|  ind2 == 81|  ind2 == 86
xtreg lnBTD DID $xlist i.year i.ind ,fe  vce(cluster prov) 
estadd local 个体固定效应 "Yes" 
estadd local 时间固定效应 "Yes" 
estadd local 行业固定效应 "Yes"
est store a6
esttab a4 using 稳健性检验2.rtf, ar2 scalar(N 个体固定效应 时间固定效应 行业固定效应) drop(__0000*) compress star(* 0.1 ** 0.05 *** 0.01) nogap b(3) t(2) replace


