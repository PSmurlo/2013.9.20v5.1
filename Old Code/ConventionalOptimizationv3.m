function [finalData] = ConventionalOptimizationv3(inputs)
global modPV inv wirePriceCu wirePriceAl cb2invRes m2cbRes

% Wiring
element.string_orientation=0;           % 0=vertical, 1=horizontal

%% *** only Modality if statement ***
% Orientation
element.modality=0;                     % 0=portrait, 1=landscape

if element.modality ==0 % PORTRAIT
    eleDim.nmody=2;
    eleDim.nstrx=2;
else                    % LANDSCAPE
    eleDim.nmody=4;
    eleDim.nstrx=1;
end
%%
element.azimuth=180;                    % Azimuth, 0=N, 90=E, 180=S, 270=W
element.gap_spacing= .1;                % Spacing between modules


% Rack Dimensions
eleDim=rackDim(element,modPV);
eleDim.totH = 10;
eleDim.tilt = 30;

% Determine AC system size
ac_system_size=inv.paco*inv.num_inverters;
% Calculating the DC size of array
dc_system_size=inv.DC_AC.target*ac_system_size;
strings_parallel=floor(dc_system_size/(modPV.Vmp*modPV.Imp*modPV.mps));
dc_system_size=strings_parallel*(modPV.Vmp*modPV.Imp*modPV.mps);
% Determining number of tables

% table Watts
tableDCW=eleDim.modperTable*modPV.Imp*modPV.Vmp;
% required DC size
DCsize_quad=inv.pdco*inv.DC_AC.target;
tablesPerQuad=DCsize_quad/tableDCW;
eleDim.tablesPerQuad.Range=ceil(tablesPerQuad*(1-inv.DC_AC.variance)):floor(tablesPerQuad*(1+inv.DC_AC.variance));

CB=PossibleCB(eleDim.tablesPerQuad.Range);

%% Declarations
addpath('NEC');

%% max/mins
type=0; %0=AL, 1=cu
if(type==0)
    maxAWG=20;
else
    maxAWG=15;
end

%% Initializations
maxVD = 4;
maxCost = 8000000;
Isc = modPV.Isc;
Imax = Isc * 1.25;
OCPDs = Imax * 1.25;
n = 1;
finalData = [];

%% Main
for k = 1:numel(CB)
    for l = 1:numel(CB(k).Tables)
        %     m=cbStringsOutput(k == CB(k).num);
        %     CBqHi=CB(k).qH( k == CB(k).num);
        strings= CB(k).Strings(l);
        OCPDcb = OCPDs.*strings;
        CBwireIndex = ampacityCheck(1,2,'15b17',OCPDcb); %finds smallest wire size for configuration
        tables= CB(k).Tables(l);    % Number of tables in array
        CBqH= CB(k).CBqH(l);        % Height in tables of array for each combiner box
        numCB= CB(k).num(l);        % number of combiner boxes
        qH=CB(k).qH;
        qW=CB(k).qW;
        if minIndex >= maxAWG
            continue % If minimum wire size based on ampacity exceeds the largest possible available conductor
        end
        for m = minIndex:maxAWG %Size up this conductor up to the maximum allowable size
            if(qH/numCB >= mod(qH,numCB))
                
                addpath('Voltage Drop');
                
                % kW STC
                modules=qH*2*qW*2*76; %total number of modules in array
                misc.modulesW=modules*modPV.Imp*modPV.Vmp*(inv.num_inverters/4); % Total Power rating of array
                
                % Module to Combiner box
                leng.wire.m2cb = 0;
                [leng.wire.m2cb,longestm2cb1way] = stringRuns(qW,qH,eleDim.totW,eleDim.totH,numCB,eleDim.modality,CBqH);
                cost.wire.m2cb = (leng.wire.m2cb) * (wirePriceCu(5) / 1000); % $/m times m = dollars
                
                % Combiner Box to Inverter
                leng.wire.cb2inv = 0;
                [longestcb2inv1way,leng.wire.cb2inv,qHleft] = aluminumRuns(numCB,qH,eleDim.totH,5); % total wire length north-south (meters)
                
                [~,vd.stringmax] = voltDrop(longestm2cb1way,m2cbRes(5),modPV.Imp,modPV.Vmpmax); % VD of 10 gauge strings
                [~,vd.cb2invmax] = voltDrop(longestcb2inv1way,cb2invRes(CBwireIndex),modPV.Imp*cbStrings,modPV.Vmpmax); % VD of chosen cb to inverter conductors
                % downSizeRuns(leng.wire.cb2inv,vd.cb2invmax,cbStrings,minIndex,wireIndex,ampacityCheck(1,2,'15b17',modPV.Isc*1.25*1.25*qHleft*qW*4,2))
                for i=length(leng.wire.cb2inv):-1:1
                    trunkInfo(i,1)=leng.wire.cb2inv(i); % Length
                    if (i==1 && qHleft>0) % If the last combiner box is not full
                        minIndex = ampacityCheck(1,2,'15b17',modPV.Isc*1.25*1.25*qHleft*qW*4,2);
                    end
                    for j= minIndex:wireIndex
                        [~,VDj] = voltDrop(trunkInfo(i,1),cb2invRes(j),modPV.Imp*cbStrings,modPV.Vmpmax); % Volt drop% check
                        if (VDj > vd.cb2invmax) % if the voltage drop is higher than the max continue loop
                            continue
                        elseif(VDj <= vd.cb2invmax)
                            trunkInfo(i,2)=j;   % Wire Size Index
                            trunkInfo(i,3)=VDj; % Voltage Drop
                            trunkInfo(i,4)=trunkInfo(i,1)*(wirePriceAl(j))/1000*2; %Cost
                            %             indexLength(1,j)=indexLength(1,j)+leng.wire.cb2inv(i);
                            trunkInfo(i,5)=minIndex;
                            
                            break
                        end
                    end
                end
                vd.max = vd.stringmax + vd.cb2invmax;
                cost.wire.cb2inv = sum(trunkInfo(:,4));
                %% Power Loss
                % sImpHourly=modPV.dc_current.^2;
                % cbImpHourly=(modPV.dc_current*cbStrings).^2;
                % sResAvg=(m2cbRes/1000*leng.wire.m2cb);
                % cbResAvg=cb2invRes/1000*leng.wire.cb2inv;
                % kwhLoss.m2cb=sum(sImpHourly*sResAvg/1000);
                % kwhLoss.cb2inv=sum(cbImpHourly*cbResAvg/1000);
                % degredation=linspace(1,.8,25);
                % kwhLoss.total=sum(kwhLoss.cb2inv+kwhLoss.m2cb.*degredation);
                
                % Length of Cable Tray
                
                leng.CT.m2cb=((qW-1)*eleDim.totW*qH + ((CBqH-1) * eleDim.totH * numCB));
                leng.CT.cb2inv = longestcb2inv1way;
                
                % Multiply Components for Entire Array
                
                %top/bottom
                numCB=numCB*2;
                cost.wire.cb2inv = cost.wire.cb2inv *2; % Top and bottom
                leng.wire.cb2inv = leng.wire.cb2inv *2;
                leng.CT.cb2inv = leng.CT.cb2inv*2;
                
                %per quad
                % misc.modulesW=misc.modulesW*4;
                cost.wire.m2cb = cost.wire.m2cb * 4;
                leng.wire.m2cb = leng.wire.m2cb * 4;
                leng.CT.m2cb=leng.CT.m2cb*4;
                % Multiply Components for Multiple arrays
                
                leng.numCB=numCB*inv.num_inverters;
                cost.wire.m2cb = cost.wire.m2cb*inv.num_inverters;
                leng.wire.m2cb = leng.wire.m2cb*inv.num_inverters;
                cost.wire.cb2inv = cost.wire.cb2inv *inv.num_inverters; % Top and bottom
                leng.wire.cb2inv = leng.wire.cb2inv *inv.num_inverters; % Top and bottom
                leng.CT.m2cb=leng.CT.m2cb*inv.num_inverters;
                leng.CT.cb2inv = leng.CT.cb2inv*inv.num_inverters;
                
                [cost] = ItemtoCostConversionConv(leng,inputs);
                
                
            end
        end
    end
end

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

%                 [vd(n),leng(n),cost(n),misc(n)] = convFindcostv3(ceil(numCB),m,minIndex,strings,qH,qW,eleDim,CBqH,inv,inputs); %main calculation function
%                 if (vd(n).max < maxVD) && (cost(n).total < maxCost)
%                     extraData = horzcat(cost(n).total,...       % Cost of total system ($)
%                         vd(n).max,...                           % Maximum voltage drop (%VD)
%                         cost(n).total/misc(n).modulesW,...      % Dollars per Watt ($/W)
%                         cost(n).wire.total,...                  % Cost of Conductors
%                         cost(n).CT.raw,...                      % Cost of tray
%                         cost(n).labor.total,...                 % Cost of Labor
%                         leng(n).wire.m2cb,...                   % Length of #10
%                         2*sum(leng(n).wire.cb2inv),...          % Length of Trunk
%                         qH*2,...                                % Array height in tables
%                         qW*2,...                                % Array width in tables
%                         numCB,...                               % Number of combiner Boxes
%                         cost(n).CB.raw,...                      % Cost of CB
%                         cost(n).inverter,...                    % Cost of Inverter
%                         m);                                 	% Size of Trunk
%                     finalData = vertcat(finalData,extraData);
%
%                     n = n + 1;
%                 else
%                     vd(n) = [];
%                     cost(n) = [];
%                     misc(n) = [];
%                     leng(n) =[];
%                 end
