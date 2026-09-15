log using Savani_PsychologSci_2010_88xa.log
clear
import excel using DatabySubjectKS, firstrow

anova numactions culture##cond

esize twosample numactions, by(cond)

log close