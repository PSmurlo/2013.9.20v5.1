function [ kWhLoss ] = kWhLossFuncAlencon( handles,raw)
global modPV m2spotRes spot2prefabRes trunk2gripRes internal 
degredation = linspace(.97,.8,25); % degredation assumed from year 1 to 25

SPOT_eff=str2double(get(handles.spotEfficiency,'String'));

% 1 way or 2 way?
m2SPOTResTotal = internal*(m2spotRes(5)/1000); % resistance of total string wire length
spot2prefabResTotal = spot2prefabRes(5)/1000*raw.wire.spot2prefab; % resistance of total string wire length
trunk2gripResTotal = trunk2gripRes(raw.index)/1000*raw.wire.trunk2grip;            

kWhLoss.m2spot=[];
kWhLoss.spot2prefab=[];
kWhLoss.trunk2grip=[];

for i=degredation
    sImpHourly = (i*modPV.dc_current).^2; %hourly curent for strings (s)
    m2spotKWhLoss=(sImpHourly*m2SPOTResTotal/1000);
    kWhLoss.m2spot=horzcat(kWhLoss.m2spot,m2spotKWhLoss*raw.SPOTs);
    SPOTcurrentSquared=(((i*modPV.kWh_perTable-m2spotKWhLoss)*(SPOT_eff/100))/2.5).^2;
    kWhLoss.spot2prefab=horzcat(kWhLoss.spot2prefab,spot2prefabResTotal*SPOTcurrentSquared/1000);
    % prefab
    kWhLoss.trunk2grip=horzcat(kWhLoss.trunk2grip,trunk2gripResTotal*(SPOTcurrentSquared*raw.qW)/1000);
end

kWhLoss.total = sum(kWhLoss.trunk2grip+kWhLoss.spot2prefab+kWhLoss.m2spot); % total losses for 25 years assuming degredation
kWhLoss.lifecycleTotal=sum(kWhLoss.total);
% kWhLoss.lifecycle.m2cb=sum(kWhLoss.m2cb);
% kWhLoss.lifecycle.cb2inv=sum(kWhLoss.cb2inv);


