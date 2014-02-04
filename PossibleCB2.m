function [CB]=PossibleCB2(tablesPerHalf,maxAWG,CBtable)
%Combiner Box Works eliminates combiner box sizes which do not
%work for the given table sizes.
%   tablesPerQuad is a vector of the number of tables found in one quad.
%   CBworks is a struct which holds a couple parameters *UPDATE*
%   updated utilizing matrix multiplication rather than for loops the same as
%   'AlenconOptimizationv4.m'
%
%   See also 'AlenconOptimizationv4.m'


% CBINFO:
% row 1: #strings/CB
% row 2: maximum over current protection
% row 3: cost
global inv tableWOptim tableW modPV eleDim
optim=0;
CBInfo=cell2mat(CBtable(:,1:3))';

maxnumber_Trunks=8;
hWworks=[];
hHworks=[];
CBInfoWorks=[];
tablesWorks=[];
CBW=[];
CBH=[];
numberOfTrunks=[];

% Matrix multiplication 
i = tablesPerHalf; % vector of possible tables per Half of array(varies slightly)
p = 2:max(i); % vector from 1 to the maximum tables (represents possible hH)
q = i*(1./p); % matrix of the number of spots divided by hH (value represents hW)
remainder=mod(q,1); % finds which have an integer of hW by using modulus 1
inte=zeros(size(remainder)); % creates another matrix of this size to represent which are integers
inte(remainder==0)=1; % if there is a zero in remainder, there is now a 1 in the integer matrix
[x,y]=find(inte); % finds the x and y indicies for every 1 in the integer matrix. y represents hW and x represents i starting at the first values of the vector
hW=(y+1)'; % flips direction of y and rename it hW
hH=((x+min(i)-1)./hW')'; % x must be offset by the minimum i in the vector (min(i)-1) and then divided by hW to get hH
tables=(hH.*hW); % re-calculates tables per quad which is simply hH * hW
CBInfo(1,:)= floor(CBInfo(1,:)/4); % divides the size of the CB up by its symmetrical number of combiner boxes
for j=1:maxnumber_Trunks
    %% trunks per width
    CBhH=(CBInfo(1,:)')*(1./((hW)./j)); % gives the qH for each combiner box (CBhH) if used for that orientation
    integers=zeros(size(CBhH)); % creates matrix integers the same size as CBqh
    integers(mod(CBhH,1)==0)=1; % populates matrix with 1 where CBqH is an integer
    [tablesPerCBIndex,hWindex]=find(integers); % finds the x and y indecies for the integers,
    %x represents the tables per combiner boxes which works, while qW index is what qWs indecies work.
    %This is then used to find what the actual values of qH,qW, and the total number of tables can be.
    CBInfoWorks=horzcat(CBInfoWorks,CBInfo(:,tablesPerCBIndex));
    tablesWorks=horzcat(tablesWorks,tables(hWindex));
    hWworks=horzcat(hWworks,hW(hWindex)); 
    hHworks=horzcat(hHworks,hH(hWindex));
    numberOfTrunks=horzcat(numberOfTrunks,(ones(size(tablesPerCBIndex))*j)');
    CBW_trunk=hW(hWindex)./((ones(size(tablesPerCBIndex')))*j);
    CBW=horzcat(CBW,CBW_trunk); %this calculates the CBqh which is the number of elements per ONE combiner box.
    CBH=horzcat(CBH,(CBInfo(1,tablesPerCBIndex)./CBW_trunk)); %this calculates the CBhH which is the number of elements per ONE combiner box.
end
%qH is not always a multiple of CBqH, but this is taken care of in the rest
%of the code.
CB=vertcat(CBInfoWorks,tablesWorks,hWworks,hHworks,CBW,CBH,numberOfTrunks); % puts all of these values together.
CB(:,CB(8,:)==0.5)=[]; % deletes cases where quad width is too short
if optim==1
OCP=9.2...% Current Limit for Optimizers
    *1.25; % Over Current Protection 
elseif optim==0   
OCP=modPV.Isc...% Current Limit for Optimizers
    *1.25*1.25; % Over Current Protection 
end
if OCP<10
    fuseSize=10;
elseif OCP<12
    fuseSize=12;
elseif OCP<15
    fuseSize=15;
else
    fuseSize=20;
end
CB_Imp= CB(1,:)...% the number of tables 
    *4*fuseSize; % string per CB
minIndex = ampacityCheck(1,2,'15b17',CB_Imp); %finds smallest wire size allowed by conductor
tooMuchCurrent=zeros(size(minIndex)); % creates empty array
tooMuchCurrent(minIndex>maxAWG)=1; % populates empty array when minimum index too large
tooMuchCurrent(CB_Imp>CB(2,:))=1; % populates empty array when minimum index too large
minIndex(tooMuchCurrent==1)=[]; % 1 here means we cannot use this type of wire because it is larger than allowed
CB(:,tooMuchCurrent==1)=[]; % deletes cases where current would be too large
CB(:,minIndex==1)=[]; % deletes cases where current can not be accomodated by a particular wire size
minIndex(minIndex==1)=[]; % 1 here means wire does not exist (>2000kcmil) and cannot be accomodated
numCButilized=CB(5,:)./CB(1,:)*2*(inv.num_inverters/inv.perPad);
numCBinArray=ceil(CB(5,:)./CB(1,:))*2*(inv.num_inverters/inv.perPad);
if optim==1
arrayKW=CB(5,:)*tableWOptim*2*(inv.num_inverters/inv.perPad);
elseif optim==0
    arrayKW=CB(5,:)*tableW*2*(inv.num_inverters/inv.perPad);
end
stringsPerCB=CB(1,:)*4;
CB=vertcat(CB,minIndex,numCButilized,numCBinArray,stringsPerCB,arrayKW);
if eleDim.modality ==0
    CB(:,mod(CB(5,:)./CB(9,:),.5)~=0)=[];
else
    CB(:,mod(CB(5,:)./CB(9,:),.1)~=0)=[];
end

%% CB row description
% Tables per Combiner box
% maximum over current protection
% cost
% Tables per Half
% Tables for Half Width
% Tables for half Height
% Combiner Box width in Tables
% combiner box height in tables
% number of trunks
% Minimum Wire Size Index for Combiner Box conductor (1-30) 18AWG to
%   1500kcmi
% Number of Combiner Boxes Utilized (smaller if not all filled)
% Number of Combiner Boxes in array
% Strings per Combiner Boxes
% kW STC of the entire array

