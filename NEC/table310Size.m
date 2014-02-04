function [minIndex]=table310Size(Table,type,Tc,deratedOCPD)%310.15(B)(20) 2011 NEC
%TABLE 310 SIZE finds the minimum conductor size given the input
%parameters.
%   [minIndex]=table310Size(table,type,Tc,deratedAmpacity)
%   table, Tc, type, tableIdentity, and condPerRaceway are all scalar values.
%   The description of the inputs are as follows:
%
%   Table is the table found in function 'table310Select' which is the 4x30
%   matrix of integers. This function simply selects a row based off of Tc
%   and type parameters as explained in the aformentioned function and
%   visable below and then finds the index of the row vector which it goes
%   from being larger to smaller. This is the allowable ampacity of the
%   conductor index. The index of conductor is translatable to the wire
%   size string through the 'sizesAWG.mat' cell array.
%   
%   Tc is the temperature rating of the conductor insulation.
%   90C, 75C, or 60C is used per the NEC.
%
%   type is the conductor type, accepts 'Al', 'Cu', 
%                                        0,  or 1  respectively.
%   deratedOCPD is what the Over Current Protection Device must be rated for, after derating effects have been applied.
%   Along with the over current protection device, the conductor must be
%   rated for this as well. This is the number which is looked up in the
%   table 310 chart, which is exactly what this function is doing.
%
%   See also VDresults, table310Select, getIndex, completeDerate, tempDerate.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   NEC related function.

%% Selects Row Vector
% Selects the row vector of the table which it is passed based off of the
% Material (type) and Temperature of Conductor (Tc)

if      (Tc==60 && (strcmp('Cu',type)==1 || type==1)) % Accepts 'Cu' or '1' and 60C
    row = Table(1,:);
elseif  (Tc==75 && (strcmp('Cu',type)==1 || type==1)) % Accepts 'Cu' or '1' and 75C
    row = Table(2,:);
elseif  (Tc==90 && (strcmp('Cu',type)==1 || type==1)) % Accepts 'Cu' or '1' and 90C
    row = Table(3,:);
elseif  (Tc==60 && (strcmp('Al',type)==1 || type==0)) % Accepts 'Al' or '1' and 60C
    row = Table(4,:);
elseif  (Tc==75 && (strcmp('Al',type)==1 || type==0)) % Accepts 'Al' or '1' and 75C
    row = Table(5,:);
elseif  (Tc==90 && (strcmp('Al',type)==1 || type==0)) % Accepts 'Al' or '1' and 90C
    row = Table(6,:);
end

%% finds indexes from vector
% Matches the deratedOCPD to an index found in the previous row vector,
% which becomes the minimum index

if (length(deratedOCPD)==1) % If not a vector
    if(row(30)<deratedOCPD)
        minIndex=NaN;
        return % Leave the function
    else % Since it is not larger than the largest number in the chart:
        for i=1:30 % Loop from the smallest index to the largest possible
            if(row(i)>=deratedOCPD) % if the index of the chart is now greater or equal to the derated OCPD, this is your minimum wire size.
                minIndex=i;
                break
            end
        end
    end
else % if deratedOCPD is a vector
    rowArray=ones(length(deratedOCPD),1)*row; %creates two equivalent matricies with the matrix being the same on the y axis and changing on the x axis for the first
    OCPDarray=(ones(length(row),1)*deratedOCPD)'; % and same on the x and changing on the y for the second. (I refer to x and y axis for better visualization)
    resultantArray=rowArray-OCPDarray; % finds the difference of the two arrays. this difference represents whether or not the over current protection is met.
    resultantArray(resultantArray<0)=1000; % if the value is below 0, this means that it is not met, so set the result to a high number so that it is not selected when looking for the minimum.
    [~,minIndex]=min(resultantArray,[],2); % finds the minimum indicies on the y axis which represent the minimum index of the conductors
    minIndex=minIndex'; % flip vector
end
