function [finalData,tableData] = finalDataExtract(handles,cost,raw,vd,kWhLoss,info)
%FINALDATAEXTRACT extracts essential data in order to populate a table with
%equivalent data from both Alencon and Conventional systems.
%   [finalData,tableData] = finalDataExtract(cost,raw,kWhLossvd) populates a table
%   for Alencon's system with a uniform trunk size.
%   [finalData,tableData] = finalDataExtract(cost,raw,vd,kWhLossinfo,trunkInfo)
%   populates a table for the conventional system with additional combiner
%   box information as well as a non-uniform trunk size.
%
%   See also ConventionalOptimizationv4, AlenconOptimizationv4
global tableW inv modPV eleDim internal prefab
swap=@(varargin)varargin{nargin:-1:1}; % anonymous function to do swapping operation

finalData=[];
if nargin == 6 % Conventional
    totalW=tableW*info.hW*info.hH*2*(inv.num_inverters/4);
    tableData=horzcat(cost.total,...% Total Cost of System
        vd.max,...% Max Volt Drop %
        kWhLoss.lifecycle.total,...% GWh loss over 25yrs
        cost.total/totalW,...% $/W
        totalW/1000000,...% Rated DC Power of Array
        str2double(get(handles.ACMW,'String')),...% Rated AC power of inverters
        round((totalW/1000000)/str2double(get(handles.ACMW,'String'))*1000)/1000,...% Exact DC:AC Ratio
        info.hW*info.hH*modPV.mps*2*4*(inv.num_inverters/inv.perPad),...     % Number of Modules
        info.hW*info.hH*modPV.mps*2*4*(inv.num_inverters/inv.perPad)/modPV.mps,... % Number of strings
        inv.num_inverters,...% Number of Inverters
        cost.inverter,...% Cost of Inverters
        raw.numCB,...% # of CBs/SPOTs
        cost.CB.raw,...% Cost of CBs/SPOTs
        info.stringsPerCB,...% # of Strings per CB/SPOT
        (info.hW*eleDim.totW)*((info.hH*eleDim.totH+eleDim.array2Inverter)*2)*(inv.num_inverters/inv.perPad),...% Array Area
        (info.hH*eleDim.totH+eleDim.array2Inverter)*2,...% Array Height in meters
        info.hW*eleDim.totW,...% Array Width in meters
        info.hH*2,...% Array Height in tables
        info.hW,...% Array Width in tables
        cost.wire.raw,...% Total Cost of Conductor
        raw.wire.m2cb,...% Length of String Wiring
        0,...% Length of SPOT to Prefab
        0,...% Length of Prefab Wiring
        sum(info.trunkInfo),...% Length of Trunk Wiring
        info.index);% Trunk (and Prefab) Wire Size
    
    %     tableData = horzcat(cost.total,...              % Cost of total system ($)
    %         vd.max,...                                  % Maximum voltage drop percent (%VD)
    %         kWhLoss.lifecycle.total,...                       % Dissipated kWh over conductors
    %         cost.total/(totalW),...                     % Dollars per Watt ($/W)
    %         info.hW*info.hH*modPV.mps*2*4*(inv.num_inverters/inv.perPad),...     % Number of Modules
    %         info.hW*info.hH*modPV.mps*2*4*(inv.num_inverters/inv.perPad)/modPV.mps,...       % Number of strings
    %         cost.wire.raw,...                           % Cost of Conductors
    %         raw.wire.m2cb,...                           % length of #10
    %         sum(info.trunkInfo(:,1)),...                % length of Trunk
    %         info.hH*2,...                               % Array height in tables
    %         info.hW,...                                 % Array width in tables
    %         ((info.hW*eleDim.totW)*((info.hH*eleDim.totW)+eleDim.array2Inverter))*(inv.num_inverters/4),...
    %         raw.numCB,...                               % Number of combiner Boxes
    %         info.stringsPerCB,...                       % Strings per combiner box
    %         cost.CB.raw,...                             % Cost of CB
    %         cost.inverter,...                             % Cost of Inverter
    %         info.index);
elseif nargin == 5 % Alencon
    if(prefab.dir==1)
        [raw.qH,raw.qW]=swap(raw.qH,raw.qW);
    end
    totalW=tableW*raw.SPOTs;
    tableData=horzcat(cost.total,...% Total Cost of System
        vd.max,...% Max Volt Drop %
        kWhLoss.lifecycleTotal,...% GWh loss over 25yrs
        cost.total/totalW,...% $/W
        totalW/1000000,...% Rated DC Power of Array
        str2double(get(handles.ACMW,'String')),...% Rated AC power of inverters
        round((totalW/1000000)/str2double(get(handles.ACMW,'String'))*1000)/1000,...% Exact DC:AC Ratio
        raw.qW*raw.qH*modPV.mps*4*4,...% Number of Modules
        raw.qW*raw.qH*4*4,...% Number of Strings
        0,...% Number of Inverters
        cost.GrIP,...% Cost of Inverters
        raw.SPOTs,...% # of CBs/SPOTs
        cost.SPOTs,...% Cost of CBs/SPOTs
        4,...% # of Strings per CB/SPOT
        (raw.qW*2*eleDim.totW)*((raw.qH*eleDim.totH+eleDim.array2Inverter)*2),...% Array Area
        (raw.qH*eleDim.totH+eleDim.array2Inverter)*2,...% Array Height in meters
        raw.qW*2*eleDim.totW,...% Array Width in meters
        raw.qH*2,...% Array Height in tables
        raw.qW*2,...% Array Width in tables
        cost.wire.total,...% Total Cost of Conductor
        raw.SPOTs*internal,...% Length of String Wiring
        raw.SPOTs*raw.wire.spot2prefab,...% Length of SPOT to Prefab
        raw.wire.prefab,...% Length of Prefab Wiring
        raw.wire.trunk2grip,...% Length of Trunk Wiring
        raw.index);% Trunk (and Prefab) Wire Size
    
    %     tableData = horzcat(cost.total,...              % Cost of total system ($)
    %         vd.max,...                                  % Maximum voltage drop percent (%VD)
    %         kWhLoss.lifecycleTotal,...                       % Dissipated kWh over conductors
    %         cost.total/(totalW),...                     % Dollars per Watt ($/W)
    %         raw.qW*raw.qH*modPV.mps*4*4,...              % Number of Modules
    %         (raw.qW*raw.qH*4*4),...                     % Number of strings
    %         cost.wire.total,...                         % Cost of Conductors
    %         raw.SPOTs*(internal + raw.wire.spot2prefab),...  % length of #10
    %         raw.wire.prefab + raw.wire.trunk2grip,...   % length of Trunk
    %         raw.qH*2,...                                % Array height in tables
    %         raw.qW,...                                  % Array width in tables
    %         (raw.qW*eleDim.totW)*((raw.qH*eleDim.totW)+eleDim.array2Inverter*4),...
    %         raw.SPOTs,...                               % Number of SPOTs
    %         4,...                                       % strings per spot
    %         cost.SPOTs,...                              % cost of SPOTs
    %         cost.GrIP,...
    %         raw.index);
else
    disp('finalDataExtract has Incorrect Input Arguments');
end