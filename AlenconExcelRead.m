function AlenconExcelRead(handles)
global Alencon

% Get Alencon Information

% Read Excel Document
num=xlsread('Alencon_Inverter_info.xlsx',1);
partload=xlsread('Alencon_Inverter_info.xlsx',2);

% SPOT
Alencon.SPOT.DCoutMaxPower=str2double(get(handles.textSpotkW,'String'))*1000;
Alencon.SPOT.conversionEfficiency=str2double(get(handles.spotEfficiency,'String'));
Alencon.SPOT.DCinMaxPower=Alencon.SPOT.DCoutMaxPower/(Alencon.SPOT.conversionEfficiency/100);
Alencon.SPOT.DCinputvoltage=num(3);
Alencon.SPOT.VdcMax=num(4);% **Not Used**
Alencon.SPOT.nightConsumption.w=num(5);
Alencon.SPOT.inversionStart=(num(6)/100)*Alencon.SPOT.DCoutMaxPower;
Alencon.SPOT.C0=num(8);
Alencon.SPOT.C1=num(9);
Alencon.SPOT.C2=num(10);
Alencon.SPOT.C3=num(11);
Alencon.SPOT.PL.part=partload(:,1);
Alencon.SPOT.PL.eff=partload(:,2);

% GrIP
Alencon.GrIP.ACmaxPower=str2double(get(handles.ACMW,'String'))*1000;
Alencon.GrIP.conversionEfficiency=str2double(get(handles.GrIPeff,'String'));
Alencon.GrIP.DCmaxPower=Alencon.GrIP.ACmaxPower/(Alencon.GrIP.conversionEfficiency/100);
Alencon.GrIP.nightConsumption.w=num(14);
Alencon.GrIP.inversionStart=(num(15)/100)*Alencon.GrIP.ACmaxPower;
Alencon.GrIP.maxCurrent=num(16);
Alencon.GrIP.PL.part=partload(:,3);
Alencon.GrIP.PL.eff=partload(:,4);

% Non-SAM

% SPOT
Alencon.SPOT.currentLimit=num(20);

