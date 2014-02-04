%--------------------------------------------------------------------------
% SUE v1.1
% SSC Utilizing Engine
% Scott Hummel, Jonathan Topham
% Last Revision: 8/12/13
%--------------------------------------------------------------------------
clc;
close all
clearvars -except finishdata finishdatacell

displaySAMresults=0;
displayConductorResults=0;
displayPlot_totH_Tilt=0;
% Call the correct folder
cd('C:\Users\cleanenergy\Documents\My Dropbox\F12_Clinic_ECE10_Inverter\MATLAB\ssc-sdk-0-9\languages\matlab')

% Load the SAM simulation core modules
SSC.ssccall('load');

% Create a data container to store all the variables
data = ssccall('data_create');

% Load CEC module database
if (exist('finishdata','var')==0 || exist('finishdatacell','var')==0)
    load('Libraries\CEClibrary.mat');
    load('Libraries\CEClib_strings.mat');
end

% Search for Module Name
pv_module='Renesola Jiangsu JC300M-24-Ab'; % must be exact from library
mod_addr=(find(strcmp(pv_module,finishdatacell))/2+.5); %/2+.5 because counts both values

% % Search for Inverter Name (NOT Included yet)
% pv_inverter='SMA America: SC500CP-US 270V [CEC 2012]'; % must be exact from library
% inv_addr=(find(strcmp(pv_inverter,finishdatacell))/2+.5);

%%
% Simulation Selection Parameters
inverter_model = 0;             % Inverter model specifier,
% 0=spe, 1=sandia

module_model = 1;               % Photovoltaic module_model model specifier
% 0=spe, 1=cec, 2=6par_user, 3=snl

temp_corr_model = 0;            % Cell temperature model,
% 0=noct, 1=mc
track_mode=0;                   % Tracking mode: 0=fixed, 1=1axis, 2=2axis, 3=azi

irrad_model = 0;                % 0=beam & diffuse, 1=total & beam
sky_model = 2;                  % 0=isotropic, 1=hkdr, 2=perez
mismatch_model = 1;             % 0=disable, 1=enable
self_shading_enable = 0;        % 0=disable, 1=enable


% Environmental Parameters
TMY3_File_Location= 'C:\Users\cleanenergy\Documents\My Dropbox\F12_Clinic_ECE10_Inverter\Weather Data\724075TY.csv';
% Set TMY3 file location
ssccall('data_set_string', data, 'file_name', TMY3_File_Location);
%% WF Reader
WF=WFreader(data);
%%

wf_albedo = 1;                  % Uses albedo from weather file if provided(yes)
modPV.Tmin= -14;                % ASHRAE Mean Low Temp
modPV.Ta = 37;                  % ASHRAE High Ambient Temperature

% Derates
soil(1:12)=0.95;                % Monthly Soiling Derate
dc_derate=0.98;                 % DC Power Derate
ac_derate=0.99;                 % Interconnection AC Derate

% Wiring
element.string_orientation=0;           % 0=vertical, 1=horizontal

%% *** only Modality if statement ***
% Orientation
element.modality=0;                     % 0=portrait, 1=landscape 

if element.modality ==0 % PORTRAIT
    eleDim.nmody=2;
    eleDim.nstrx=2;
else                    % LANDSCAPE
    eleDim.nmody=4;
    eleDim.nstrx=1;
end
%%
element.azimuth=180;                    % Azimuth, 0=N, 90=E, 180=S, 270=W
element.gap_spacing= .1;                % Spacing between modules

% Heat transfer CEC variables
heat_transfer = 1;              % 0=module, 1=array;
mounting_orientation =1;        % 0= do not impede flow, 1=vertical, 2=horizontal supports
cec_height=0;                   % Array mounting height (0=one, 1=two)
mounting_config=0;              % (0=rack, 1=flush, 2=intergrated, 3=gap)
standoff=6;                     % 6 means rack mounted

% SANDIA Inverter Parameters
% SMA America: SC500CP-US 270V [CEC 2012]
inv.ac_voltage=270;
inv.paco=514000;                    % Max AC power rating (W)
inv.pdco=525258.202644486;          % DC input power at which AC-power rating is achieved (W)
inv.vdco=533.477916666667;          % DC input voltage for the rated ac-power rating (V)
inv.pso=1658.88177526711;           % DC power required to enable the inversion process (Wdc)
inv.c0=-2.60289802779116*10^(-8);   % Curvature between ac-power and dc-power at ref (1/W)
inv.c1=1.79159664133963*10^(-5);    % Coefficient of Pdco variation with DC input voltage (1/V)
inv.c2=2.61712986452631*10^(-3);    % Coefficient of Pso variation with DC input voltage (1/V)
inv.c3=1.44910647847469*10^(-5);    % Coefficient of Co variation with DC input voltage (1/V)
inv.pnt=307.9;                      % AC power consumed by inverter at night (Wac)

% Inverter constraints
inv.vdcmax=1000;                    % Maximum DC input operating voltage (V)
inv.idcmax=1250;                    % Max AC current (A)
inv.mppt_low=449;                   % Minimum input voltage (MPPT)
inv.mppt_hi=850;                    % Maximum input voltage (MPPT)
inv.DC_AC.target= 1.33;
inv.num_inverters=16;               % Number of inverters
inv.DC_AC.variance=.05;

% Module Manual Entry
modPV.module_length=1.956;                      % Module length (m)
modPV.ncellx=6;                                 % Number of cells on top

% CEC Module Parameters
modPV.noct=       finishdata(1,mod_addr);       % Nominal operating cell temperature (C)
modPV.mod_area=   finishdata(2,mod_addr);       % Module Area (m^2)
modPV.cells=      finishdata(3,mod_addr);       % Number of cells in series
modPV.Isc=        finishdata(4,mod_addr);       % Short circuit current (A)
modPV.Voc=        finishdata(5,mod_addr);       % Open circuit voltage (V)
modPV.Imp=        finishdata(6,mod_addr);       % Maximum power point current (A)
modPV.Vmp=        finishdata(7,mod_addr);       % Max power voltage (V)
modPV.alpha_sc=   finishdata(8,mod_addr);       % Isc temperature coefficient (A/C)
modPV.beta_oc=   -finishdata(9,mod_addr);       % Voc temperature coefficient (V/C)
modPV.nonideal=   finishdata(10,mod_addr);      % Nonideality factor a
modPV.light_I=    finishdata(11,mod_addr);      % Light current (A)
modPV.sat_I=      finishdata(12,mod_addr);      % Saturation Current (A)
modPV.r_s=        finishdata(13,mod_addr);      % Series resistance (ohms)
modPV.r_sh=       finishdata(14,mod_addr);      % Shunt resistance (ohms)
modPV.t_adjust=   finishdata(15,mod_addr);      % Temperature coefficient adjustment (%)
modPV.gamma_r=    finishdata(16,mod_addr);      % Pmax temperature coefficient (%/C)
modPV.module_width=modPV.mod_area/modPV.module_length;      % Module width (m)
modPV.ncelly=modPV.cells/modPV.ncellx;                      % Number of cells longways
modPV.ndiode=modPV.ncellx/2;                          % Number of bypass diodes
modPV.type=       finishdatacell{2,mod_addr};   % Module Type
modPV.module_string=finishdatacell{1,mod_addr}; % Module Name
% celltype=type2celltypebool(type);       % Module type index (6par)

% Calculating modules per string and max power voltage
modPV.mps= floor(inv.vdcmax/(modPV.Voc-(modPV.beta_oc*(25-modPV.Tmin))));
modPV.vmpmax = modPV.mps * (modPV.Vmp - ((modPV.gamma_r/modPV.Imp) * (25 - modPV.Ta))); %used for VD calc of string wiring

% Rack Dimensions
eleDim=rackDim(element,modPV);

% Determine AC system size
ac_system_size=inv.paco*inv.num_inverters;
% Calculating the DC size of array
dc_system_size=inv.DC_AC.target*ac_system_size;
strings_parallel=floor(dc_system_size/(modPV.Vmp*modPV.Imp*modPV.mps));
dc_system_size=strings_parallel*(modPV.Vmp*modPV.Imp*modPV.mps);
% Determining number of tables

% table Watts
tableDCW=eleDim.modperTable*modPV.Imp*modPV.Vmp;
% required DC size
DCsize_quad=inv.pdco*inv.DC_AC.target;
tablesPerQuad=DCsize_quad/tableDCW;
eleDim.tablesPerQuad.Range=ceil(tablesPerQuad*(1-inv.DC_AC.variance)):floor(tablesPerQuad*(1+inv.DC_AC.variance));

% Combiner box configuration
%% BEGIN SSC

%% Begin Performance Model

ssccall('data_set_number', data, 'use_wf_albedo', wf_albedo);
ssccall('data_set_number', data, 'irrad_mode', irrad_model);
ssccall('data_set_number', data, 'sky_model', sky_model);
ssccall('data_set_number', data, 'ac_derate', ac_derate);
ssccall('data_set_number', data, 'modules_per_string', modPV.mps);
ssccall('data_set_number', data, 'strings_in_parallel', strings_parallel);
ssccall('data_set_number', data, 'inverter_count', inv.num_inverters);
ssccall('data_set_number', data, 'enable_mismatch_vmax_calc', mismatch_model);

% Subarray1
ssccall('data_set_number', data, 'subarray1_azimuth', element.azimuth);
ssccall('data_set_number', data, 'subarray1_track_mode', track_mode);

% Shading factors
ssccall('data_set_array',  data, 'subarray1_soiling', soil);
ssccall('data_set_number', data, 'subarray1_derate', dc_derate);

% Other Subarray Disabled
ssccall('data_set_number', data, 'subarray2_tilt', 0);
ssccall('data_set_number', data, 'subarray3_tilt', 0);
ssccall('data_set_number', data, 'subarray4_tilt', 0);

% Photovoltaic module model
ssccall('data_set_number', data, 'module_model', module_model);

% SPE
%----------------------------------------------------------------------
% CEC Parameters
if module_model==1
    ssccall('data_set_number', data, 'cec_area', modPV.mod_area);
    ssccall('data_set_number', data, 'cec_a_ref', modPV.nonideal);
    ssccall('data_set_number', data, 'cec_adjust', modPV.t_adjust);
    ssccall('data_set_number', data, 'cec_alpha_sc', modPV.alpha_sc);
    ssccall('data_set_number', data, 'cec_beta_oc', modPV.beta_oc);
    ssccall('data_set_number', data, 'cec_gamma_r', modPV.gamma_r);
    ssccall('data_set_number', data, 'cec_i_l_ref', modPV.light_I);
    ssccall('data_set_number', data, 'cec_i_mp_ref', modPV.Imp);
    ssccall('data_set_number', data, 'cec_i_o_ref', modPV.sat_I);
    ssccall('data_set_number', data, 'cec_i_sc_ref', modPV.Isc);
    ssccall('data_set_number', data, 'cec_n_s', modPV.cells);
    ssccall('data_set_number', data, 'cec_r_s', modPV.r_s);
    ssccall('data_set_number', data, 'cec_r_sh_ref', modPV.r_sh);
    ssccall('data_set_number', data, 'cec_t_noct', modPV.noct);
    ssccall('data_set_number', data, 'cec_v_mp_ref', modPV.Vmp);
    ssccall('data_set_number', data, 'cec_v_oc_ref', modPV.Voc);
    ssccall('data_set_number', data, 'cec_temp_corr_mode', temp_corr_model);
    ssccall('data_set_number', data, 'cec_standoff', standoff);
    ssccall('data_set_number', data, 'cec_height', cec_height);
    ssccall('data_set_number', data, 'cec_mounting_config', mounting_config);
    ssccall('data_set_number', data, 'cec_heat_transfer', heat_transfer);
    ssccall('data_set_number', data, 'cec_mounting_orientation', mounting_orientation);
    ssccall('data_set_number', data, 'cec_gap_spacing', element.gap_spacing);
    ssccall('data_set_number', data, 'cec_module_length', modPV.module_length);
    ssccall('data_set_number', data, 'cec_module_width', modPV.module_width);
end
% Inverter Model
ssccall('data_set_number', data, 'inverter_model', inverter_model);

if inverter_model==0

else
    % SANDIA INVERTER MODEL Parameters
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
end

eleDim.tilt= 30;
eleDim.totH= 10;
tiltend=0;
totHend=0;
n=0;
% while (eleDim.tilt~=tiltend && eleDim.totH~=totHend)
% %% Conventional System Optimization
% 
% n=n+1;
% disp(n);
% %% totH optimization
% % Tilting and totH 
% tilt= 25:1:35;
% totH= 8:.1:12;
% [eleDim]=totH_Optim(data,final,tilt,totH,eleDim.totW,displayPlot_totH_Tilt);
% 
% tiltend=eleDim.tilt;
% totHend=eleDim.totH;
% end
% 6 parameter module gives hourly voltage and current
% [data,modPV]=pv6parmodule(data,modPV,WF);
% Combiner boxes available to use with given array geometry
[CB]=PossibleCB(eleDim);
[final,finalCell] = ConventionalOptimization(modPV,inv,CB,eleDim,1);

% Set the optimal parameters for a complete simulation
ssccall('data_set_number', data, 'self_shading_rowspace', eleDim.totH);
ssccall('data_set_number', data, 'subarray1_tilt', eleDim.tilt);

% Create the pvsamv1 module
module = ssccall('module_create', 'pvsamv1');

% Run the module
ok=ssccall('module_exec', module, data);
% run pv6parmodule must be after pvsam1

%% SSC Retrieve

% Calculate total area
% inverterArea=2;

% Subarray 1
beam_shade=ssccall('data_get_array', data, 'hourly_subarray1_beam_shading_factor');
hourly_eff=ssccall('data_get_array', data, 'hourly_subarray1_modeff');
dc_voltage=ssccall('data_get_array', data, 'hourly_subarray1_dc_voltage');

ss_derate=ssccall('data_get_array', data, 'hourly_ss_derate');
ss_derate_diff=ssccall('data_get_array', data, 'hourly_ss_diffuse_derate');
ss_derate_reflect=ssccall('data_get_array', data, 'hourly_ss_reflected_derate');
ss_derate_diff_loss=ssccall('data_get_array', data, 'hourly_ss_diffuse_loss');

% Array output hourly
hourly.dc.net=ssccall('data_get_array', data, 'hourly_dc_net');
hourly.dc.gross=ssccall('data_get_array', data, 'hourly_dc_gross');
hourly.ac.net=ssccall('data_get_array', data, 'hourly_ac_net');
hourly.ac.gross=ssccall('data_get_array', data, 'hourly_ac_gross');

% Array output monthly
monthly.dc.net=ssccall('data_get_array', data, 'monthly_dc_net');
monthly.ac.net=ssccall('data_get_array', data, 'monthly_ac_net');

% Array output yearly
yearly.dc.net=ssccall('data_get_number', data, 'annual_dc_net');
yearly.dc.gross=ssccall('data_get_number', data, 'annual_dc_gross');
yearly.ac.net=ssccall('data_get_number', data, 'annual_ac_net');
yearly.ac.gross=ssccall('data_get_number', data, 'annual_ac_gross');

% Annual performance
Annual_performance=ssccall('data_get_number', data, 'annual_performance_factor');

% Nameplate DC
DC_Nameplate=ssccall('data_get_number', data, 'nameplate_dc_rating');
%% End Performance Model

%% System Costs
% 
% fixed.land=30000; %per Acre
% dpw.inverter = .30;
% dpw.module = .30;
% dpw.racking= .25;
% costs.BoS.hard= dpw.racking*10000000; %input total DC kW

%% Begin Financial Model


%% END SSC


% hourly_current=((hourly_ac_net*1000)./dc_voltage)/inv.num_inverters; %
% NOT ANYMORE!!
if displaySAMresults==1;
    
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
    plot(y2,modPV.dc_current);
    y={'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    xlabel('Month');
    ylabel('DC Current (A)');
    title('DC Module Current Over a Year');
    
    subplot(3,1,3)
    plot(y2,modPV.dc_voltage);
    y={'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    xlabel('Month');
    ylabel('DC Voltage (V)');
    title('DC Module Voltage Over a Year');
    
    
    % Sets axis for hourly plots and monthly plots
    y={'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
    
    % Plot the monthly DC output vs monthly ac output
    figure(2)
    stem(monthly_dc_net);
    set(gca, 'XTick',1:12, 'XTickLabel',y);
    ylabel('kWh');
    xlabel('Month');
    title('Net DC and AC Output vs. Month');
    grid;
    hold all;
    stem(monthly_ac_net);
    legend('DC Net','AC Net');
    
    % Plot Hourly Voltage
    figure(3)
    y2=linspace(0,12,8760);
    subplot(3,1,1)
    plot(y2,dc_voltage);
    grid;
    line([0 12],[inv.mppt_hi,inv.mppt_hi],'Color','red')
    line([0 12],[inv.mppt_low,inv.mppt_low],'Color','green')
    title('Hourly Voltage Output Over a Year');
    xlabel('Month')
    ylabel('Volts (V)');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Plot Hourly PV current
    subplot(3,1,2)
    plot(y2,hourly_current);
    grid;
    line([0 12],[inv.idcmax,inv.idcmax],'Color','red');
    title('Hourly PV Current Output Over a Year Per Inverter');
    xlabel('Month');
    ylabel('Amps (A)');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Plot Hourly AC output over a year per inverter
    subplot(3,1,3)
    plot(y2,hourly_ac_net/inv.num_inverters);
    grid;
    title('Hourly AC Output Over a Year Per Inverter');
    line([0 12],[inv.paco/1000,inv.paco/1000],'Color','red');
    xlabel('Month')
    ylabel('kWh');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Self Shading Derate
    figure(4)
    subplot(4,1,1)
    plot(y2,ss_derate);
    grid;
    title('Self Shading Derate');
    xlabel('Month');
    ylabel('kWh');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Self Shading Derate Diffuse
    subplot(4,1,2)
    plot(y2,ss_derate_diff);
    grid;
    title('Self Shading Derate Diffuse');
    xlabel('Month');
    ylabel('Volts (V)');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Self Shading Derate Reflect
    subplot(4,1,3)
    plot(y2,ss_derate_reflect);
    grid;
    title(' Self Shading Derate Reflect');
    xlabel('Month');
    ylabel('Amps (A)');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Self Shading Derate Diffuse Loss
    subplot(4,1,4)
    plot(y2,ss_derate_diff_loss);
    grid;
    title('Self Shading Derate Diffuse Loss');
    xlabel('Month');
    ylabel('Amps (A)');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Plot clipping losses and inverter inefficiency
    figure(5)
    plot(y2,(hourly_dc_net-hourly_ac_gross));
    grid;
    ylabel('kWh');
    xlabel('Month');
    title('Clipping Losses');
    set(gca, 'XTick',0:11, 'XTickLabel',y);
    
    % Display some information
    X=['Annual Gross AC Output: ', num2str(yearly_ac_gross),' kWh'];
    disp(X);
    X=['AC Size: ', num2str(ac_system_size),' W'];
    disp(X);
    X=['DC Size: ', num2str(dc_size),' W'];
    disp(X);
    X=['Modules per String: ',num2str(mps)];
    disp(X);
    X=['Strings in Parallel: ',num2str(strings_parallel)];
    disp(X);
    X=['Number of Inverters: ',num2str(inv.num_inverters)];
    disp(X);
    X=['Inefficiency and Clipping Losses: ',num2str(sum(hourly_dc_net-hourly_ac_gross)),' kWh'];
    disp(X);
    ssccall('unload');
    
end