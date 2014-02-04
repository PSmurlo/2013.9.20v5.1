clear all;
close all;
clc;

n = 1;
extraData = [];
finalData = [];

for i = 2:10
    for j = 23:26
        for k = 7:21
            [x(n),y(n),~,~,~,numTables,numCB] = pvConvFunction([i,j,k]);
            if (y(n) < 2) && (x(n) < 900000)
                n = n + 1;
                extraData = horzcat(numCB,numTables,(k));
                finalData = vertcat(finalData,extraData);
            else
                x(n) = [];
                y(n) = [];
            end
        end
    end
end

pointlabels = {'Total Cost';'Max Volt Drop';'Number of Combiner Boxes';'Number of Tables';'Index of Conductor'};
finalData = horzcat(x',y',finalData);

bestVals = [(finalData(1,1)^2) + (finalData(1,2)^2),1]; % distance to zero of first index

% loop checks all the possibilities for the closest one to (0,0)
for i = 2:(size(x,2))
    nextVals = [(finalData(i,1)^2) + (finalData(i,2)^2),i];
    if nextVals(1) < bestVals(1)
        bestVals = nextVals;
    end
end

fh = figure;
scatter(x,y,'x');
xlabel('Total Cost');
ylabel('Max Volt Drop');

dcm = datacursormode(fh);
datacursormode on
set(dcm, 'updatefcn', @PVDatatipCursor);

q = bestVals(2);
X = [finalData(q,4) / 4,finalData(q,5),finalData(q,6)];
[totalWireCost,VDP,~,~,totalWire,numTables,numCB,tableW,tableH,~,~,totalCost,totalCableTrayCost] = ...
    pvAlenconFunction(X);

qW = X(1);
qH = numCB / 2;

figure;
pvFarmDraw(0,0,tableW,tableH,qH,qW,1.996,0.994,4,19);