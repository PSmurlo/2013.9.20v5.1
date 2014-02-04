function [data]=sandiaInvModel(data)
global inv
ssccall('data_set_number', data, 'inv_snl_c0', inv.c0);
ssccall('data_set_number', data, 'inv_snl_c1', inv.c1);
ssccall('data_set_number', data, 'inv_snl_c2', inv.c2);
ssccall('data_set_number', data, 'inv_snl_c3', inv.c3);
ssccall('data_set_number', data, 'inv_snl_paco', inv.paco);
ssccall('data_set_number', data, 'inv_snl_pdco', inv.pdco);
ssccall('data_set_number', data, 'inv_snl_pnt', inv.pnt);
ssccall('data_set_number', data, 'inv_snl_pso', inv.pso);
ssccall('data_set_number', data, 'inv_snl_vdco', inv.vdco);
ssccall('data_set_number', data, 'inv_snl_vdcmax', inv.vdcmax);