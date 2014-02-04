function [vd,leng,costs,misc] = pvAlenconFunction(tablesPerQuad,dimensionIndex,wiresize,inputs)
misc.wiresize=wiresize;
      
      %% Input Arguments              
% Tables in the quadrent
% Current dimensions of array
% Current wire size being used
%#ok<*AGROW>

%% Tables
                                                                          
load('wirePriceFt.mat');
        
wirePriceCu = wirePriceFtCu * 3.28; % Dollars per kilometer
wirePriceAl = wirePriceFtAl * 3.28; % Dollars per kilometer
           

%cbStrings = cbInfo(7,x(1));

%% Declarations

Tc = 75;                        % Conductor rating
GrIP_size=10000;                % Total Array size in kW
SPOT_kW=20;                     % kW rating of SPOT
spotSize=4;                     % Strings per SPOT
DC_AC1= GrIP_size/SPOT_kW;      % 1:1 DC:AC ratio

ppc = 1;                        % If==1, Use Percent Per Celcius

tempAmbient = 37;               % Ambient temperature (C)
tempMin = -14;                  % Low Temperaure (C)

minDCtoAC = 1.0;                % X:1   % minimum DC:AC Ratio
maxDCtoAC = 1.5;                % X:1   % maximum DC:AC Ratio

latitude = 33;                  % Latitude of position
tiltAngle = 25;                 % Tilt angle of array (Degrees)

% Module Nameplate Data  
Name = 'Renesola 300W 72 cell poly c-Si';

stcKW = .300;                   % Standard Test Conditions KW
Voc = 44.8;                     % Open Circuit Voltage (V)
Vmp = 36.6;                     % Max power voltage (V)
Isc = 8.69;                     % Short circut current (A)
Imp = 8.20;                     % Max power current (A)
Tvoc = -.30;                    % Percent/C
Tisc = -.04;                    % Perecnt/C
Tvmp = -.4;                     % Percent/C
modW = 1.996;                   % Module Length (*Longer side*) (m)
modH = .994;                    % Module Width (m)
Vocmax_module = 1000;           % Max voltage of module (V)

% If the data is given in (V/C), use this equation to calculate MpS
if(ppc==0)
    MpS = floor(Vocmax_module / (Voc - (Tvoc * (25 - tempMin))));
else
    MpS = floor(Vocmax_module /(Voc*(1+((-Tvoc)*(25-tempMin)/100))));
end

% Calculates the max power voltage 
Vmpmax = MpS * (Vmp - Tvmp * (25 - tempAmbient)); % Used for VD calc of string wiring

% Table/Rack size
rows = 4;
cols = MpS;

% [totW, totH] = rackDim(latitude,rows,cols,tiltAngle,modW,modH,1);
misc.totH = 9.2;     % In meters (m)
misc.totW = 37.9;    % In meters (m)

%% Tables and Spot Calculations

% Calculates the number of tables in total system
misc.numTables = tablesPerQuad * 4;

% One SPOT is needed per table
misc.numSpots = misc.numTables;

possibleDim = [];

for i = 1:tablesPerQuad
    if mod(tablesPerQuad,i) == 0
        possibleDim = horzcat(possibleDim,tablesPerQuad / i);
    end
end

possibleDim = vertcat(possibleDim,fliplr(possibleDim));
misc.qW = possibleDim(1,dimensionIndex);
misc.qH = possibleDim(2,dimensionIndex);

%% Inverter Calculation

GrIP_size=10000000;
GrIP_DpW=.17;
costs.GrIP=GrIP_size*GrIP_DpW;
%% Volt Drop

longestT2IRun = misc.totW * (misc.qW-1);


T2IRes = resistLookup(Tc,'Cu',misc.wiresize); % resistance tray to inverter
S2TRes = T2IRes;
% S2TRes = resist(Tc,'Cu',misc.wiresize); % resistance string to tray
m2sRes = resistLookup(Tc,'Cu',5); % calculates resistance based on conductor rating for 10 gauge

[~,vd.s2t] = spotVoltDrop(misc.totH,S2TRes,8,2500,misc.qH); % VD spot to tray
[~,vd.t2i] = voltDrop(longestT2IRun,T2IRes,8*2*misc.qH,2500); % VD tray to inverter
[~,vd.m2s] = voltDrop(misc.totW,m2sRes,8.2,604); % string to spot
[~,vd.s2A] = voltDrop(misc.totW/2,m2sRes,8,2500); % spot to end of table

vd.max = vd.s2t + vd.t2i + vd.m2s + vd.s2A;

%% Length of Conductors

% Module to SPOT
leng.wire.m2s = 0; % Initialize
leng.wire.m2s = misc.totW*...% width of table
    4*... % 4 strings per table
    2; % 2 runs per string
leng.wire.m2s = leng.wire.m2s * misc.numSpots;

% SPOT to prefab 
    % Branch connectors with in-line fusing required
leng.wire.s2prefab = 0; % Initialize
leng.wire.s2prefab = (misc.numSpots)*2*... % two runs per SPOT
    (misc.totW/2); % Length of half of one table since SPOT is centered in the middle and the prefab is at the end

% SPOT to main cable tray
leng.wire.s2t = 0; % Initialize
longestS2TRun = misc.totH * (misc.qH-1); % Longest run possible from SPOT to main cable tray
leng.wire.s2t = longestS2TRun*2; % all runs make longest possible run, x2 for 2 runs per length
leng.wire.s2t = leng.wire.s2t * misc.qW/2; % one run per two table widths
leng.wire.s2t = leng.wire.s2t * 4; % total wire length spots to tray in all rows (meters)

% main cable tray to GrIP
leng.wire.t2i = 0; % Initialize
j = 1:2:misc.qW-1; % Runs per quad at increasing lengths
leng.wire.t2i = sum(misc.totW*j)*2; % 2 lengs per run, runs are summed
leng.wire.t2i = leng.wire.t2i * 4; % multiplied by number of quads

%% Cost of conductor

costs.wire.s2t = ((leng.wire.s2t) * (wirePriceCu(misc.wiresize) / 1000));
costs.wire.m2s = (leng.wire.m2s * (wirePriceCu(5)/1000)); % $/m times m = $
costs.wire.t2i = (leng.wire.t2i) * (wirePriceCu(misc.wiresize)/ 1000); % dollars
costs.wire.s2prefab = (leng.wire.s2prefab) * (wirePriceCu(5)/1000);
leng.wire.total = leng.wire.s2t + leng.wire.t2i + leng.wire.m2s; % meters

costs.wire.total = costs.wire.s2t + costs.wire.t2i + costs.wire.m2s + costs.wire.s2prefab; % cost of branch connectors; % dollars
costs.tray.total = (leng.wire.s2t*(inputs.costs.raw.s2ttray))/2 + (misc.totW*(misc.qW-1))*(inputs.costs.raw.t2itray)*2;
costs.cnt = costs.wire.total + costs.tray.total;

%% Cost of Labor and Total Cost

costs.labor.spot2inv = (leng.wire.s2t * inputs.costs.labor.s2t) + (leng.wire.t2i * inputs.costs.labor.t2i);
costs.labor.tenawg = leng.wire.m2s * inputs.costs.labor.strings;
costs.labor.spots = misc.numSpots * inputs.costs.labor.spots + tablesPerQuad*278*4;
costs.labor.tray = (leng.wire.s2t * inputs.costs.labor.s2ttray) + (leng.wire.t2i * inputs.costs.labor.t2itray);

costs.labor.wiretotal = costs.labor.tenawg + costs.labor.spot2inv;
costs.labor.total = costs.labor.wiretotal + ... % total labor costs
            costs.labor.spots + ... % spot labor costs
            costs.labor.tray; % tray labor costs

costs.total = costs.wire.total + ...
            costs.labor.total + ...
            costs.tray.total + ... % cable tray cost
            misc.numSpots * (inputs.costs.raw.spots) +...% cost of SPOTs
            costs.GrIP; 

