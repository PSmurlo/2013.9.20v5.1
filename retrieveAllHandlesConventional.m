function retrieveAllHandlesConventional(handles)

global eleDim inputs

eleDim.tilt=str2double(get(handles.editTilt,'String'));
eleDim.totH=str2double(get(handles.editSpace,'String'));

inputs.costs.raw.Inverter=str2double(get(handles.costInverter,'String'));


%     if get(handles.popupCondChoice,'Value') == 1
%         type(1,2) = 0; % Conventional, trunk
%         
%     else
%         type(1,2) = 1; % Conventional, trunk
%         
%     end
%     if get(handles.popupCondTemp,'Value') == 1
%         Tc(1,2) = 60; % Conventional, trunk
%         
%     elseif get(handles.popupCondTemp,'Value') == 2
%         Tc(1,2) = 75; % Conventional, trunk
%         
%     else
%         Tc(1,2) = 90; % Conventional, trunk
        
%     end
    % Raw costs
    % Tray
%     inputs.costs.raw.m2cbtray =     str2double(get(handles.textRawTray1,'String'));
%     inputs.costs.raw.cb2invtray =   str2double(get(handles.textRawTray2,'String'));
%     % Combiner Boxes
%     % raw
%     inputs.costs.raw.cbs =          str2double(get(handles.textRawSpot,'String'));
%     % labor
%     inputs.costs.labor.cbs =        str2double(get(handles.textLaborSpots,'String'));
%     % Labor cost per length
%     % Conductors
%     inputs.costs.labor.m2cb =       str2double(get(handles.textLaborCond1,'String'));
%     inputs.costs.labor.cb2inv =     str2double(get(handles.textLaborCond3,'String'));
%     % tray
%     inputs.costs.labor.m2cbtray =   str2double(get(handles.textLaborTray1,'String'));
% %     inputs.costs.labor.cb2invtray = str2double(get(handles.textLaborTray2,'String'));
%     % Inverter Cost per Watt
%     inputs.costs.raw.inverter.ACdollarPerWatt = str2double(get(handles.textInverterCost,'String'));
%     % conventional Inverter Efficiency
% inputs.misc.efficiency.cInverter = str2double(get(handles.textGripEfficiency,'String'));

