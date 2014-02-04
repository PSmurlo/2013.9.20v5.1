function [final,finalCell] = newOptGraphConventional_rev(modPV,inv,eleDim,plotEnable)
%#ok<*AGROW>
%#ok<*SAGROW>

%% Declarations
addpath('Ampacity_Derates');

Ta = modPV.Ta;    %Temperature Ambient
Tc = 75;    %Temp conductor

%% max/mins
type=0; %0=AL, 1=cu
if(type==0)
    maxAWG=21;
else
    maxAWG=15;
end

maxVD = 10;
maxCost = 10000000;

%%
Isc = modPV.Isc;
Imax = Isc * 1.25;
OCPD = Imax * 1.25;

cbStrings = 8:8:32;

OCPD = OCPD * cbStrings;
[minIndex] = ampacity_check(Ta,Tc,type,'15b17',OCPD,2); %finds smallest wire size for configuration
if minIndex >= maxAWG
    disp('Combiner box size too small.')
    return % If minimum wire size based on ampacity exceeds the largest possible available conductor
end

n = 1;
finalData = [];

%% Determining number of tables
% table Watts
tableDCW=eleDim.modperTable*modPV.Imp*modPV.Vmp;
% required DC size
DCsize_quad=inv.pdco*inv.DC_AC.target;
tablesPerQuad=DCsize_quad/tableDCW;
tablesPerQuadRange=ceil(tablesPerQuad*(1-inv.DC_AC.variance)):floor(tablesPerQuad*(1+inv.DC_AC.variance));

%% Main
for i = tablesPerQuadRange % number of tables per quad for given DC:AC Ratio
    possibleDim = [];
    for q = 1:i % for numbers smaller than the number of tables per quad
        if mod(i,q) == 0 % if even multiple
            possibleDim = horzcat(possibleDim, i / q); % list possible dimensions
        end
    end
    possibleDim = [possibleDim;fliplr(possibleDim)];
    maxDim = size(possibleDim,2);
    
    for j = 1:maxDim % cycle through possible dimensions  
        qH = possibleDim(1,j);
        qW = possibleDim(2,j);
        [numCB,cbStringsOutput]=evenCB(cbStrings,qH,qW);
        if isempty(numCB) == 1
            continue
        end
        for k = numCB
            m=cbStringsOutput(k == numCB);
            for l = minIndex:maxAWG %Size up this conductor up to the maximum allowable size
                [vd(n),leng(n),cost(n),misc(n)] = newPvConvFunction([k,l,m],qH,qW,modPV,eleDim); %calculate information
                if (vd(n).max < maxVD) && (cost(n).cnt < maxCost)
                    x(n) = cost(n).cnt; %costs of cable tray and conductor
                    y(n) = vd(n).max; %max volt drop
                    TC(n) = cost(n).total; %total cost
                    extraData = horzcat((qH*qW),m,l,qH,qW,leng(n).wire.cb2inv,leng(n).wire.m2cb,k); 
                    finalData = vertcat(finalData,extraData);
                    n = n + 1;
                else
                    vd(n) = [];
                    leng(n) = [];
                    cost(n) = [];
                    misc(n) = [];
                end
            end
        end
    end
end
% conductor cost was calculated for 2 Mw system, but need to compare 10

pointlabels = {'CT+Conductor Cost','Voltage Drop','total cost','Tables per Quad','CB Size','Trunk Wire Index','Quad Height','Quad Width','Length of Trunk runs','String runs total','number of Combiner Boxes'};
finalData = horzcat(TC',x',y',finalData);
finalData=sortrows(finalData,1);
finalCell = vertcat(pointlabels,num2cell(finalData));


%output struct
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
    

fh = figure;
suptitle('Conventional DC Side');
subplot(211);
scatter(x,y,'x');
xlabel('Total Cost of Cable Tray + Conductors');
ylabel('Max Volt Drop');
ylim([0,maxVD]);

dcm = datacursormode(fh);
datacursormode on
set(dcm, 'updatefcn', @PVDatatipCursor);

subplot(212);
scatter(TC,y,'x');
xlabel('Total Cost System');
ylabel('Max Volt Drop');
ylim([0,maxVD]);

end
end


% q = bestVals(2);
% X = [finalData(q,3),finalData(q,4),finalData(q,5)];
% [totalConductorCost,VDmax,~,~,totalWire,numTables,numCB,cbStrings, ... 
%     tableW,tableH,qW,qH,totalCost] = ...
%     newPvConvFunction(X);
% 
% figure;
% pvFarmDraw(0,0,tableW,tableH,qH,qW,1.996,0.994,4,19);

