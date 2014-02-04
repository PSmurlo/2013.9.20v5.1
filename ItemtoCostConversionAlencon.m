function [cost] = RawtoCostConversionAlencon(raw)
%Item to Cost Conversion Alencon
%This code converts the raw costs into actual costs with

global wirePriceCu inputs
GrIP_size=10000000;
cost.GrIP=GrIP_size*inputs.costs.raw.inverter.GrIP;

%% Conductor Cost
cost.wire.m2spot = (raw.wire.m2spot * (wirePriceCu(5)/1000)); % $/m times m = $
cost.wire.spot2prefab = (raw.wire.spot2prefab) * (wirePriceCu(5)/1000);
cost.wire.prefab = ((raw.wire.prefab) * (wirePriceCu(raw.wire.sizeIndex) / 1000));
cost.wire.trunk2grip = (raw.wire.trunk2grip) * (wirePriceCu(raw.wire.sizeIndex)/ 1000); % dollars
cost.wire.total = cost.wire.m2spot + cost.wire.spot2prefab + cost.wire.prefab + cost.wire.trunk2grip; % cost of branch connectors; % dollars

%% Cable Tray Cost
cost.tray.total = (raw.wire.prefab*(inputs.costs.raw.prefabTray))/2 + raw.longestTrunk2GripRun*(inputs.costs.raw.trunk2gripTray)*2;
cost.labor.tray = (raw.wire.prefab * inputs.costs.labor.prefab) + (raw.wire.trunk2grip * inputs.costs.labor.trunk2grip);
%% Cost of Labor
% Conductors
cost.labor.m2spot = (raw.wire.m2spot+raw.wire.spot2prefab) * inputs.costs.labor.m2spot; % ALL #10 wire
cost.labor.prefab = (raw.wire.prefab * inputs.costs.labor.prefab);
cost.labor.trunk2grip = (raw.wire.trunk2grip * inputs.costs.labor.trunk2grip);
cost.labor.wiretotal = cost.labor.m2spot + cost.labor.prefab + cost.labor.trunk2grip;
% SPOTs
cost.labor.spots = raw.SPOTs * inputs.costs.labor.spots + raw.SPOTs*278*4;
cost.SPOTs= raw.SPOTs * inputs.costs.raw.spots;
%% Totals
cost.labor.total = cost.labor.wiretotal + ... % total labor cost
            cost.labor.spots + ... % spot labor cost
            cost.labor.tray; % tray labor cost

cost.total = cost.wire.total + ...
            cost.labor.total + ...
            cost.tray.total + ... % cable tray cost
            cost.SPOTs +...% cost of SPOTs
            cost.GrIP; 

end

