function [vd,leng,cost,misc] = ...
    convFindCost(x,qH,qW,modPV,eleDim,CBqH,inv)

%% Tables

load('wirePriceFt.mat');
addpath('Voltage Drop');
wirePriceCu = wirePriceFtCu * 3.28; % dollars per kilometer
wirePriceAl = wirePriceFtAl * 3.28; % dollars per kilometer

%% Input Arguments
numCB = x(1);
wireIndex = x(2);
cbStrings = x(3);

ACdollarPerWatt=.3;
cost.inverter=inv.paco*inv.num_inverters*ACdollarPerWatt;
num_inverters=inv.num_inverters/4; %4 per skid

% dimensionIndex = x(4);
%cbStrings = cbInfo(7,x(1));

%% Declarations for using SUE
Imp = modPV.Imp;
Vmpmax= modPV.vmpmax;
totH = eleDim.totH;
totW = eleDim.totW;
% wire_l= eleDim.wire_l; % only used for Alencon

Tc = 75; % conductor rating
%% kW STC
modules=qH*qW*eleDim.modperTable;
misc.modulesW=modules*modPV.Imp*modPV.Vmp;

%% Length of Conductor
leng.wire.m2cb = 0;
leng.wire.cb2inv = 0;

% Module to Combiner Box
[leng.wire.m2cb,longestm2cb1way] = stringRuns(qW,qH,totW,totH,numCB,eleDim.modality,CBqH);
% Combiner box to Inverter
[leng.wire.cb2inv,longestcb2inv1way,qHleft] = aluminumRuns(numCB,qH,totH,5); % total wire length north-south (meters)

%% Length of Cable Tray

leng.CT.m2cb=((qW-1)*totW*qH*4 + ((qH-1) * totH * 4));
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


%% Cost of Conductor
cost.wire.m2cb = (leng.wire.m2cb) * (wirePriceCu(5) / 1000); % $/m times m = dollars
cost.wire.cb2inv = (leng.wire.cb2inv) * (wirePriceAl(wireIndex) / 1000);
cost.wire.total= cost.wire.m2cb +cost.wire.cb2inv;

%% Resistance
m2cbRes = resist(Tc,'Cu',5); % calculates resistance based on conductor rating for 10 gauge
cb2invRes = resist(Tc,'Al',wireIndex); % chooses the correct resistance for that conductor

%% Cost of Combiner Box
cost.CB.item = numCB * 1500;

%% Cost of Combiner Box Labor
cost.CB.labor = numCB * 500;
cost.CB.total = cost.CB.item+cost.CB.labor;

%% Cost of Cable Tray
cost.CT.cb2inv= leng.CT.cb2inv*8*3.28;
cost.CT.m2cb = leng.CT.m2cb *3.28*7;
cost.CT.total = cost.CT.cb2inv+cost.CT.m2cb;

%% Cost of Cable Tray/Conductor Labor
cost.labor.CTwire.cb2inv = leng.wire.cb2inv * 8;
cost.labor.CTwire.m2cb = leng.wire.m2cb * 2;
cost.labor.CTwire.total=cost.labor.CTwire.m2cb + cost.labor.CTwire.cb2inv;

%% Totals
cost.labor.total= cost.labor.CTwire.total + cost.CB.labor;
cost.cnt= cost.CT.total+cost.wire.total;
cost.total= cost.labor.total + cost.CT.total +cost.CB.item + cost.wire.total +cost.inverter;


%% Voltage Drop
[~,vd.stringmax] = voltdrop(longestm2cb1way,m2cbRes,Imp,Vmpmax); % VD of 10 gauge strings
[~,vd.cb2invmax] = voltdrop(longestcb2inv1way,cb2invRes,Imp*cbStrings,Vmpmax); % VD of chosen cb to inverter conductors
vd.max = vd.stringmax + vd.cb2invmax;

%% Power Loss
% sImpHourly=modPV.dc_current.^2;
% cbImpHourly=(modPV.dc_current*cbStrings).^2;
% sResAvg=(m2cbRes/1000*leng.wire.m2cb);
% cbResAvg=cb2invRes/1000*leng.wire.cb2inv;
% kwhLoss.m2cb=sum(sImpHourly*sResAvg/1000);
% kwhLoss.cb2inv=sum(cbImpHourly*cbResAvg/1000);
% degredation=linspace(1,.8,25);
% kwhLoss.total=sum(kwhLoss.cb2inv+kwhLoss.m2cb.*degredation);

%% Outputs as Structs
conductor.size = wireIndex;

misc.table.height = totH;
misc.table.width = totW;
misc.table.number= totH*totW;
misc.cb = numCB;
misc.cbstrings = cbStrings;
misc.quad.height = qH;
misc.quad.width = qW;
