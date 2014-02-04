function [data]=test_pvshade(data,totH,qH,qW)

% ssccall('data_set_number', data, 'stc_fill_factor', modPV.STC/modPV.Voc/modPV.Isc);
% ssccall('data_set_number', data, 'tilt',tilt);
% ssccall('data_set_number', data, 'azimuth', eleDim.azimuth);
% ssccall('data_set_number', data, 'length', modPV.module_length);
% ssccall('data_set_number', data, 'width', modPV.module_width);
% ssccall('data_set_number', data, 'row_space', totH);
% ssccall('data_set_number', data, 'mod_space', eleDim.gap_spacing);
% ssccall('data_set_number', data, 'slope_ns', 0);
% ssccall('data_set_number', data, 'slope_ew', 0);
% ssccall('data_set_number', data, 'mod_orient', self_shading_enable);
% ssccall('data_set_number', data, 'str_orient', self_shading_enable);
% ssccall('data_set_number', data, 'nmodx', modPV.nmodx);
% ssccall('data_set_number', data, 'nmody', modPV.nmody);
% ssccall('data_set_number', data, 'nrows', qH);
% ssccall('data_set_number', data, 'ncellx', modPV.ncellx);
% ssccall('data_set_number', data, 'ncelly', modPV.ncelly);
% ssccall('data_set_number', data, 'ndiode', modPV.ndiode);

ssccall('data_set_number', data, 'self_shading_enabled', 1);
ssccall('data_set_number', data, 'self_shading_length', modPV.module_length);
ssccall('data_set_number', data, 'self_shading_width', modPV.module_width);
ssccall('data_set_number', data, 'self_shading_mod_orient', modality);
ssccall('data_set_number', data, 'self_shading_str_orient', eleDim.string_orientation);
ssccall('data_set_number', data, 'self_shading_cellx', modPV.ncellx);
ssccall('data_set_number', data, 'self_shading_celly', modPV.ncelly);
ssccall('data_set_number', data, 'self_shading_ndiode', modPV.ndiode);
ssccall('data_set_number', data, 'self_shading_nmodx', modPV.mps);
ssccall('data_set_number', data, 'self_shading_nstrx', eleDim.nstrx*qW*2);
ssccall('data_set_number', data, 'self_shading_nmody', eleDim.nmody);
ssccall('data_set_number', data, 'self_shading_nrows', qH*2);
ssccall('data_set_number', data, 'self_shading_rowspace', totH);

