function [vd,leng,cost,misc] = ...
    convFindcostv2(x,qH,qW,modPV,eleDim,CBqH,inv,inputs)

%% Tables
load('wirePriceFt.mat');
addpath('Voltage Drop');
wirePriceCu = wirePriceFtCu * 3.28; % dollars per kilometer
wirePriceAl = wirePriceFtAl * 3.28; % dollars per kilometer

%% Input Arguments
numCB = x(1);
wireIndex = x(2);
minIndex = x(3);
cbStrings = x(4);

%% Inverter Cost
ACdollarPerWatt=.3;
cost.inverter=inv.paco*inv.num_inverters*ACdollarPerWatt;
num_inverters=inv.num_inverters/4; %4 per skid

% dimensionIndex = x(4);
%cbStrings = cbInfo(7,x(1));

%% Required Array Information
Imp = modPV.Imp;
Vmpmax= modPV.vmpmax; % nominal Voltage of module
totH = eleDim.totH;
totW = eleDim.totW;
% wire_l= eleDim.wire_l; % only used for Alencon

Tc = 75; % conductor rating
%% kW STC
modules=qH*qW*eleDim.modperTable; %total number of modules in array
misc.modulesW=modules*modPV.Imp*modPV.Vmp; % Total Power rating of array

%% Module to Combiner box
leng.wire.m2cb = 0;
m2cbRes = resist(Tc,'Cu',5); % calculates resistance based on conductor rating for 10 gauge
[leng.wire.m2cb,longestm2cb1way] = stringRuns(qW,qH,totW,totH,numCB,eleDim.modality,CBqH);
cost.wire.m2cb = (leng.wire.m2cb) * (wirePriceCu(5) / 1000); % $/m times m = dollars

%% Combiner Box to Inverter
leng.wire.cb2inv = 0;
cb2invRes = resist(Tc,'Al');
[longestcb2inv1way,leng.wire.cb2inv,qHleft] = aluminumRuns(numCB,qH,totH,5); % total wire length north-south (meters)

% Downsize shorter runs
[~,vd.stringmax] = voltdrop(longestm2cb1way,m2cbRes,Imp,Vmpmax); % VD of 10 gauge strings
[~,vd.cb2invmax] = voltdrop(max(leng.wire.cb2inv),cb2invRes(wireIndex),Imp*cbStrings,Vmpmax); % VD of chosen cb to inverter conductors
for i=1:length(leng.wire.cb2inv)
    for j= minIndex:wireIndex
        trunkInfo(i,1)=leng.wire.cb2inv(i);
        [~,VDcheck] = voltdrop(trunkInfo(i,1),cb2invRes(j),Imp*cbStrings,Vmpmax);
        if (VDcheck>vd.cb2invmax && j ~= minIndex)
            trunkInfo(i,2)=j-1;
%             if(wirePriceAl(j-1)>1000000)
%                 continue
%             end
            [~,VD] = voltdrop(trunkInfo(i,1),cb2invRes(j-1),Imp*cbStrings,Vmpmax);
            trunkInfo(i,3)=VD;
            trunkInfo(i,4)=trunkInfo(i,1)*(wirePriceAl(j-1)/1000)*2;
        elseif(VDcheck <= vd.cb2invmax || j== minIndex)
%             if(wirePriceAl(j)>1000000)
%                 continue
%             end
            trunkInfo(i,2)=j;
            trunkInfo(i,3)=VDcheck;
            trunkInfo(i,4)=trunkInfo(i,1)*(wirePriceAl(j))/1000*2;
        end
    end
end
vd.max = vd.stringmax + vd.cb2invmax;
cost.wire.cb2inv.total = sum(trunkInfo(:,4));
% CB_leftover = ampacity_check(modPV.Ta,Tc,0,'15b17',modPV.Isc*1.25*1.25*qHleft*qW*eleDim.modperTable*2,2);
%% Power Loss
% sImpHourly=modPV.dc_current.^2;
% cbImpHourly=(modPV.dc_current*cbStrings).^2;
% sResAvg=(m2cbRes/1000*leng.wire.m2cb);
% cbResAvg=cb2invRes/1000*leng.wire.cb2inv;
% kwhLoss.m2cb=sum(sImpHourly*sResAvg/1000);
% kwhLoss.cb2inv=sum(cbImpHourly*cbResAvg/1000);
% degredation=linspace(1,.8,25);
% kwhLoss.total=sum(kwhLoss.cb2inv+kwhLoss.m2cb.*degredation);

%% Cost of Conductor
cost.wire.total= cost.wire.m2cb +cost.wire.cb2inv.total;

%% Length of Cable Tray

leng.CT.m2cb=((qW-1)*totW*qH + ((qH-1) * totH));
leng.CT.cb2inv = longestcb2inv1way;

%% Multiply Components for Entire Array

%top/bottom
numCB=numCB*2;
leng.wire.cb2inv = leng.wire.cb2inv *2; % Top and bottom
leng.CT.cb2inv = leng.CT.cb2inv*2;

%per quad
misc.modulesW=misc.modulesW*4;
leng.wire.m2cb = leng.wire.m2cb * 4;
leng.CT.m2cb=leng.CT.m2cb*4;
%% Multiply Components for Multiple arrays

numCB=numCB*num_inverters;
leng.wire.cb2inv = leng.wire.cb2inv*num_inverters; % Top and bottom
leng.CT.cb2inv = leng.CT.cb2inv*num_inverters;
leng.wire.m2cb = leng.wire.m2cb*num_inverters;
leng.CT.m2cb=leng.CT.m2cb*num_inverters;

%% Cost of Combiner Box
cost.CB.item = numCB * inputs.costs.raw.cbs;

%% Cost of Combiner Box Labor
cost.CB.labor = numCB * inputs.costs.labor.cbs;
cost.CB.total = cost.CB.item+cost.CB.labor;

%% Cost of Cable Tray
cost.CT.cb2inv= leng.CT.cb2inv*inputs.costs.raw.cb2invtray;
cost.CT.m2cb = leng.CT.m2cb*inputs.costs.raw.m2cbtray;
cost.CT.total = cost.CT.cb2inv+cost.CT.m2cb;

%% Cost of Cable Tray/Conductor Labor
cost.labor.CTwire.cb2inv = (2*sum(leng.wire.cb2inv) * inputs.costs.labor.cb2inv) + ...
                           (2*sum(leng.wire.cb2inv) * inputs.costs.labor.cb2invtray);
cost.labor.CTwire.m2cb = (leng.wire.m2cb * inputs.costs.labor.m2cb) + ...
                         (leng.wire.m2cb * inputs.costs.labor.m2cbtray);
cost.labor.CTwire.total=cost.labor.CTwire.m2cb + cost.labor.CTwire.cb2inv;

%% Totals
cost.labor.total= cost.labor.CTwire.total + cost.CB.labor;
cost.cnt= cost.CT.total+cost.wire.total;
cost.total= cost.labor.total + cost.CT.total +cost.CB.item + cost.wire.total +cost.inverter;

%% Outputs as Structs
conductor.size = wireIndex;

misc.table.height = totH;
misc.table.width = totW;
misc.table.number= totH*totW;
misc.cb = numCB;
misc.cbstrings = cbStrings;
misc.quad.height = qH;
misc.quad.width = qW;
