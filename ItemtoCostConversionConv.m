function[cost,raw] = ItemtoCostConversionConv(raw,trunkInfo,COST,handles)
%Item To Cost Conversion is used to convert quantities required and costs
%of each quantity into a total cost. Both input and output parameters are
%structs containing similar data.
global inv wirePriceCu1kV

%% Conductor costs (not based on inputs, but on .mat file)
raw.wire.m2cb = raw.wire.m2cb*(inv.num_inverters/inv.perPad);
cost.wire.m2cb = (raw.wire.m2cb) * (wirePriceCu1kV(5) / 1000); % $/m times m = dollars
cost.wire.cb2inv = sum(trunkInfo);

%% Multiply Components for Entire Array

%% Conductor raw total
cost.wire.raw= cost.wire.m2cb +cost.wire.cb2inv;
%% Inverter Cost

cost.inverter=str2double(get(handles.costInverter,'String'))*str2double(get(handles.ACMW,'String'));

%% Cost of Combiner Box
cost.CB.raw = raw.numCB*COST;
% 
% %% Cost of Combiner Box
% cost.CB.labor = raw.numCB * inputs.costs.labor.cbs;
% cost.CB.total = cost.CB.raw+cost.CB.labor;
% 
% %% Cost of Cable Tray
% cost.CT.cb2inv.raw= raw.CT.cb2inv*inputs.costs.raw.cb2invtray;
% cost.CT.m2cb.raw = raw.CT.m2cb*inputs.costs.raw.m2cbtray;
% cost.CT.raw = cost.CT.cb2inv.raw + cost.CT.m2cb.raw;
% 
% %% Cost of Cable Tray Labor
% cost.CT.cb2inv.labor = raw.CT.cb2inv*inputs.costs.labor.cb2invtray;
% cost.CT.m2cb.labor = raw.CT.m2cb*inputs.costs.labor.m2cbtray;
% cost.CT.labor =cost.CT.m2cb.labor + cost.CT.cb2inv.labor;

%% Cost of Conductor Labor
% cost.wire.cb2inv.labor=(sum(raw.wire.cb2inv) * inputs.costs.labor.cb2inv);
% cost.wire.m2cb.labor = raw.wire.m2cb * inputs.costs.labor.m2cb;
% cost.wire.labor=cost.wire.m2cb.labor+cost.wire.cb2inv.labor;

%% Totals
% cost.labor.total= cost.CT.labor + cost.CB.labor + cost.wire.labor;
cost.raw.total= cost.CB.raw + cost.wire.raw +cost.inverter; %cost.CT.raw +;
cost.total= cost.raw.total;%cost.labor.total +;