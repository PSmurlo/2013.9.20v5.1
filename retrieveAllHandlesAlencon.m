function []= retrieveAllHandlesAlencon(handles)
global eleDim inputs

eleDim.tilt=str2double(get(handles.editTilt,'String'));
eleDim.totH=str2double(get(handles.editSpace,'String'));

inputs.eff.SPOT=str2double(get(handles.spotEfficiency,'String'));
inputs.eff.GrIP=str2double(get(handles.GrIPeff,'String'));
inputs.costs.raw.GrIP=str2double(get(handles.costGrIP,'String'));
inputs.costs.raw.SPOT=str2double(get(handles.costSpot,'String'));

% if get(handles.popupCondChoice,'Value') == 1
%     type(2,3) = 0; % Alencon, Prefab
%     type(2,4) = 0; % Alencon, trunk
% else
%     type(2,3) = 1; % Alencon, Prefab
%     type(2,4) = 1; % Alencon, trunk
% end
% if get(handles.popupCondTemp,'Value') == 1
%     Tc(2,3) = 60; % Alencon, Prefab
%     Tc(2,4) = 60; % Alencon, trunk
% elseif get(handles.popupCondTemp,'Value') == 2
%     Tc(2,3) = 75; % Alencon, Prefab
%     Tc(2,4) = 75; % Alencon, trunk
% else
%     Tc(2,3) = 90; % Alencon, Prefab
%     Tc(2,4) = 90; % Alencon, trunk
% end
% % tray
% inputs.costs.raw.prefabTray =       str2double(get(handles.textRawTray1,'String'));
% inputs.costs.raw.trunk2gripTray =   str2double(get(handles.textRawTray2,'String'));
% % SPOTs
% % raw
% inputs.costs.raw.spots =            str2double(get(handles.textRawSpot,'String'));
% % labor
% inputs.costs.labor.spots =          str2double(get(handles.textLaborSpots,'String'));
% % Labor cost per length
% % Conductors
% inputs.costs.labor.m2spot =         str2double(get(handles.textLaborCond1,'String'));
% inputs.costs.labor.trunk2grip =     str2double(get(handles.textLaborCond2,'String'));
% inputs.costs.labor.prefab =         str2double(get(handles.textLaborCond3,'String'));
% % tray
% % inputs.costs.labor.cb2invtray =     str2double(get(handles.textLaborTray2,'String'));
% % inputs.costs.labor.m2cbtray =       str2double(get(handles.textLaborTray1,'String'));
% 
% % Inverter Cost per Watt
% inputs.costs.raw.inverter.GrIP =    str2double(get(handles.textInverterCost,'String'));
% % Efficiency input
% inputs.misc.efficiency.GrIP =       str2double(get(handles.textGripEfficiency,'String'));
% inputs.misc.efficiency.spots =      str2double(get(handles.textSpotEfficiency,'String'));