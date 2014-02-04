function [vd,leng,cost,misc] = ...
    convFindcostv3(numCB,wireIndex,minIndex,cbStrings,qH,qW,eleDim,CBqH,inputs)

addpath('Voltage Drop');
%% kW STC
modules=qH*2*qW*2*76; %total number of modules in array
misc.modulesW=modules*modPV.Imp*modPV.Vmp*(inv.num_inverters/4); % Total Power rating of array

%% Module to Combiner box
leng.wire.m2cb = 0;
[leng.wire.m2cb,longestm2cb1way] = stringRuns(qW,qH,eleDim.totW,eleDim.totH,numCB,eleDim.modality,CBqH);
cost.wire.m2cb = (leng.wire.m2cb) * (wirePriceCu(5) / 1000); % $/m times m = dollars

%% Combiner Box to Inverter
leng.wire.cb2inv = 0;
[longestcb2inv1way,leng.wire.cb2inv,qHleft] = aluminumRuns(numCB,qH,eleDim.totH,5); % total wire length north-south (meters)

[~,vd.stringmax] = voltDrop(longestm2cb1way,m2cbRes(5),modPV.Imp,modPV.Vmpmax); % VD of 10 gauge strings
[~,vd.cb2invmax] = voltDrop(longestcb2inv1way,cb2invRes(wireIndex),modPV.Imp*cbStrings,modPV.Vmpmax); % VD of chosen cb to inverter conductors
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

%% Length of Cable Tray

leng.CT.m2cb=((qW-1)*eleDim.totW*qH + ((CBqH-1) * eleDim.totH * numCB));
leng.CT.cb2inv = longestcb2inv1way;

%% Multiply Components for Entire Array

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
%% Multiply Components for Multiple arrays

leng.numCB=numCB*inv.num_inverters;
cost.wire.m2cb = cost.wire.m2cb*inv.num_inverters;
leng.wire.m2cb = leng.wire.m2cb*inv.num_inverters;
cost.wire.cb2inv = cost.wire.cb2inv *inv.num_inverters; % Top and bottom
leng.wire.cb2inv = leng.wire.cb2inv *inv.num_inverters; % Top and bottom
leng.CT.m2cb=leng.CT.m2cb*inv.num_inverters;
leng.CT.cb2inv = leng.CT.cb2inv*inv.num_inverters;

[cost] = ItemtoCostConversionConv(leng,inputs);