
%--------------------------------------------------------------------------
% Six Par Mod Solve Model
% Scott Hummel
% Last Revision: 7/30/13
%--------------------------------------------------------------------------


%% WF Reader

% Set TMY3 file location 
ssccall('data_set_string', data, 'file_name', TMY3_File_Location);

% Create the wfreader module and run it
module = ssccall('module_create', 'wfreader');
ssccall('module_exec', module, data);

% Get wind direction data
wdir=ssccall('data_get_array',data,'wdir');

%% PV6PARMOD

% Set Array elements
poa_beam = ssccall('data_get_array', data, 'hourly_beam');
poa_skydiff = ssccall('data_get_array', data, 'hourly_glob_horiz_rad');
poa_gnddiff = ssccall('data_get_array', data, 'hourly_diff');
tdry = ssccall('data_get_array', data, 'hourly_ambtemp');
wspd = ssccall('data_get_array', data, 'hourly_windspd');
sun_zen = ssccall('data_get_array', data, 'hourly_sol_zen');
incidence = ssccall('data_get_array', data, 'hourly_sol_alt');
surf_tilt = ssccall('data_get_array', data, 'hourly_subarray1_surf_tilt');
site_elevation = 40; 

% Set array parameters
ssccall('data_set_array', data, 'poa_beam', poa_beam*1000); 
ssccall('data_set_array', data, 'poa_skydiff', poa_skydiff*1000);  
ssccall('data_set_array', data, 'poa_gnddiff', poa_gnddiff*1000);  
ssccall('data_set_array', data, 'tdry', tdry);  
ssccall('data_set_array', data, 'wspd', wspd);  
ssccall('data_set_array', data, 'sun_zen', sun_zen);  
ssccall('data_set_array', data, 'incidence', incidence); 
ssccall('data_set_array', data, 'surf_tilt', surf_tilt);  

% Set number parameters
ssccall('data_set_number', data, 'elev', site_elevation);
ssccall('data_set_number', data, 'area', mod_area);
ssccall('data_set_number', data, 'Vmp', Vmp);  
ssccall('data_set_number', data, 'Imp', Imp);  
ssccall('data_set_number', data, 'Voc', Voc);  
ssccall('data_set_number', data, 'Isc', Isc);  
ssccall('data_set_number', data, 'alpha_isc', alpha_sc); 
ssccall('data_set_number', data, 'beta_voc', beta_oc);  
ssccall('data_set_number', data, 'gamma_pmp', gamma_r); 
ssccall('data_set_number', data, 'tnoct', noct);  
ssccall('data_set_number', data, 'a', nonideal); 
ssccall('data_set_number', data, 'Il', light_I);  
ssccall('data_set_number', data, 'Io', sat_I);  
ssccall('data_set_number', data, 'Rs', r_s); 
ssccall('data_set_number', data, 'Rsh', r_sh);  
ssccall('data_set_number', data, 'Adj', t_adjust);  
ssccall('data_set_number', data, 'standoff', 6);  
ssccall('data_set_number', data, 'height', 0);  
ssccall('data_set_array',  data, 'wdir', wdir);  

% Create and run the module
module = ssccall('module_create', 'pv6parmod');
ssccall('module_exec', module, data);

% Get cell temperature, dc current, and dc voltage
t_cell=ssccall('data_get_array', data, 'tcell');
dc_current=ssccall('data_get_array', data, 'dc_current');
dc_voltages=ssccall('data_get_array', data, 'dc_voltage');

% Plot Results
figure(2)
subplot(3,1,1)
y2=linspace(0,12,8760);
plot(y2,t_cell);
y={'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
set(gca, 'XTick',0:11, 'XTickLabel',y);
xlabel('Month');
ylabel('Operating Temperature (C)');
title('Cell Operating Temperature Over a Year');

subplot(3,1,2)
plot(y2,dc_current);
y={'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
set(gca, 'XTick',0:11, 'XTickLabel',y);
xlabel('Month');
ylabel('DC Current (A)');
title('DC Module Current Over a Year');

subplot(3,1,3)
plot(y2,dc_voltages);
y={'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
set(gca, 'XTick',0:11, 'XTickLabel',y);
xlabel('Month');
ylabel('DC Voltage (V)');
title('DC Module Voltage Over a Year');








