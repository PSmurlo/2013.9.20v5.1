function [CB]=SAM_PossibleCB(qW,qH,vertical,maxAWG)
%SAM_POSSIBLECB eliminates combiner box sizes which do not
%work for the given table sizes.
%   tablesPerQuad is a vector of the number of tables found in one quad.
%   CBworks is a struct which holds a couple parameters *UPDATE*
%   updated utilizing matrix multiplication rather than for loops the same as
%   'AlenconOptimizationv4.m'
%
%   See also 'AlenconOptimizationv4.m'

global inv possibleCBsizes modPV tableW

% Matrix multiplication 
% i = qH.*qW; % vector of possible tables per quad
% p = 1:max(i); % vector from 1 to the maximum tables (represents possible qH)
% q = i'*(1./p); % matrix of the number of spots divided by qH (value represents qW)
% remainder=mod(q,1); % finds which have an integer of qW by using modulus 1
% inte=zeros(size(remainder)); % creates another matrix of this size to represent which are integers
% inte(remainder==0)=1; % if there is a zero in remainder, there is now a 1 in the integer matrix
% [x,y]=find(inte); % finds the x and y indicies for every 1 in the integer matrix. y represents qW and x represents i starting at the first values of the vector
% qW=y'; % flips direction of y and rename it qW
% qH=((x+min(i)-1)./y)'; % x must be offset by the minimum i in the vector (min(i)-1) and then divided by qW to get qH
tables=(qH.*qW); % tables per quad which is simply qH * qW
tablesPerCB=possibleCBsizes/8; % divides the size of the CB up by its symmetrical number of combiner boxes
if vertical ==1
    CBqH=(tablesPerCB')*(1./(qW*[1 1/2 1/3 1/4 1/5])); % gives the qH for each combiner box (CBqH) if used for that orientation
    integers=zeros(size(CBqH)); % creates matrix integers the same size as CBqh
    integers(mod(CBqH,1)==0)=1; % populates matrix with 1 where CBqH is an integer
elseif vertical ==0
    CBqW=(tablesPerCB')*(1./qH*[1 1/2 1/3 1/4 1/5]); % gives the qW for each combiner box (CBqW) if used for that orientation
    integers=zeros(size(CBqW)); % creates matrix integers the same size as CBqW
    integers(mod(CBqW,1)==0)=1; % populates matrix with 1 where CBqW is an integer
end
[tablesPerCBworks,CBqW]=find(integers); % finds the x and y indecies for the integers,
%x represents the tables per combiner boxes which works, while qW index is what qWs indecies work.
%This is then used to find what the actual values of qH,qW, and the total number of tables can be.
qWworks=qW(CBqW);
qHworks=qH(CBqW);
tablesWorks=tables(CBqW);
CBqHworks=tablesPerCBworks./qWworks'; %this calculates the CBqh which is the number of elements per ONE combiner box.
%qH is not always a multiple of CBqH, but this is taken care of in the rest
%of the code.
CB=vertcat(tablesPerCBworks',tablesWorks,qWworks,qHworks,CBqHworks'); % puts all of these values together.
CB_Imp= tablesPerCBworks' ...% the number of tables on one side (CBqH*qW)
    *2 ... %tables for both sides (E/W)
    *4* ...
    modPV.Isc*... % Current per string
    1.25*1.25; % Over Current Protection 
minIndex = ampacityCheck(1,2,'15b17',CB_Imp); %finds smallest wire size allowed by conductor
tooMuchCurrent=zeros(size(minIndex)); % creates empty array
CB(:,minIndex==1)=[]; % deletes cases where current can not be accomodated by a particular wire size
minIndex(minIndex==1)=[]; % 1 here means wire does not exist (>2000kcmil) and cannot be accomodated
tooMuchCurrent(minIndex>maxAWG)=1; % populates empty array when minimum index too large
minIndex(tooMuchCurrent==1)=[]; % 1 here means we cannot use this type of wire because it is larger than allowed
CB(:,tooMuchCurrent==1)=[]; % deletes cases where current would be too large
numCButilized=CB(2,:)./CB(1,:)*inv.num_inverters/2;
numCBinArray=ceil(CB(2,:)./CB(1,:))*inv.num_inverters/2;
arrayKW=CB(2,:)*tableW*inv.num_inverters;
stringsPerCB=CB(1,:)*8;
CB=vertcat(CB,minIndex,numCButilized,numCBinArray,stringsPerCB,arrayKW);

%% CB row description
% Tables per Combiner box
% Tables per Quad
% Tables for Quad Width
% Tables for Quad Height
% Combiner Box Height in Tables
% Minimum Wire Size Index for Combiner Box conductor (1-30) 18AWG to
%   1500kcmi
% Number of Combiner Boxes Utilized (smaller if not all filled)
% Number of Combiner Boxes in array
% Strings per Combiner Boxes
% kW STC of the entire array

