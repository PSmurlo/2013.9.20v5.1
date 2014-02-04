function []=setAllHandlesAlencon(inputs,handles)
%SETALLHANDLESALENCON sets the GUI to stored values for Alencon
% Popup menu select
global type Tc

if type(2,3) == 0
    set(handles.popupCondChoice,'Value',1)
elseif type(2,3) == 1
    set(handles.popupCondChoice,'Value',2)
end

if Tc(2,3) == 60; 
    set(handles.popupCondTemp,'Value',1)
elseif Tc(2,3) == 75
    set(handles.popupCondTemp,'Value',2)
elseif  Tc(2,3) == 90 
    set(handles.popupCondTemp,'Value',3)
end

% String select
    % Raw costs
        % Tray
set(handles.textRawTray1,'String',inputs.costs.raw.trunk2gripTray)
set(handles.textRawTray2,'String',inputs.costs.raw.prefabTray)
        % SPOTs
        % raw
set(handles.textRawSpot,'String',inputs.costs.raw.spots)
        % labor
set(handles.textLaborSpots,'String',inputs.costs.labor.spots)
    % Labor cost per length
        % Conductors
set(handles.textLaborCond1,'String',inputs.costs.labor.m2spot)
set(handles.textLaborCond2,'String',inputs.costs.labor.trunk2grip)
set(handles.textLaborCond3,'String',inputs.costs.labor.prefab)
        % Tray
set(handles.textLaborTray1,'String',inputs.costs.labor.m2cbtray)
set(handles.textLaborTray2,'String',inputs.costs.labor.cb2invtray)
 % Inverter Cost per Watt
set(handles.textInverterCost,'String',inputs.costs.raw.inverter.GrIP)
    % conventional Inverter Efficiency
set(handles.textGripEfficiency,'String',inputs.misc.efficiency.GrIP)