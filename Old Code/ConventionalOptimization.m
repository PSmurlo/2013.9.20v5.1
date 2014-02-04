function [final,finalCell] = ConventionalOptimization(modPV,inv,CB,eleDim,plotEnable)
%% Declarations
addpath('Ampacity_Derates');

Ta = modPV.Ta;    %Temperature Ambient
Tc = 75;    %Temp conductor

%% max/mins
type=0; %0=AL, 1=cu
if(type==0)
    maxAWG=20;
else
    maxAWG=15;
end

%% Initializations
maxVD = 4;
maxCost = 2000000;
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
        [minIndex] = ampacity_check(Ta,Tc,type,'15b17',OCPDcb,2); %finds smallest wire size for configuration
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
                [vd(n),leng(n),cost(n),misc(n)] = convFindcost([ceil(numCB),m,minIndex,strings],qH,qW,modPV,eleDim,CBqH,inv); %main calculation function
                if (vd(n).max < maxVD) && (cost(n).cnt < maxCost)
                    extraData = horzcat(cost(n).total,...                % Cost of total system ($)
                        vd(n).max,...                         % Maximum voltage drop (%VD)
                        cost(n).total/misc(n).modulesW,...   % Dollars per Watt ($/W)
                        zeros(length(vd(n).max),1),...      % kwhLoss(n).total,...              % Power Loss on conductors (kWh)...
                        qH*2,...                                % Array height in number of tables
                        qW*2,...                                % Array width in number of tables
                        (qH*qW)*4,...                           % Array area in number of tables
                        strings/4,...                           % CB Size in number of tables
                        ceil(numCB),...                         % Number of combiner boxes installed
                        numCB,...                               % Number of combiner boxes utilized
                        m,...                                 % Largest Wire Size of trunk conductor
                        leng(n).wire.cb2inv1,...                % Total Length of conductor from combiner box to inverter
                        leng(n).wire.m2cb);                     % Total Length of conductor from module to combiner box
                    finalData = vertcat(finalData,extraData);
                            
                    n = n + 1;
                else
                    vd(n) = [];
                    cost(n) = [];
                    misc(n) = [];
                    leng(n) =[];
                end
            end
        end
    end
end

% conductor cost was calculated for 2 Mw system, but need to compare 10
pointlabels = {'Total System Cost','Voltage Drop','$/W','kWh Loss','Quad Height','Quad Width','Tables per Quad','CB Size in Tables','CBs Installed','CBs Utilized','Trunk Wire Index','Length of Trunk runs','String runs total'};
% finalData = horzcat(cost',vd',dpw',kwhLoss',finalData);
finalData = sortrows(finalData,1);
finalCell = vertcat(pointlabels,num2cell(finalData));


%output struct
% ** Wrong **
final.cost = finalData(1,1);
final.vd = finalData(1,2);
final.tablesperquad = finalData(1,3);
final.cbStrings = finalData(1,4);
final.wireSizeIndex = finalData(1,5);
final.qH = finalData(1,6);
final.qW = finalData(1,7);


% bestVals = [(finalData(1,1)^2) + (finalData(1,2)^2),1]; % distance to zero of first index

% loop checks all the possibilities for the closest one to (0,0)
% for i = 2:(size(x,2))
%     nextVals = [(finalData(i,1)^2) + (finalData(i,2)^2),i];
%     if nextVals(1) < bestVals(1)
%         bestVals = nextVals;
%     end
% end

if(plotEnable==1)
    
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
    figure;
    suptitle('Conventional DC Side');
    scatter(finalData(:,3),finalData(:,2),'x');
    grid
    xlabel('$/W of all X-Y components');
    ylabel('Max Volt Drop');
    ylim([0,maxVD]);
    dcm = datacursormode(fh);
    datacursormode on
    set(dcm, 'updatefcn', @PVDatatipCursor);
end



% q = bestVals(2);
% X = [finalData(q,3),finalData(q,4),finalData(q,5)];
% [totalConductorCost,VDmax,~,~,totalWire,numTables,CB.num,cbStrings, ...
%     tableW,tableH,qW,qH,totalCost] = ...
%     newPvConvFunction(X);
%
% figure;
% pvFarmDraw(0,0,tableW,tableH,qH,qW,1.996,0.994,4,19);

