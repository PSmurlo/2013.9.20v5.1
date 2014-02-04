function [finalData] = optGraphAlencon(inputs)
%--------------------------------------------------------------------------
% Alencon Optimal Graph
% Neal Margraf, Jon Topham, Scott Hummel
% Last Revision: 8/19/13
%--------------------------------------------------------------------------

%#ok<*AGROW>

% close all;
clc;
addpath ('NEC','Voltage Drop');

%% Declarations
Ta = 37;                    % Ambient temperature (C)
Tc = 75;                    % Temperature of conductor (C)
Isc = 8.69;                 % Short circuit current (A)
Imax = Isc * 1.25;          % Max current (A)
OCPD = Imax * 1.25;         % Over current protection  (A)

n = 1;                      % Index variable
extraData = [];             % Matrix to store extra data
finalData = [];             % Matrix to store final data

%% Main 

% Loops through possible number of tables in a quadrant
for i = 119:131             
    possibleDim = [];       
    
    % Determines possible dimensions and stores them in a matrix
    for q = 1:i
        if mod(i,q) == 0
            possibleDim = horzcat(possibleDim, i / q);
        end
    end
    possibleDim = [possibleDim;fliplr(possibleDim)];
    
    % Finds the size of matrix X by X
    maxDim = size(possibleDim,2);
    
    % Loops through all possible configurations given in possibleDim
    for j = 1:maxDim
        OCPD = possibleDim(2,j) * 1.25 * 8 * 2;
        [minIndex] = ampacityCheck(2,3,'15b17',OCPD); %Copper Prefab Conductor
        
        % If there is too much current, ignore this array layout
        if minIndex >= 18
            continue
        end
        
        % Run the pvAlenconFunction on current array layout
        for k = minIndex:18
            [vd(n),leng(n),costs(n),misc(n)] ...
                = pvAlenconFunction([i,j,k],inputs);         
            % If the VD is less than 2 percent and cost is less than 1000000, save result
            if (vd(n).max < 4) && (costs(n).total < 4000000)
                extraData = horzcat(costs(n).total,...      % Total System Cost
                    vd(n).max,...                           % Maximum voltage drop percent
                    costs(n).total/(76*i*4*300),...         % $/W
                    costs(n).wire.total,...                 % Cost of Conductors
                    costs(n).tray.total,...                 % Cost of Tray
                    costs(n).labor.total,...                % Cost of Labor
                    leng(n).wire.m2s + leng(n).wire.s2prefab,...% Length of #10
                    leng(n).wire.s2t + leng(n).wire.t2i,...    % Length of Trunk                    % Size of Trunk
                    misc(n).qH*2,...                           % Array height in tables
                    misc(n).qW*2,...
                    misc(n).numSpots,...
                    misc(n).numSpots * (inputs.costs.raw.spots),...
                    costs(n).GrIP,...
                misc(n).wiresize);                             % Array width in tables
                finalData = vertcat(finalData,extraData);
                n = n + 1;            
            % If conditions are not met, set all matrices to empty
%             else
%                vd(n) = [];
%                 leng(n) = [];
%                 costs(n) = [];
%                 misc(n) = [];
            end
        end
    end
end

% Labels for final data matrix
% pointlabels = {'Total Cost','Max Voltage Drop','Total Wire','Number of Tables','Dimension Index','Index of Conductor'};

% Add together volt drop and total cost to finaldata matrix
% finalData = horzcat(x',y',finalData);

%% Cheapest Five
% sortedData = sortedData(1:5,:);
% sortedData = sortedData';

%% Plots 

% Create main plot title in full screen figure
% fh = figure('units','normalized','outerposition',[0 0 1 1]);
% suptitle('Alencon DC Side');
% 
% % Plot the VD vs the cost of conductors and cable tray
% subplot(221)
% s1 = scatter(finalData(:,1),finalData(:,2),'x');
% title('Conductors and Cable Tray')
% xlabel('Cost of Conductor + Cable Tray (hundred thousands)');
% ylabel('Max Volt Drop Percent');
% grid;
% 
% % Allows you to select data points on the plot
% dcm = datacursormode(fh);
% datacursormode on
% set(dcm, 'updatefcn', @PVDatatipCursor);
% 
% % Plot VD vs cost of labor, conductors, and cable tray
% subplot(222)
% s2 = scatter(WLC' + SLC' + finalData(:,1),finalData(:,2),'x');
% title('Voltage Drop vs. Cost of Conductors, Cable Tray, and Installation of Each');
% xlabel('Cost of Labor + Conductors + Cable Tray(hundred thousand)');
% grid;
% 
% % Plot VD vs the cost of conductors, cable tray, and SPOTs
% subplot(223)
% s3 = scatter(finalData(:,1) + inputs.costs.raw.spots*4*finalData(:,6),finalData(:,2),'x');
% title('Voltage Drop vs. Cost of Conductors, Cable Tray, and SPOTs');
% xlabel('Total Cost of 10MW system including SPOTs (millions)');
% ylabel('Max Volt Drop Percent');
% grid;
% 
% % Plot VD vs Total cost of Alencons system
% subplot(224)
% s4 = scatter(TC,finalData(:,2),'x');
% title('Voltage Drop vs. Total Cost');
% xlabel('Total Cost of 10MW system including SPOTs (millions)');
% grid;

%% Old Code

% q = bestVals(2);
% X = [finalData(q,4),finalData(q,5),finalData(q,6)];
%     [totalCNTCost,VDP,~,~,totalWire,numTables,tableW,...
%      tableH,qW,qH,totalCost,totalCableTrayCost,totalWireCost] = ...
%     pvAlenconFunction(X);
% 
% disp(horzcat('Quadrants are ',num2str(qW),' tables wide and ',num2str(qH),' tables tall.'));
% disp(horzcat('There are ',num2str(numTables),' tables and ',num2str(numTables),' SPOTs.'));
% disp(horzcat(num2str(totalWire),' meters of conductor would cost $',num2str(totalWireCost)));
% disp(horzcat('Maximum voltage drop is ',num2str(VDP)));
% disp(horzcat('The cost of the cable tray is $',num2str(totalCableTrayCost)));
% disp(horzcat('The cost of the conductor and cable tray combined is $',num2str(totalCNTCost)));
% disp(horzcat('The total cost, including cable tray and SPOTs, is $',num2str(totalCost)));
% 
% figure;
% pvFarmDraw(0,0,tableW,tableH,qH,qW,1.996,0.994,4,19);
