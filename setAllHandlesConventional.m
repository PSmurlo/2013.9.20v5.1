function []=setAllHandlesConventional(inputs, handles)
%SETALLHANDLESCONVENTIONAL sets the GUI to stored values for Conventional
% Popup menu select
global type Tc

if type(1,2) == 0
    set(handles.popupCondChoice,'Value',1)
elseif type(1,2) == 1
    set(handles.popupCondChoice,'Value',2)
end

if Tc(1,2) == 60; 
    set(handles.popupCondTemp,'Value',1)
elseif Tc(1,2) == 7
    set(handles.popupCondTemp,'Value',2)
elseif  Tc(1,2) == 90 
    set(handles.popupCondTemp,'Value',3)
end


% String select
    % Raw costs
    % Tray
set(handles.textRawTray1,   'String',inputs.costs.raw.m2cbtray)
set(handles.textRawTray2,   'String',inputs.costs.raw.cb2invtray)
    % Combiner Boxes
    % raw
set(handles.textRawSpot,    'String',inputs.costs.raw.cbs)
 % labor
set(handles.textLaborSpots, 'String',inputs.costs.labor.cbs)
    % Labor cost per length
    % Conductors
set(handles.textLaborCond1,  'String',inputs.costs.labor.m2cb)
set(handles.textLaborCond3,  'String',inputs.costs.labor.cb2inv)
    % Tray
set(handles.textLaborTray1,'String',inputs.costs.labor.m2cbtray)
set(handles.textLaborTray2,'String',inputs.costs.labor.cb2invtray)
    % Inverter Cost per Watt
set(handles.textInverterCost,'String',inputs.costs.raw.inverter.ACdollarPerWatt)
    % Inverter Efficiency
set(handles.textGripEfficiency,'String',inputs.misc.efficiency.cInverter);