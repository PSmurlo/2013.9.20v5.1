function [ kWhLoss ] = kWhLossFunc( tablePerHalf,trunkInfo,CBsize,m2cbwire,numCB)
global modPV m2cbRes inv
degredation = linspace(.97,.8,25); % degredation assumed from year 1 to 25

kWhLoss.m2cb=[];
kWhLoss.cb2inv=[];
kWhLoss.total=[];


for i=degredation
    sImpHourly = (i*modPV.dc_current).^2; %hourly curent for strings (s)
    kWhLoss.m2cb = horzcat(kWhLoss.m2cb,sum(sImpHourly*m2cbRes(5)/1000*m2cbwire*tablePerHalf*2*numCB)/1000000); % resistance of total string wire length
    kWhLoss.cb2inv=horzcat(kWhLoss.cb2inv,(sum(sum(trunkInfo(:,7)*(CBsize*sImpHourly)'))/1000000)*2*(inv.num_inverters/inv.perPad));
end
kWhLoss.total = kWhLoss.m2cb+kWhLoss.cb2inv; % total losses for 25 years assuming degredation
kWhLoss.lifecycle.total=sum(kWhLoss.total);
kWhLoss.lifecycle.m2cb=sum(kWhLoss.m2cb);
kWhLoss.lifecycle.cb2inv=sum(kWhLoss.cb2inv);


