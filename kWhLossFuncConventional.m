function [ kWhLoss ] = kWhLossFuncConventional( tablePerHalf,trunkInfo,CBsize,m2cbwire,numCB)
global modPV m2cbRes inv
degredation = linspace(.97,.8,25); % degredation assumed from year 1 to 25

kWhLoss.m2cb=[];
kWhLoss.cb2inv=[];
kWhLoss.total=[];

for i=degredation
    sImpHourly = (i*modPV.dc_current).^2; %hourly curent for strings (s)
    cbImpHourly = (i*CBsize*modPV.dc_current).^2; %hourly curent for CB (cb)
    kWhLoss.m2cb = horzcat(kWhLoss.m2cb,sum(sImpHourly*m2cbRes(5)/1000*m2cbwire*(2*(inv.num_inverters/4))/1000)); % resistance of total string wire length
    kWhLoss.cb2inv=horzcat(kWhLoss.cb2inv,(sum(sum((trunkInfo(:,7))*(cbImpHourly)'))/1000)*2*(inv.num_inverters/4));
end
kWhLoss.total = kWhLoss.m2cb+kWhLoss.cb2inv; % total losses for 25 years assuming degredation
kWhLoss.lifecycle.total=sum(sum(kWhLoss.total))/1000;
kWhLoss.lifecycle.m2cb=sum(sum(kWhLoss.m2cb))/1000;
kWhLoss.lifecycle.cb2inv=sum(sum(kWhLoss.cb2inv))/1000; % MWh


