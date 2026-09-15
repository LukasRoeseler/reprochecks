clear
global NUMBER_OF_SUBJECTS NUMBER_OF_BOOTS
NUMBER_OF_SUBJECTS=101;
NUMBER_OF_BOOTS=1000;
risk1=xlsread('inputs.xlsx','risk1'); %all data 101x10
risk2=xlsread('inputs.xlsx','risk2'); %last column contains switchpoint 101x11
time1=xlsread('inputs.xlsx','time1'); %all data 101x10
time2=xlsread('inputs.xlsx','time2'); %last column contains switchpoint 101x11
eis1=xlsread('inputs.xlsx','eis1'); %11th column contains total money divided, last column contains total of choices (useless?)
eis2=xlsread('inputs.xlsx','eis2'); %last column contains switchpoint 101x11
for bootcounter=1:NUMBER_OF_BOOTS
    display(bootcounter);
    boots_used=random('unid',NUMBER_OF_SUBJECTS,NUMBER_OF_SUBJECTS,1);
    risk1_export=risk1(boots_used,:);
    risk2_export=risk2(boots_used,:);
    time1_export=time1(boots_used,:);
    time2_export=time2(boots_used,:);
    eis1_export=eis1(boots_used,:);
    eis2_export=eis2(boots_used,:);
    fname=['boot inputs\inputb' num2str(bootcounter) '.xlsx'];
    writetable(array2table(risk1_export), fname, 'Sheet', 'risk1');
    writetable(array2table(risk2_export), fname, 'Sheet', 'risk2');
    writetable(array2table(time1_export), fname, 'Sheet', 'time1');
    writetable(array2table(time2_export), fname, 'Sheet', 'time2');
    writetable(array2table(eis1_export), fname, 'Sheet', 'eis1');
    writetable(array2table(eis2_export), fname, 'Sheet', 'eis2');
end