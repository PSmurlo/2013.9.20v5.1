function [final] = newOptGraphConventional(modPV,inv,eleDim,plotEnable)
%#ok<*AGROW>
%#ok<*SAGROW>

%% Declarations

Ta = modPV.Ta;    %Temperature Ambient
Tc = 75;    %Temp conductor

Isc = modPV.Isc;
Imax = Isc * 1.25;
OCPD = Imax * 1.25;

n = 1;
extraData = [];
finalData = [];

%% Determining number of tables
% table kW
tableDCW=eleDim.modperTable*modPV.Imp*modPV.Vmp;
% required DC size
DCsize_quad=inv.pdco*inv.DC_AC.target;
tablesPerQuad=DCsize_quad/tableDCW;
tablesPerQuadRange=ceil(tablesPerQuad*(1-inv.DC_AC.variance)):floor(tablesPerQuad*(1+inv.DC_AC.variance));

%% Main
for i = tablesPerQuadRange%31:34 % 23:26 .95:1.05    40:44   1.66
    possibleDim = [];
    for q = 1:i % for numbers smaller than the number of tables per quad
        if mod(i,q) == 0 % if even multiple
            possibleDim = horzcat(possibleDim, i / q); % list possible dimensions
        end
    end
    possibleDim = [possibleDim;fliplr(possibleDim)];
    maxDim = size(possibleDim,2);
    
    for j = 1:maxDim
        OCPD = possibleDim(2,j) * 1.25 * 8 * 2;
        [minIndex] = ampacity_check(Ta,Tc,'Cu','15b17',OCPD,2);
        if minIndex >= 15
            continue
        end
        
        for k = minIndex:15
            [vd(n),conductor(n),costs(n),misc(n)] = newPvConvFunction([i,j,k]);
            if (vd(n).max < 2) && (costs(n).cnt < 800000)
                x(n) = costs(n).cnt;
                y(n) = vd(n).max;
                TC(n) = costs(n).total;
                extraData = horzcat((misc(n).table.number)/4,(j),(k));
                finalData = vertcat(finalData,extraData);
                n = n + 1;
            else
                vd(n) = [];
                conductor(n) = [];
                costs(n) = [];
                misc(n) = [];
            end
        end
    end
end
 % conductor cost was calculated for 2 Mw system, but need to compare 10

pointlabels = {'Total Cost';'Max Volt Drop';'Number of Combiner Boxes';'Number of Tables';'Index of Conductor'};
finalData = horzcat(x',y',finalData);
finalData=sortrows(finalData,1);

%output struct
final.tablesperquad=finalData(1,3);
final.dimIndex=finalData(1,4);
final.wireSizeIndex=finalData(1,5);
final.cost(1,1);
final.vd(1,2);

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
ylim([0,2]);

dcm = datacursormode(fh);
datacursormode on
set(dcm, 'updatefcn', @PVDatatipCursor);

subplot(212);
scatter(TC,y,'x');
xlabel('Total Cost System');
ylabel('Max Volt Drop');
ylim([0,2]);

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

