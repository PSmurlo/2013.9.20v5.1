function[cost] = ItemtoCostConversion(leng,inputs)
%Item To Cost Conversion is used to convert quantities required and costs
%of each quantity into a total cost. Both input and output parameters are
%structs containing similar data.

%% Inverter Cost
cost.inverter=inv.paco*inv.num_inverters*inputs.ACdollarPerWatt;

%% Cost of Conductor
cost.wire.total= cost.wire.m2cb +cost.wire.cb2inv;

%% Cost of Combiner Box
cost.CB.raw = numCB * inputs.costs.raw.cbs;

%% Cost of Combiner Box
cost.CB.labor = numCB * inputs.costs.labor.cbs;
cost.CB.total = cost.CB.raw+cost.CB.labor;

%% Cost of Cable Tray
cost.CT.cb2inv.raw= leng.CT.cb2inv*inputs.costs.raw.cb2invtray;
cost.CT.m2cb.raw = leng.CT.m2cb*inputs.costs.raw.m2cbtray;
cost.CT.raw = cost.CT.cb2inv.raw + cost.CT.m2cb.raw;

%% Cost of Cable Tray Labor
cost.CT.cb2inv.labor = leng.CT.cb2inv*inputs.costs.labor.cb2invtray;
cost.CT.m2cb.labor = leng.CT.m2cb*inputs.costs.labor.m2cbtray;
cost.CT.labor =cost.CT.m2cb.labor + cost.CT.cb2inv.labor;

%% Cost of Conductor Labor
cost.wire.cb2inv.labor=(sum(leng.wire.cb2inv) * inputs.costs.labor.cb2inv);
cost.wire.m2cb.labor = leng.wire.m2cb * inputs.costs.labor.m2cb;
cost.wire.labor=cost.wire.m2cb.labor+cost.wire.cb2inv.labor;

%% Totals
cost.labor.total= cost.CT.labor + cost.CB.labor + cost.wire.labor;
cost.raw.total= cost.CT.raw +cost.CB.raw + cost.wire.total +cost.inverter;
cost.total= cost.labor.total + cost.raw.total; 
