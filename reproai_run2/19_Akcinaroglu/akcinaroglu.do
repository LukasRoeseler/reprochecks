
clear
import excel using replicationdata, firstrow

*Replication Codes
*Peace Agreements
*stset  accumulateddays, failure(outcome=1)
stcrreg polity  rsup govsupport  gdp numberofrebels  alliance formalalliance  rebelsize 
alliancesize intensity  milper, compete(outcome =2 3 4) vce(robust)
stcrreg polity  rsup govsupport  gdp numberofrebels  allianceduration formalalliance  
rebelsize alliancesize intensity  milper, compete(outcome =2 3 4) vce(robust)
stcrreg polity  rsup govsupport  gdp  alliance  rebelsize intensity  milper, 
compete(outcome =2 3 4) vce(robust)

*Rebel Victory
stset  accumulateddays, failure(outcome=3)
stcrreg polity  rsup govsupport  gdp numberofrebels  alliance formalalliance  rebelsize 
alliancesize intensity  milper, compete(outcome =1 2 4) vce(robust)
stcrreg polity  rsup govsupport  gdp numberofrebels  allianceduration formalalliance  
rebelsize alliancesize intensity  milper, compete(outcome =1 2 4) vce(robust)
stcrreg polity  rsup govsupport  gdp alliance  rebelsize intensity  milper, 
compete(outcome =1 2 4) vce(robust)
Government Victory
stset  accumulateddays, failure(outcome=2)
stcrreg polity  rsup govsupport  gdp numberofrebel alliance formalalliance  rebelsize 
alliancesize intensity  milper, compete(outcome =1 3 4) vce(robust)
stcrreg polity  rsup govsupport  gdp numberofrebels  allianceduration formalalliance  
rebelsize alliancesize intensity  milper, compete(outcome =1 3 4) vce(robust)
stcrreg polity  rsup govsupport  gdp  alliance  rebelsize intensity  milper, 
compete(outcome =1 3 4) vce(robust)

*Attrition
stset  accumulateddays, failure(outcome=4)
stcrreg polity  rsup govsupport  gdp numberofrebels  alliance formalalliance  rebelsize 
alliancesize intensity  milper, compete(outcome =1 2 3) vce(robust)
stcrreg polity  rsup govsupport  gdp numberofrebels  allianceduration formalalliance  
rebelsize alliancesize intensity  milper, compete(outcome =1 2 3) vce(robust)
stcrreg polity  rsup govsupport  gdp alliance  rebelsize intensity  milper, 
compete(outcome =1 2 3) vce(robust)

*log close