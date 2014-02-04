function [finalData] = SAM_Conventional()
%CONVENTIONALOPTIMIZATIONV4 Optimizes a conventional central Inverter system
%   [finalData] = ConventionalOptimizationv4() determines the finalData through
%   global variables which are changed in the GUI.
%
%   See also ALENCONOPTIMIZATIONV4, CONVENTIONALOPTIMIZATIONV4

global modPV inv eleDim % both in Alencon as well
global tableW type Tc 
global usingSSC

% Conventional
global m2cbRes % Module to Combiner box Resistance
m2cbRes = resistLookup(Tc(1,1),type(1,1));
global cb2invRes % Combiner Box to Inverter Resistance
cb2invRes = resistLookup(Tc(1,2),type(1,2));

addpath('NEC');
finalData=[];

% required DC size
DCsize_quad=inv.pdco*inv.DC_AC.target;
tablesPerQuad=DCsize_quad/tableW;
eleDim.tablesPerQuad.Range=ceil(tablesPerQuad*(1-inv.DC_AC.variance)):floor(tablesPerQuad*(1+inv.DC_AC.variance));

if( type(1,2)==0)% Conventional trunk
    maxAWG=20; % Al
else
    maxAWG=17; % Cu
end

% Find all information about combiner box layouts
CB=PossibleCB1(eleDim.tablesPerQuad.Range,maxAWG);
for i= 1:length(CB)
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
    info.tablePerCB=CB(1,i);
    info.tablePerQuad=CB(2,i);
    info.qW=CB(3,i);
    info.qH=CB(4,i);
    info.CBqH=CB(5,i);
    info.CBminIndex=CB(6,i);
    info.numCButilized=CB(7,i);
    info.numCB=CB(8,i);
    info.stringsPerCB=CB(9,i);
    info.kWSTCarray=CB(10,i);
    
      
    for m = info.CBminIndex:maxAWG %Size up this conductor up to the maximum allowable size
%         if(info.qH/(info.numCB*2/inv.num_inverters) >= mod(info.qH,(info.numCB*2/inv.num_inverters)))
            
            info.index=m; % throw index into struct for portability
            
            % number of combiner boxes is both information about array and a raw part
            raw.numCB=info.numCB;
            %% Raw amounts
            % Module to Combiner box
            [raw.wire.m2cb,longestm2cb1way] = stringRuns(info.qW,info.qH,eleDim.totW,eleDim.totH,info.numCB,eleDim.modality,info.CBqH);
            
            % Combiner Box to Inverter
            [longestcb2inv1way,raw.wire.cb2inv,qHleft] = aluminumRuns(info.qH,eleDim.totH,info.CBqH,5); % total wire length north-south (meters)
            
            % Cable tray
            raw.CT.m2cb=((info.qW-1)*eleDim.totW*info.qH + ((info.CBqH-1) * eleDim.totH * info.numCB));
            raw.CT.cb2inv = longestcb2inv1way;
            
            [~,vd.stringmax] = voltDrop(longestm2cb1way,    m2cbRes(5),             modPV.Imp,                  modPV.Vmpmax); % VD of 10 gauge strings
            [~,vd.cb2invmax] = voltDrop(longestcb2inv1way,  cb2invRes(info.index),  modPV.Imp*info.stringsPerCB,modPV.Vmpmax); % VD of chosen cb to inverter conductors
            vd.max = vd.stringmax + vd.cb2invmax; %Total MAX VD
            
            [trunkInfo] = downSizeRuns(raw.wire.cb2inv,vd.cb2invmax,info.stringsPerCB,info.CBminIndex,maxAWG,ampacityCheck(1,2,'15b17',modPV.Isc*1.25*1.25*qHleft*info.qW*4),qHleft);
            
            if usingSSC ==1
                sImpHourly = modPV.dc_current.^2; %hourly curent for strings (s)
                cbImpHourly = (modPV.dc_current*info.stringsPerCB).^2; % hourly current for combiner boxes (cb)
                if qHleft>0
                    cbLeftoverImpHourly=(modPV.dc_current*(qHleft*info.qW*4));
                    cbLeftoverRes = trunkInfo(1,7);
                    kWhLoss.cb2invLeftover=sum(cbLeftoverImpHourly*2*cbLeftoverRes/1000);
                    trunkInfo(1,7)=0;
                else
                    kWhLoss.cb2invLeftover=0;
                end
                sResTotal = m2cbRes(5)/1000*raw.wire.m2cb; % resistance of total string wire length
                cbRes = sum(trunkInfo(:,7)); % resistance of total Combiner box length
                kWhLoss.m2cb = sum(sImpHourly*sResTotal/1000); % loss of run from module to combiner box for one year
                kWhLoss.cb2inv = sum(cbImpHourly*cbRes/1000); % loss of run from combiner box to inverter for one year
                kWhLoss.total = sum(kWhLoss.cb2inv+kWhLoss.m2cb+kWhLoss.cb2invLeftover); % total losses for 25 years assuming degredation
                degredation = linspace(1,.8,25); % degredation assumed from year 1 to 25
                kWhLoss.lifecycle=sum(kWhLoss.total*degredation);
            else
                kWhLoss.lifecycle=0;
            end
            
            [cost,raw] = ItemtoCostConversionConv(raw,trunkInfo(:,4));
            if 
            [~,tableData] = finalDataExtract(cost,raw,vd,kWhLoss,info);
            finalData=vertcat(finalData,tableData);
            clear cost raw vd
%         end
        
    end
    clear info
end


%                 for i=length(raw.wire.cb2inv):-1:1
%                     trunkInfo(i,1)=raw.wire.cb2inv(i); % Length
%                     if (i==1 && qHleft>0) % If the last combiner box is not full
%                         CBminIndex = ampacityCheck(1,2,'15b17',modPV.Isc*1.25*1.25*qHleft*qW*4,2);
%                     end
%                     for j= CBminIndex:maxAWG
%                         [~,VDj] = voltDrop(trunkInfo(i,1),cb2invRes(j),modPV.Imp*strings,modPV.Vmpmax); % Volt drop% check
%                         if (VDj > vd.cb2invmax) % if the voltage drop is higher than the max continue loop
%                             continue
%                         elseif(VDj <= vd.cb2invmax)
%                             trunkInfo(i,2)=j;   % Wire Size Index
%                             trunkInfo(i,3)=VDj; % Voltage Drop
%                             trunkInfo(i,4)=trunkInfo(i,1)*(wirePriceAl(j))/1000*2; %Cost
%                             %             indexLength(1,j)=indexLength(1,j)+raw.wire.cb2inv(i);
%                             trunkInfo(i,5)=CBminIndex;
%
%                             break
%                         end
%                     end
%                 end
%% Power Loss
% sImpHourly=modPV.dc_current.^2;
% cbImpHourly=(modPV.dc_current*cbStrings).^2;
% sResAvg=(m2cbRes/1000*raw.wire.m2cb);
% cbResAvg=cb2invRes/1000*raw.wire.cb2inv;
% kwhLoss.m2cb=sum(sImpHourly*sResAvg/1000);
% kwhLoss.cb2inv=sum(cbImpHourly*cbResAvg/1000);
% degredation=linspace(1,.8,25);
% kwhLoss.total=sum(kwhLoss.cb2inv+kwhLoss.m2cb.*degredation);

% Length of Cable Tray
%                     if (vd.max < maxVD) && (cost.total < maxCost)
%                     extraData = horzcat(cost.total,...       % Cost of total system ($)
%                         vd.max,...                           % Maximum voltage drop (%VD)
%                         cost.total/misc.modulesW,...      % Dollars per Watt ($/W)
%                         cost.wire.total,...                  % Cost of Conductors
%                         cost.CT.raw,...                      % Cost of tray
%                         cost.labor.total,...                 % Cost of Labor
%                         raw.wire.m2cb,...                   % Length of #10
%                         2*sum(raw.wire.cb2inv),...          % Length of Trunk
%                         qH*2,...                                % Array height in tables
%                         qW*2,...                                % Array width in tables
%                         numCB,...                               % Number of combiner Boxes
%                         cost.CB.raw,...                      % Cost of CB
%                         cost.inverter,...                    % Cost of Inverter
%                         m);                                 	% Size of Trunk
%                     finalData = vertcat(finalData,extraData);
%                 end

% pointlabels = {'Total System Cost','Voltage Drop','$/W','kWh Loss','Quad Height','Quad Width','Tables per Quad','CB Size in Tables','CBs Installed','CBs Utilized','Trunk Wire Index','Length of Trunk runs','String runs total'};
% finalData = horzcat(cost',vd',dpw',kwhLoss',finalData);
% finalData = sortrows(finalData,1);
% finalCell = vertcat(pointlabels,num2cell(finalData));


% bestVals = [(finalData(1,1)^2) + (finalData(1,2)^2),1]; % distance to zero of first index

% loop checks all the possibilities for the closest one to (0,0)
% for i = 2:(size(x,2))
%     nextVals = [(finalData(i,1)^2) + (finalData(i,2)^2),i];
%     if nextVals(1) < bestVals(1)
%         bestVals = nextVals;
%     end
% end

% if(plotEnable==1)
%
%     % kWh vs %VD
%     fh0 = figure;
%     title('DC power loss vs Voltage drop');
%     scatter(kwh,y,'x');
%     grid
%     xlabel('kWh loss over 25 years');
%     ylabel('Max Volt Drop');
%     ylim([0,maxVD]);
%
%     dcm0 = datacursormode(fh0);
%     datacursormode on
%     set(dcm0, 'updatefcn', @PVDatatipCursorKWH);

% $/w vs %VD
%     figure;
%     suptitle('Conventional DC Side');
%     scatter(finalData(:,3),finalData(:,2),'x');
%     grid
%     xlabel('$/W of all X-Y components');
%     ylabel('Max Volt Drop');
%     ylim([0,maxVD]);
%     dcm = datacursormode(fh);
%     datacursormode on
%     set(dcm, 'updatefcn', @PVDatatipCursor);
% end
%
%
%
% % q = bestVals(2);
% % X = [finalData(q,3),finalData(q,4),finalData(q,5)];
% % [totalConductorCost,VDmax,~,~,totalWire,numTables,CB.num,cbStrings, ...
% %     tableW,tableH,qW,qH,totalCost] = ...
% %     newPvConvFunction(X);
% %
% % figure;
% % pvFarmDraw(0,0,tableW,tableH,qH,qW,1.996,0.994,4,19);
%

%% Code from for loop


