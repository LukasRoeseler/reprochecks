#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

use DATA_1900_2004;

/** Number of doctors per 1000 population ***/

summ i1_phys [aw=totalpop] if(year==1930); 
summ i1_phys [aw=totalpop] if(year==1960);
summ i1_phys [aw=totalpop] if(year==2004);

table uscr [aw=totalpop] if(year==1930), c(mean i1_phys);
table uscr [aw=totalpop] if(year==1960), c(mean i1_phys);
table uscr [aw=totalpop] if(year==2004), c(mean i1_phys);

/** Share of Household with Electricity ***/

summ elec [aw=totalpop] if(year==1930);
summ elec [aw=totalpop] if(year==1959);
summ elec [aw=totalpop] if(year==1960);

table uscr [aw=totalpop] if(year==1930), c(mean elec);
table uscr [aw=totalpop] if(year==1959), c(mean elec);
table uscr [aw=totalpop] if(year==1960), c(mean elec);

/** Share of Household with Residential AC ***/

summ i2_ac [aw=totalpop] if(year==1960);
summ i2_ac [aw=totalpop] if(year==1980);
summ i2_ac [aw=totalpop] if(year==2004);

table uscr [aw=totalpop] if(year==1960), c(mean i2_ac);
table uscr [aw=totalpop] if(year==1980), c(mean i2_ac);
table uscr [aw=totalpop] if(year==2004), c(mean i2_ac);
clear;


use DATA_TABLE9;

replace q_elec=q_elec/1000;

summ q_elec if aircon==1;
summ q_elec if aircon==0;
summ p_elec;

table uscr if(aircon==1), c(mean q_elec);
table uscr if(aircon==0), c(mean q_elec);
table uscr, c(mean p_elec);
clear;
