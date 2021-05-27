#generating lag of total assets,lag of total revuenues,lag of current liabilities,lag of current assets and lag of cash
xtset companyid year
sort companyid year
by companyid : gen lag1totalassets =  assetstotal[_n-1]
by companyid : gen lag1revenues = revenuetotal[_n-1]
by companyid : gen lag1currentassets = currentassetstotal[_n-1]
by companyid : gen lag1currentliabilities = currentliabilitiestotal[_n-1]
by companyid : gen lag1cash = cashandshortterminvestments[_n-1]


#preparing the dependent variable y and the three indenpendent variables (x1,x2,x3) for the Jones (1991) model
gen deltacurrentassets= currentassetstotal- lag1currentassets
gen deltacurrentliabilities= currentliabilitiestotal - lag1currentliabilities
gen deltacash= cashandshortterminvestments - lag1cash
gen y= deltacurrentassets- deltacurrentliabilities- deltacash- depreciationoftangiblefixedasset
gen deltarevenues= revenuetotal- lag1revenues
gen x1=1/ lag1totalassets
gen x2= deltarevenues/ lag1totalassets
gen x3= propertyplantandequipment/ lag1totalassets


#running the main analysis
xtset year 
gen A=.   
replace A=. 
local companyStart = 2 
local companyEnd=40788
capture count 
local totalObserVation=r(N) 
local recordCount=0 

while `companyStart'<`companyEnd' { 
capture count if (company==`companyStart')  
			local recordCountCompany=r(N)
			if(`recordCountCompany'>0){
			capture count if (company==`companyStart'  & y!=. & x1!=. & x2!=. & x3!=.)  
			local recordCount=r(N) 
			if(`recordCount'>5){			
			capture reg y x1 x2 x3 if (company==`companyStart' & y!=. & x1!=. & x2!=. & x3!=.)  
			mat beta=e(b) 
			local betaX1 =_b[x1] 
			local betaX2 =_b[x2] 
			local betaX3 =_b[x3] 
			local beta_const=_b[_cons] 
			local loopCounter=0 
			local yearStart = 2001
			local yearEnd=2021
			while `yearStart'<`yearEnd'{
			replace A= y-(`beta_const'+(`betaX1' * x1) + (`betaX2' * x2 )+ (`betaX3' * x3)) if (company==`companyStart' & year==`yearStart' & y!=. & x1!=. & x2!=. & x3!=.)
			local yearStart = `yearStart' + 1
			}
			}
			}
			local companyStart = `companyStart' + 1
			}
display "done"


