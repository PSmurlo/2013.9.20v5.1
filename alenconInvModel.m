function[data]=SPOTmodel(data)

global Alencon
ssccall('data_set_number', data, 'inverter_model', Alencon.inverterModel);

if Alencon.inverterModel==0 % CEC
    ssccall('data_set_number', data, 'inv_snl_c0', Alencon.SPOT.C0);
    ssccall('data_set_number', data, 'inv_snl_c1', Alencon.SPOT.C1);
    ssccall('data_set_number', data, 'inv_snl_c2', Alencon.SPOT.C2);
    ssccall('data_set_number', data, 'inv_snl_c3', Alencon.SPOT.C3);
    ssccall('data_set_number', data, 'inv_snl_paco', Alencon.SPOT.DCoutMaxPower);
    ssccall('data_set_number', data, 'inv_snl_pdco', Alencon.SPOT.DCinMaxPower);
    ssccall('data_set_number', data, 'inv_snl_pnt', Alencon.SPOT.nightConsumption.w);
    ssccall('data_set_number', data, 'inv_snl_pso', Alencon.SPOT.inversionStart);
    ssccall('data_set_number', data, 'inv_snl_vdco', Alencon.SPOT.DCinputvoltage);
    ssccall('data_set_number', data, 'inv_snl_vdcmax', Alencon.SPOT.VdcMax);
    
elseif Alencon.inverterModel==1 % Datasheet
    ssccall('data_set_number', data, 'inv_ds_paco', Alencon.SPOT.DCoutMaxPower);
    ssccall('data_set_number', data, 'inv_ds_eff',  Alencon.SPOT.conversionEfficiency);
    ssccall('data_set_number', data, 'inv_ds_pnt',  Alencon.SPOT.nightConsumption.w);
    ssccall('data_set_number', data, 'inv_ds_pso',  Alencon.SPOT.inversionStart);
    ssccall('data_set_number', data, 'inv_ds_vdco', Alencon.SPOT.DCinputvoltage);
    ssccall('data_set_number', data, 'inv_ds_vdcmax',Alencon.SPOT.VdcMax);
elseif Alencon.inverterModel==2 % Partload
    ssccall('data_set_number', data, 'inv_pd_paco', Alencon.SPOT.DCoutMaxPower);
    ssccall('data_set_number', data, 'inv_pd_pdco', Alencon.SPOT.DCinMaxPower);
    ssccall('data_set_array', data, 'inv_pd_partload', Alencon.SPOT.PL.part);
    ssccall('data_set_array', data, 'inv_pd_efficiency', Alencon.SPOT.PL.eff);
    ssccall('data_set_number', data, 'inv_pd_pnt', Alencon.SPOT.nightConsumption.w);
    ssccall('data_set_number', data, 'inv_pd_vdco', Alencon.SPOT.DCinputvoltage);
    ssccall('data_set_number', data, 'inv_pd_vdcmax', Alencon.SPOT.VdcMax);    
end


