function [wireIndex]=findIndex(string)%searches vector for char or int
%FIND INDEX finds the index corresponding to a string indicating wire size.
%   This function is not currently used.
sizes=cellstr(['18  ';'16  ';'14  ';'12  ';'10  ';'8   ';'6   ';'4   ';'3   ';'2   ';'1   ';'1/0 ';'2/0 ';'3/0 ';'4/0 ';'250 ';'300 ';'350 ';'400 ';'500 ';'600 ';'700 ';'750 ';'800 ';'900 ';'1000';'1250';'1500';'1750';'2000']); 
numsizes=length(sizes);
for i=1:numsizes
    if(strcmp(string,sizes{i})==1)
        wireIndex=i;
    end
end
if(isdef(wireIndex==0))
    disp('undefined wire size');
end

