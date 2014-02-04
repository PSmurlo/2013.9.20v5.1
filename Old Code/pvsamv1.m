
%--------------------------------------------------------------------------
% PV SAM Version 1 Model
% Scott Hummel
% Last Revision: 7/31/13
%--------------------------------------------------------------------------

close all;
clear all;

% Load the SAM simulation core modules
SSC.ssccall('load');

% Create a data container to store all the variables
data = ssccall('data_create');

% System Parameters
ac_derate=0.99;                 % Interconnection AC Derate
angle=25;                       % Tilt angle in degrees
azimuth=180;                    % Azimuth, 0=N, 90=E, 180=S, 270=W
soil(1:12)=0.95;                % Monthly Soiling Derate
track_mode=0;                   % Tracking mode: 0=fixed, 1=1axis, 2=2axis, 3=azi
dc_derate=0.95;                 % DC Power Derate
ac_system_size=10000000;        % System size in W
AC_DC_ratio=1.1;                % DC/AC ratio of the system

% Module Parameters
module=1;                       % Photovoltaic module model specifier 
                                % 0=spe, 1=cec, 2=6par_user, 3=snl

a=1.7482;                       % Nonideality factor a
cec_adjust=6.8013;              % Temperature coefficient adjustment (%)
cec_alpha_sc=0.0034;            % Isc temperature coefficient (A/C)
module_area=1.94;               % Module area (m^2)
cec_beta_oc=-0.134;             % Voc temperature coefficient (V/C)
cec_gamma_r=-0.4;               % Pmax temperature coefficient (%/C)
cec_height=0;                   % Array mounting height (0=one, 1=two)
light_current=8.69;             % Light current (A)
Imp=8.2;                        % Maximum power point current (A)
sat_current=6.39*10^(-11);      % Saturation Current (A)
Isc=8.69;                       % Short circuit current (A)
module_length=1.956;            % Module length (m)
module_width=0.992;             % Module width (m)
mounting_config=0;              % (0=rack, 1=flush, 2=intergrated, 3=gap)
cells_series=72;                % Number of cells in series
series_resistance=0.3573;       % Series resistance (ohms)
shunt_resistance=539.73;        % Shunt resistance (ohms)
noct=45;                        % Nominal operating cell temperature (C)
Vmp=36.6;                       % Max power voltage (V)
Voc=44.8;                       % Open circuit voltage (V)
standoff=6;                     % 6 means rack mounted
cec_temp_corr_mode=0;           % Cell temperature model , (0=noct, 1=mc)
Tmin= -14;                      % ASHRAE Mean Low Temp

% Inverter Parameters
inverter_model=1;               % Inverter model specifier, 0=spe, 1=sandia
  
% SMA America: SC500CP-US 270V [CEC 2012]
ac_voltage=270;
paco=514000;                    % Max AC power rating (W)
pdco=525258.202644486;          % DC input power at which AC-power rating is achieved (W)
vdco=533.477916666667;          % DC input voltage for the rated ac-power rating (V)
pso=1658.88177526711;           % DC power required to enable the inversion process (Wdc)
c0=-2.60289802779116*10^(-8);   % Curvature between ac-power and dc-power at ref (1/W)
c1=1.79159664133963*10^(-5);    % Coefficient of Pdco variation with DC input voltage (1/V)
c2=2.61712986452631*10^(-3);    % Coefficient of Pso variation with DC input voltage (1/V)
c3=1.44910647847469*10^(-5);    % Coefficient of Co variation with DC input voltage (1/V)
pnt=307.9;                      % AC power consumed by inverter at night (Wac)
vdcmax=1000;                    % Maximum DC input operating voltage (V)    
idcmax=1250;                    % Max AC current (A)
mppt_low=449;
mppt_hi=850;

% Calculating modules per string
mps= floor(vdcmax/(Voc-(cec_beta_oc*(25-Tmin))));

% Calculating number of strings neeeded
dc_size=ac_system_size*AC_DC_ratio;
strings_parallel=floor(dc_size/(Vmp*Imp*mps));

% Determine number of inverters needed
num_inverters=ceil(ac_system_size/paco);


% Sets the inverter model
ssccall('data_set_number', data, 'inverter_model', inverter_model);

if inverter_model==0
    
    inv_eff=98;                 % Single point inverter effiency (%)
    power_ac=514000;            % Rated Inverter Power (Wac)
    
    ssccall('data_set_number', data, 'inv_spe_efficiency', inv_eff);
    ssccall('data_set_number', data, 'inv_spe_power_ac', power_ac);
else
    
    % SANDIA INVERTER MODEL Parameters
    ssccall('data_set_number', data, 'inv_snl_c0', c0); 
    ssccall('data_set_number', data, 'inv_snl_c1', c1);
    ssccall('data_set_number', data, 'inv_snl_c2', c2);
    ssccall('data_set_number', data, 'inv_snl_c3', c3);
    ssccall('data_set_number', data, 'inv_snl_paco', paco);
    ssccall('data_set_number', data, 'inv_snl_pdco', pdco);
    ssccall('data_set_number', data, 'inv_snl_pnt', pnt);
    ssccall('data_set_number', data, 'inv_snl_pso', pso);
    ssccall('data_set_number', data, 'inv_snl_vdco', vdco);
    ssccall('data_set_number', data, 'inv_snl_vdcmax', vdcmax);
end


% Setup the system parameters
%--------------------------------------------------------------------------
ssccall('data_set_string', data, 'weather_file', '../../examples/724075TY.csv');          
ssccall('data_set_number', data, 'ac_derate', ac_derate);  
ssccall('data_set_number', data, 'modules_per_string', mps);    
ssccall('data_set_number', data, 'strings_in_parallel', strings_parallel);                                 
ssccall('data_set_number', data, 'subarray1_tilt', angle);                    
ssccall('data_set_number', data, 'subarray1_azimuth', azimuth);
ssccall('data_set_array',  data,  'subarray1_soiling', soil);
ssccall('data_set_number', data, 'subarray1_track_mode', track_mode);
ssccall('data_set_number', data, 'subarray1_derate', dc_derate);

% Disabled by setting them to zero
ssccall('data_set_number', data, 'subarray2_tilt', 0);
ssccall('data_set_number', data, 'subarray3_tilt', 0);
ssccall('data_set_number', data, 'subarray4_tilt', 0);

% Photovoltaic module model specifier 0=spe, 1=cec, 2=6par_user, 3=snl
ssccall('data_set_number', data, 'module_model', module);    
ssccall('data_set_number', data, 'cec_a_ref', a);
ssccall('data_set_number', data, 'cec_adjust', cec_adjust);
ssccall('data_set_number', data, 'cec_alpha_sc', cec_alpha_sc);
ssccall('data_set_number', data, 'cec_area', module_area);
ssccall('data_set_number', data, 'cec_beta_oc', cec_beta_oc);
ssccall('data_set_number', data, 'cec_gamma_r', cec_gamma_r);
ssccall('data_set_number', data, 'cec_height', cec_height);
ssccall('data_set_number', data, 'cec_i_l_ref', light_current);
ssccall('data_set_number', data, 'cec_i_mp_ref', Imp);
ssccall('data_set_number', data, 'cec_i_o_ref', sat_current);
ssccall('data_set_number', data, 'cec_i_sc_ref', Isc);
ssccall('data_set_number', data, 'cec_module_length', module_length);
ssccall('data_set_number', data, 'cec_module_width', module_width);
ssccall('data_set_number', data, 'cec_mounting_config', mounting_config);
ssccall('data_set_number', data, 'cec_n_s', cells_series);
ssccall('data_set_number', data, 'cec_r_s', series_resistance);
ssccall('data_set_number', data, 'cec_r_sh_ref', shunt_resistance);
ssccall('data_set_number', data, 'cec_standoff', standoff);
ssccall('data_set_number', data, 'cec_t_noct', noct);
ssccall('data_set_number', data, 'cec_temp_corr_mode', cec_temp_corr_mode);
ssccall('data_set_number', data, 'cec_v_mp_ref', Vmp);
ssccall('data_set_number', data, 'cec_v_oc_ref', Voc);

% Number of inverters
ssccall('data_set_number', data, 'inverter_count', num_inverters);

% Run the module
%--------------------------------------------------------------------------
% Create the pvsamv1 module
module = ssccall('module_create', 'pvsamv1');
% Run the module
ssccall('module_exec', module, data);

% Get monthly dc and ac output
dc = ssccall('data_get_array', data, 'monthly_dc_net');
ac = ssccall('data_get_array', data, 'monthly_ac_net');

% Get annual AC output in kWh
annual_ac = ssccall('data_get_number', data, 'annual_ac_net');

% Get AC power generated over a year in kWh
ac_net = ssccall('data_get_array', data, 'hourly_ac_net');

% Plot the monthly dc output vs monthly ac output
y={'Jan', 'Feb', 'Mar', 'Apr', 'May','June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
subplot(2,1,1)
plot(dc);
set(gca, 'XTick',1:12, 'XTickLabel',y);
ylabel('kWh');
xlabel('Month');
title('Net DC and AC Output vs. Month');
grid;
hold all;
plot(ac);
legend('DC','AC');

% Plot Hourly AC output in kWh
subplot(2,1,2)
y2=linspace(1,12,8760);
plot(y2,ac_net);
grid;
title('Annual AC Output Over a Year');
xlabel('Month')
ylabel('kWh');

% Display some information 
X=['Annual AC Output: ', num2str(annual_ac),' kWh'];
disp(X);
X=['Modules per String: ',num2str(mps)];
disp(X);
X=['Strings in Parallel: ',num2str(strings_parallel)];
disp(X);
X=['Number of Inverters: ',num2str(num_inverters)];
disp(X);







