function [totalCost,VDmax,cb2invVDP,stringVDP,totalWire,numTables,numCB,cbStrings,totW,totH] = ...
          pvConvFunction(x)

%% Tables
      
wirePriceFtCu = [100000,100000,542,602,315,785,1005,1553,100000,2230,2902,3515, ... 
             4276,5637,4000,100000,100000,100000,100000,100000,100000,100000,100000,...
             100000,100000,100000,100000,100000,100000,100000]; % $/1000ft
         
wirePriceFtAl = [100000,100000,100000,100000,100000,100000,333,458,100000,643,100000, ...
                 1004,1195,1440,1737,2115,100000,3560,100000,4206,100000,100000, ...
                 5830,100000,100000,8154,100000,100000,100000,100000];%$/1000ft

         
wirePriceCu = wirePriceFtCu * 3.28;
wirePriceAl = wirePriceFtAl * 3.28;
           
%% Input Arguments
tablesPerCBSide = x(1);
tablesPerQuad = x(2);
wireIndex = x(3);
% dimensionIndex = x(4);
%cbStrings = cbInfo(7,x(1));

%% Declarations

Tc = 75; % conductor rating

inverterSize = 2000;
ppc = 1;

tempAmbient = 37;
tempMin = -14;

minDCtoAC = 1.5; %X:1   % minimum DC:AC Ratio
maxDCtoAC = 1.7; %X:1   % maximum DC:AC Ratio

latitude = 33;
tiltAngle = 25;

% Module Nameplate Data  %**have access to CEC module database, in future
% will be able to import ALL module data**
Name = 'Renesola 300W 72 cell poly c-Si';
stcKW = .300; % Standard Test Conditions KW
Voc = 44.8;
Vmp = 36.6;
Isc = 8.69;
Imp = 8.20;
Tvoc = -.30;         %percent/C
Tisc = -.04;
Tvmp = -.4;
modL = 1.996;           %Module Length (*Longer side*) (m)
modW = .994;            %Module Width (m)
Vocmax_module = 1000;

if(ppc==0)
    %not sure if works(!!)
    MpS = floor(Vocmax_module / (Voc - (Tvoc * (25 - tempMin))));
else
    MpS = floor(Vocmax_module /(Voc*(1+((-Tvoc)*(25-tempMin)/100))));
end %calculates Vmaxpower and Modules per string

Vmpmax = MpS * (Vmp - Tvmp * (25 - tempAmbient)); %used for VD calc of string wiring

% Table/Rack size
rows = 4;
cols = MpS;
[totW, totH] = rackDim(latitude,rows,cols,tiltAngle,modL,modW,1);

%% Tables and CB Calculations

cbStrings = (tablesPerCBSide * 8);
numTables = tablesPerQuad * 4;
numCB = ceil(numTables / tablesPerCBSide)/2;
CBsPerHalf = floor(numCB / 2);

% possibleDim = [];
% 
% for i = 1:tablesPerQuad
%     if mod(tablesPerQuad,i) == 0
%         possibleDim = horzcat(possibleDim,tablesPerQuad / i);
%     end
% end
% 
% possibleDim = vertcat(possibleDim,fliplr(possibleDim));
% qW = possibleDim(1,dimensionIndex);
% qH = possibleDim(2,dimensionIndex);

%% Length of Conductor

totalWireWE = 0;
totalWireNS = 0;
totalWireExtra = 0;

for i = 1:(tablesPerCBSide)
    totalWireWE = totalWireWE + totW*2*i*4; % total length of west-east wire
end

for j = 1:CBsPerHalf
    totalWireNS = totalWireNS + totH*j;  % total length of north-south wire
end

if mod(numTables,2*CBsPerHalf) ~= 0
    totalWireExtra = (CBsPerHalf + 1) * totH;
end

totalWireWE = totalWireWE * numCB * 2; % total wire length west-east (strings in meters)
totalWireNS = (totalWireNS * 2) + totalWireExtra; % total wire length north-south (meters)

%% Cost of conductor

totalWireWECost = (totalWireWE) * (wirePriceCu(5) / 1000);
totalWireNSCost = (totalWireNS) * (wirePriceAl(wireIndex) / 1000);

totalWire = totalWireWE + totalWireNS; % meters

totalCost = totalWireNSCost + totalWireWECost; % dollars per foot
totalCost = totalCost + (numCB * (1400 + (cbStrings * 75)));

totalCost = totalCost * 5; % this was all for 2 megawatts, so multiply by 5

%% Volt Drop

longestWERun = totW * tablesPerCBSide;
longestNSRun = max(totH * CBsPerHalf, totalWireExtra);

cb2invRes = resist(Tc,'Al',wireIndex); % chooses the correct resistance for that conductor
stringRes = resist(Tc,'Cu',5); % calculates resistance based on conductor rating for 10 gauge

[~,stringVDP] = voltdrop(longestWERun,stringRes,Imp,Vmpmax); % VD of 10 gauge strings
[~,cb2invVDP] = voltdrop(longestNSRun,cb2invRes,Imp,Vmpmax); % VD of chosen cb to inverter conductors

VDmax = stringVDP + cb2invVDP;
