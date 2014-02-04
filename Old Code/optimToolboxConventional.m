%% Minimization Script - Conventional

clc;
close all;
clear all;

% suppresses warnings for lack of semicolons
%#ok<*NOPTS>

%% Declarations
minDCtoAC = 1.5; %X:1   %maximum DC:AC Ratio
maxDCtoAC = 1.7; %X:1   %percent oversize of number of SPOTs

inverterSize = 2000;
rows = 4;

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
tempMin = -14;
ppc = 1;

if(ppc==0)
    %not sure if works(!!)
    MpS = floor(Vocmax_module / (Voc - (Tvoc * (25 - tempMin))));
else
    MpS = floor(Vocmax_module /(Voc*(1+((-Tvoc)*(25-tempMin)/100))));
end %calculates Vmaxpower and Modules per string

%% Bounds

tableMin = floor(inverterSize/(rows * MpS * stcKW)); %1:1 DC:AC
tablesLB = ceil((tableMin * (minDCtoAC))/4);
tablesUB = floor((tableMin * (maxDCtoAC))/4);   

lb = [2,tablesLB,6];
ub = [10,tablesUB,30];

%% Optimization

[X,Fval,exitflag,output] = ga(@(x) pvConvFunction(x),3, ...
                                [],[],[],[],lb,ub,[],[1,2,3])
                            
[totalCost,VDPercent,cb2invVDP,stringVDP,totalWire,numTables,numCB,cbStrings,totL,totW] = pvConvFunction(X);

%% Output to Command Line

disp(strcat('Total Cost:                  $',num2str(totalCost)));
disp(horzcat('Total Length of Wire:         ',num2str(totalWire), ' meters'));
disp(strcat('Highest Voltage Drop:        %',num2str(VDPercent)));
disp(horzcat('Number of Tables:             ',num2str(numTables)));
disp(horzcat('Number of Combiner Boxes:     ',num2str(numCB)));
disp(horzcat('Number of Strings per CB:     ',num2str(cbStrings)));
disp(horzcat('Size of Conductor is:         ',wireIndex(X(3))));

%% Plotting the PV Farm

quadW = X(1);
quadH = numCB / 2;

figure
pvFarmDraw(0,0,totL,totW,quadH,quadW,modL,modW,rows,MpS)
grid on