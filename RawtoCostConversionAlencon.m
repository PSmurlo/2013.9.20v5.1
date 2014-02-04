function [cost] = RawtoCostConversionAlencon(raw,handles)
%Item to Cost Conversion Alencon
%This code converts the raw costs into actual costs with

global type internal
global priceString alenconPriceTrunk

% Number of SPOTs
num_SPOT=raw.SPOTs;

% Converter Sizes
GrIP_size=str2double(get(handles.ACMW,'String'))*1000000;
SPOT_size=str2double(get(handles.textSpotkW,'String'))*1000;

% Converter Cost
cost.GrIP=str2double(get(handles.costGrIP,'String'))*GrIP_size;
cost.SPOTs=str2double(get(handles.costSpot,'String'))*SPOT_size*num_SPOT;

%% Conductor Cost
%% Cost

cost.wire.m2spot = (internal*num_SPOT* (priceString(5)/1000)); % $/m times m = $
if type(2,2)==1
    cost.wire.spot2prefab = (raw.wire.spot2prefab) * (alenconPriceTrunk(5)/1000);
else
    cost.wire.spot2prefab = (raw.wire.spot2prefab) * (alenconPriceTrunk(6)/1000);
end

cost.wire.prefab = ((raw.wire.prefab) * (alenconPriceTrunk(raw.index) / 1000)) +...
    raw.SPOTs*278*4; % markup for prefab connectors
cost.wire.trunk2grip = (raw.wire.trunk2grip) * (alenconPriceTrunk(raw.index)/ 1000) ; % dollars

cost.wire.prefab = ((raw.wire.prefab)*(alenconPriceTrunk(raw.index)/1000))+num_SPOT*278*4; % last part is the markup for prefab
cost.wire.trunk2grip = (raw.wire.trunk2grip) * (alenconPriceTrunk(raw.index)/ 1000) ; % dollars
cost.wire.total = cost.wire.m2spot + cost.wire.spot2prefab + cost.wire.prefab + cost.wire.trunk2grip; % cost of branch connectors; % dollars

%% Cable Tray Cost
% cost.tray.total = (raw.wire.prefab*(inputs.costs.raw.prefabTray))/2 + raw.longestTrunk2GripRun*(inputs.costs.raw.trunk2gripTray)*2;
% cost.labor.tray = (raw.wire.prefab * inputs.costs.labor.prefab) + (raw.wire.trunk2grip * inputs.costs.labor.trunk2grip);
%% Cost of Labor
% Conductors
% cost.labor.m2spot = (raw.wire.m2spot+raw.wire.spot2prefab) * inputs.costs.labor.m2spot; % ALL #10 wire
% cost.labor.prefab = (raw.wire.prefab * inputs.costs.labor.prefab);
% cost.labor.trunk2grip = (raw.wire.trunk2grip * inputs.costs.labor.trunk2grip);
% cost.labor.wiretotal = cost.labor.m2spot + cost.labor.prefab + cost.labor.trunk2grip ;
% SPOTs
% cost.labor.spots = 4*raw.SPOTs * inputs.costs.labor.spots;
% cost.SPOTs= 4*raw.SPOTs * inputs.costs.raw.spots;
%% Totals
% cost.labor.total = cost.labor.wiretotal + ... % total labor cost
%             cost.labor.spots + ... % spot labor cost
%             cost.labor.tray; % tray labor cost

cost.total = cost.wire.total + ...
    cost.SPOTs +...% cost of SPOTs
    cost.GrIP;
%                     cost.labor.total + ...
%             cost.tray.total + ... % cable tray cost

end

