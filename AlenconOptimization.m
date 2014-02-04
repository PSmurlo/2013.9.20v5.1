function [finalData] = AlenconOptimization(handles)
%ALENCONOPTIMIZATIONV4 Optimizes the Alencon Systems Inc. Inverter system
%   [finalData] = AlenconOptimizationv4() determines the finalData through
%   global variables which are changed in the GUI.
%
%   See also CONVENTIONALOPTIMIZATIONV4
%#ok<*AGROW>


addpath ('NEC','Voltage Drop');
global modPV eleDim type prefab internal

global tableW corner

global xLim yLim

global m2spotRes spot2prefabRes prefabRes trunk2gripRes

global priceString alenconPriceTrunk


totW=eleDim.totW;
totH=eleDim.totH;
finalData=[];
% maximum Copper wire size

if type(2,3)==1
    maxAWG=20; %500kcmil
elseif type(2,3)==0
    maxAWG=20; %500kcmil
end

% Sizing DC side of array
% info.mps= floor(1000/(modPV.Voc-(modPV.beta_oc*(25-Tmin)))); % Module Per String
% misc.tables=(ACsystemSize/4)/(modPV.Vmp*modPV.Imp*info.mps*4/inv.DC_AC.target); %do not use tables
% SPOTsPerQuad=ceil(misc.tables*(1-inv.DC_AC.variance)):floor(misc.tables*(1+inv.DC_AC.variance));
SPOTs=str2double(get(handles.listSPOTs,'String'))/4;

% Matrix multiplication
m = SPOTs; % vector of possible tables per quad (varies slightly)
p = 1:max(m); % vector from 1 to the maximum tables (represents possible qH)
q = m*(1./p); % matrix of the number of spots divided by qH (value represents qW)
remainder=mod(q,1); % finds which have an integer of qW by using modulus 1
inte=zeros(size(remainder)); % creates another matrix of this size to represent which are integers
inte(remainder==0)=1; % if there is a zero in remainder, there is now a 1 in the integer matrix
[x,y]=find(inte); % finds the x and y indicies for every 1 in the integer matrix. y represents qW and x represents m starting at the first values of the vector
qW=y'; % flips direction of y and rename it qW
qH=((x+min(m)-1)./y)'; % x must be offset by the minimum m in the vector (min(m)-1) and then divided by qW to get qH
SPOTs=(qH.*qW); % SPOTS per quad which is simply qH * qW
possibleDim = vertcat(qH,qW,SPOTs); % concatenates the results together for visual verification

swap=@(varargin)varargin{nargin:-1:1}; % anonymous function to do swapping operation
if prefab.dir==1 % Vertical=1
    [totH,totW] = swap(totH,totW);
end
%% Swapping totW and totH for vertical/horizontal prefab explination
% All calculations can remain the same if the only changes are the frame of
% reference is changed by 90 degrees and the dimensions of a table is
% reversed. This way, what is actually vertical is still going horizontally
% and the calculations can remain the same.

%%
% Remove incorrect dimensions.
spotcurrent=str2double(get(handles.textSpotkW,'String'))*1000/2500;
OCPD = (qW*prefab.spotPer)*1.25*1.25*spotcurrent;
minIndex = ampacityCheck(2,3,'15b17',OCPD);
% Calculates the minimum conductor sizes for each of these conductors, has
% been modified to work with vectors (see 'table310Size').
SPOTs(minIndex==1)=[];
SPOTs(minIndex>maxAWG)=[];
qW(minIndex==1)=[];
qW(minIndex>maxAWG)=[];
qH(minIndex==1)=[];
qH(minIndex>maxAWG)=[];
minIndex(minIndex==1)=[];
minIndex(minIndex>maxAWG)=[];

% remove uneven array configurations if multiple spots per prefab
SPOTs(mod(qH,prefab.spotPer)>0)=[]; %qH cannot be 1 if SPOTperPrefab==2
qW(mod(qH,prefab.spotPer)>0)=[];
minIndex(mod(qH,prefab.spotPer)>0)=[];
qH(mod(qH,prefab.spotPer)>0)=[];

% Iterates through all possible array sizes
for j = 1:length(minIndex)
    % no indexes used in rest of code, placed in structs for improved
    % portability
    raw.qH= qH(j);
    raw.qW= qW(j);
    raw.SPOTs = SPOTs(j)*4; % Per Array
    % DC Power
    totalW=tableW*raw.SPOTs;
    
    %% SPOT to Prefab wire length (can do 1 and all even numbers)
    % Branch connectors with in-line fusing required
    %distance from SPOT to ground or trench
    SPOTverticalLength=2;
    %Location corresponding to where the junction will be made
    if prefab.spotPer==2
        if corner==1
            spot2prefab=SPOTverticalLength*prefab.spotPer;
        else
            if prefab.dir==1 % Vertical
                spot2prefab=...
                    (2*SPOTverticalLength)+... % up and down
                    totH/2;
            else
                spot2prefab=...
                    (2*SPOTverticalLength)+... % up and down
                    totW/2;
            end
        end
    elseif prefab.spotPer==1
        spot2prefab=SPOTverticalLength*prefab.spotPer;   
    end
    raw.wire.spot2prefab=spot2prefab*(raw.SPOTs/4);
    raw.wire.spot2prefab=spot2prefab*4;
    raw.wire.spot2prefab=spot2prefab*2;
    
    %Other way of doing it for more spots per prefab
    % qHprefabLoc=(floor(prefab.spotPer)/2);
    % n=qHprefabLoc-1;
    % if mod(prefab.spotPer,2)==0 % Even
    %     % Relationship can be explained
    %     raw.wire.spot2prefab=(totH*n^2)+SPOTverticalLength*(prefab.spotPer); % one way length
    % elseif mod(prefab.spotPer,2)>0 %Odd
    %     % Relationship can be explained
    %     raw.wire.spot2prefab=(totH*(n^2)-n)++SPOTverticalLength*(prefab.spotPer); % one way length
    % end
    
    %% Prefab Wire Length
    
    if corner==1
        raw.longestPrefabRun = totW*(raw.qW-1); % Longest run possible from SPOT to main cable tray
    else
        raw.longestPrefabRun = totW*(raw.qW-0.5); % Longest run possible from SPOT to main cable tray
    end
    
    raw.number.prefabs = raw.qH/prefab.spotPer; % one run per two table widths
    raw.number.prefabs = raw.number.prefabs*2; % all runs make longest possible run, x2 for 2 runs per length
    raw.number.prefabs = raw.number.prefabs*4; % total wire length spots to tray in all rows (meters)
    raw.wire.prefab=raw.number.prefabs*raw.longestPrefabRun;
    %% Trunk Wire Length
    % main cable tray to GrIP
    
    if(prefab.spotPer==1)
        trunkLength = ((0:raw.qH-1)*totH)+eleDim.array2Inverter;
        raw.number.trunk=length(trunkLength);
    elseif(prefab.spotPer==2)
        trunkLength = ((1:2:raw.qH-1)*totH)+eleDim.array2Inverter;
        raw.number.trunk=length(trunkLength);
    end
    %     elseif(mod(raw.qH,2)==0) % even
    %         trunkLength = 1:prefab.spotPer:raw.qH; % Runs per quad at increasing lengths
    %     else % odd
    %         trunkLength = prefab.spotPer:prefab.spotPer:raw.qH; % Runs per quad at increasing lengths
    %     end
    
    raw.number.trunk = raw.number.trunk*2; % 2 lengths per run, runs are summed
    raw.number.trunk=  raw.number.trunk*4; % multiplied by number of quad
    
    if raw.number.trunk~=raw.number.prefabs
        disp('#trunk not equal to #prefab runs') % error check
    end
    
    raw.wire.trunk2grip=sum(trunkLength)*2*4; % total trunk length
    
    % raw.longestTrunk2GripRun = totW * (raw.qW-1); % CT length for trunk
    % put conditional break point that looks like this:
    % raw.qH== 5 && raw.qW==10 && prefab.dir==1 &&
    % prefab.spotPer==2
    
    % Iterates through possible wire sizes
    for k = minIndex(j):maxAWG
        
        % Find cost with cost inputs and raw cost
        raw.index=k;
        
        if get(handles.kWh_DPW,'Value')
            % kWh Loss
            kWhLoss=kWhLossFuncAlencon(handles,raw);
            vd.max =0;
        else
            % Volt Drop
            
            [~,vd.m2spot] = voltDrop(       internal/4,    m2spotRes(5),      modPV.Imp,  modPV.Vmpmax); % string to spot %
            [~,vd.spot2prefab] = voltDrop(  spot2prefab*2,              spot2prefabRes(5), spotcurrent,          2500);              % spot to end of table
            [~,vd.prefab] = spotVoltDrop(   totW,    prefabRes(raw.index),   spotcurrent,          2500, raw.qW);    % VD spot to tray
            [~,vd.trunk2grip] = voltDrop(   max(trunkLength)*2,   trunk2gripRes(raw.index),  spotcurrent*prefab.spotPer*raw.qW, 2500);              % VD tray to inverter
            vd.max = vd.m2spot + vd.spot2prefab + vd.prefab + vd.trunk2grip;
            kWhLoss.lifecycleTotal=0;
        end
        
        %% Populate GUI table
        [cost] = RawtoCostConversionAlencon(raw,handles);
        
        % Declare axes values
        if get(handles.VD_DPW,'Value')==1
            yAxis=vd.max;
            xAxis=cost.total/totalW;
        else
            yAxis=kWhLoss.lifecycleTotal;
            xAxis=cost.total/totalW;
        end
        
        % Determine whether data fits within axes
        if (yAxis < yLim(2)) & (xAxis < xLim(2)) & (yAxis > yLim(1)) & (xAxis > xLim(1)) % Save result if below max voltage drop and max cost            
            [~,tableData] = finalDataExtract(handles,cost,raw,vd,kWhLoss);
            finalData=vertcat(finalData,tableData);
        end
        clear cost vd
    end
end