%% Abstract
% The constraints of designing a PV array often are not engineering
% related, rather financial. When building a utility scale PV array, there
% is typicially a large plot of land of a fixed size on which a PV array is
% built. This PV array must produce electricity at a lower price than
% existing generation for that location. The price of this electricity must
% be calculated, and to do so the Net Present Value (NPV) of the system is
% calculated after the system lifecycle which is typicially 25 years.
% Traditionally, since solar power has been very expensive, the "ideal"
% tilt angle and inter-row spacing were chosen which maximized power
% production. The major price drivers of this study are the cost of
% conductors, associated raceway and labor costs of conductors, and price of aquiring and
% preparing land. This optimization is done by using System Advisor Model
% (SAM) and it's recently released Software Development Kit (SDK) called
% SAM Simulation Core. (SSC)
% This paper explains the processes and trade offs of optimizing in terms  
% of NPV rather than energy production (kWh) along with
% documenting the results of this optimization and explaining the processes
% behind the optimization code.

%% Introduction

%% Inter-Row Shading and Tilt angle
% Inter-Row shading is a great concern when developing a PV project. Decreasing your inter-row spacing exponentionally reduces your system output. It can
% create very high system losses if not closely investigated. Inter-row
% shading is inversely related to the tilt angle of the array. As the tilt
% angle approaches zero, the inter row spacing can also approach zero without creating losses, but
% this is not how utility scales are built in today's world for a
% multitude of reasons. The Tilt angle of the array is also closely related
% to the system output, with the tilt angle associated with the optimial
% power output being close to the lattitude of the location. This high tilt
% angle requires extreme inter-row spacing to be necessary to reduce the
% associated shading. Because of this, a large window for appropriate tilt
% angles and associated spacing exists and must be refined to a specific
% optimal case.

%% Array Area
% The area which confines an array is often fixed, does not face
% south, is not flat, and is often not square, along with it possibly
% having obstructions which cannot be removed. The model we have built
% assumes a square array with no obstructions for simplicity and because 
% most utility scale arrays are built in large enough locations to 
% eliminate these. There is room for implementing grade, which can 
% sometimes reduce inter-row spacing.
% 

addpath('Voltage Drop','NEC','SAM functions','Draw Functions');
load('sizesAWG.mat')
%% Global declaration
global usingSSC
usingSSC=0;
global modality
modality=0;                 %portrait=0;
global Tmin
Tmin= -14;                  % ASHRAE Mean Low Temp
global Ta
Ta = 37;                    % ASHRAE High Ambient Temperature


%% Load Module Data
% Load CEC module database
if (exist('inverterData','var')==0  || exist('inverterNames','var')==0 ||...
        exist('moduleData','var')==0    || exist('moduleNames','var')==0)
    load('CECSandiaLibraries.mat');
end

% Search for Module and Inverter by Name from Library
moduleProductName='Renesola Jiangsu JC300M-24-Ab';
inverterProductName='SMA America: SC500CP-US 270V [CEC 2012]';
moduleAddress=find(strcmp(moduleProductName,moduleNames));
inverterAddress=(find(strcmp(inverterProductName,inverterNames)));

% SANDIA Inverter Model Parameters
global inv
inv.ac_voltage= inverterData(1,inverterAddress);
inv.paco=       inverterData(2,inverterAddress); % Max AC power rating (W)
inv.pdco=       inverterData(3,inverterAddress); % DC input power at which AC-power rating is achieved (W)
inv.vdco=       inverterData(4,inverterAddress); % DC input voltage for the rated ac-power rating (V)
inv.pso=        inverterData(5,inverterAddress); % DC power required to enable the inversion process (Wdc)
inv.c0=         inverterData(6,inverterAddress); % Curvature between ac-power and dc-power at ref (1/W)
inv.c1=         inverterData(7,inverterAddress); % Coefficient of Pdco variation with DC input voltage (1/V)
inv.c2=         inverterData(8,inverterAddress); % Coefficient of Pso variation with DC input voltage (1/V)
inv.c3=         inverterData(9,inverterAddress); % Coefficient of Co variation with DC input voltage (1/V)
inv.pnt=        inverterData(10,inverterAddress); % AC power consumed by inverter at night (Wac)

% Inverter constraints
inv.vdcmax=     inverterData(11,inverterAddress); % Maximum DC input operating voltage (V)
inv.idcmax=     inverterData(12,inverterAddress); % Max AC current (A)
inv.mppt_low=   inverterData(13,inverterAddress); % Minimum input voltage (MPPT)
inv.mppt_hi=    inverterData(14,inverterAddress); % Maximum input voltage (MPPT)
inv.DC_AC.target= 1.00;
inv.num_inverters=20; % Number of inverters
inv.DC_AC.variance=.05;


% CEC Module Model Parameters
global modPV
% Module Manual Entry
modPV.module_length=1.956;                      % Module length (m)
modPV.ncellx=6;                                 % Number of cells on top

modPV.noct=       moduleData(1,moduleAddress);        % Nominal operating cell temperature (C)
modPV.mod_area=   moduleData(2,moduleAddress);        % Module Area (m^2)
modPV.cells=      moduleData(3,moduleAddress);        % Number of cells in series
modPV.Isc=        moduleData(4,moduleAddress);        % Short circuit current (A)
modPV.Voc=        moduleData(5,moduleAddress);        % Open circuit voltage (V)
modPV.Imp=        moduleData(6,moduleAddress);        % Maximum power point current (A)
modPV.Vmp=        moduleData(7,moduleAddress);        % Max power voltage (V)
modPV.alpha_sc=   moduleData(8,moduleAddress);        % Isc temperature coefficient (A/C)
modPV.beta_oc=   -moduleData(9,moduleAddress);        % Voc temperature coefficient (V/C)
modPV.nonideal=   moduleData(10,moduleAddress);       % Nonideality factor a
modPV.light_I=    moduleData(11,moduleAddress);       % Light current (A)
modPV.sat_I=      moduleData(12,moduleAddress);       % Saturation Current (A)
modPV.r_s=        moduleData(13,moduleAddress);       % Series resistance (ohms)
modPV.r_sh=       moduleData(14,moduleAddress);       % Shunt resistance (ohms)
modPV.t_adjust=   moduleData(15,moduleAddress);       % Temperature coefficient adjustment (%)
modPV.gamma_r=    moduleData(16,moduleAddress);       % Pmax temperature coefficient (%/C)
modPV.module_width=modPV.mod_area/modPV.module_length;% Module width (m)
modPV.ncelly=modPV.cells/modPV.ncellx;                % Number of cells longways
modPV.ndiode=modPV.ncellx/2;                          % Number of bypass diodes
modPV.type=       moduleType{moduleAddress};   % Module Type
modPV.module_string=moduleProductName; % Module Name
modPV.STC = modPV.Vmp*modPV.Imp;
modPV.Vmpmax=604;
% if(ppc==0) % Percent per celcius * Not used only for reference *
%     modPV.mps = floor(inv.vdcmax / (modPV.Voc - (modPV.beta_oc * (25 - Tmin))));
% else % If the data is given in (V/C), use this equation to calculate MpS
%     modPV.mps = floor(inv.vdcmax /(modPV.Voc*(1+((-modPV.beta_oc)*(25-Tmin)/100))));
% end

% Heat transfer CEC variables
global CECheat
CECheat.standoff=6;                     % 6 means rack mounted
CECheat.cec_height=0;                   % Array mounting height (0=one, 1=two)
CECheat.mounting_config=0;              % (0=rack, 1=flush, 2=intergrated, 3=gap)
CECheat.heat_transfer = 1;              % 0=module, 1=array;
CECheat.mounting_orientation =1;        % 0= do not impede flow, 1=vertical, 2=horizontal supports

global possibleCBsizes
possibleCBsizes = 8:8:128; % sizes range from 8 strings/CB incremented by 8 up to 64

modPV.mps= floor(inv.vdcmax/(modPV.Voc-(modPV.beta_oc*(25-Tmin)))); % Module Per String

clear 'inverterData'
clear 'moduleData'
clear 'moduleNames'
clear 'inverterNames'

% Wire Prices %*omitted from inputs below*
load('wirePriceFt.mat');
global wirePriceCu
global wirePriceAl
% *Add 1kv Cu price*
wirePriceCu = wirePriceFtCu * 3.28; % dollars per kilometer
wirePriceAl = wirePriceFtAl * 3.28; % dollars per kilometer
clear 'wirePriceFtCu'
clear 'wirePriceFtAl'

global Tc % Temperature rating of the conductor
Tc =    [75, 75,NaN,NaN;
    75, 75, 75, 75];
global type % The material of the conductor
type =  [1,0,NaN,NaN;
    1,1,1,1];
% Resistances
% Conventional
global m2cbRes % Module to Combiner box Resistance
m2cbRes = resistLookup(Tc(1,1),type(1,1));
global cb2invRes % Combiner Box to Inverter Resistance
cb2invRes = resistLookup(Tc(1,2),type(1,2));
% Alencon
global m2spotRes % Module to SPOT Resistance
m2spotRes = resistLookup(Tc(2,1),type(2,1));
global spot2prefabRes % SPOT to prefab Resistance
spot2prefabRes = resistLookup(Tc(2,2),type(2,2));
global prefabRes % Prefab Resistance
prefabRes = resistLookup(Tc(2,3),type(2,3));
global trunk2gripRes % Trunk to GrIP Resistance
trunk2gripRes = resistLookup(Tc(2,4),type(2,4));

% Element Dimensions
global eleDim
eleDim=rackDim(); % Default array Dimensions
eleDim.azimuth=180;                    % Azimuth, 0=N, 90=E, 180=S, 270=W
eleDim.gap_spacing= .1;                % Spacing between modules
if eleDim.modality ==0 % PORTRAIT
    eleDim.nmody=2; %2x2 strings
    eleDim.nstrx=2;
else                    % LANDSCAPE
    eleDim.nmody=4; %4x1 strings
    eleDim.nstrx=1;
end
global tableW
tableW = eleDim.modperTable*modPV.STC;
global maxCost
maxCost = 10000000;
global maxVD
maxVD = 4;
%% SAM code for finding nominal voltage and current
% Load the SAM simulation core modules

% Simulation Selection Parameters
inverter_model = 1;             % Inverter model specifier,
% 0=spe, 1=sandia
module_model = 1;               % Photovoltaic module_model model specifier
% 0=spe, 1=cec, 2=6par_user, 3=snl
CECheat.temp_corr_model = 0;    % Cell temperature model,
% 0=noct, 1=mc
track_mode=0;                   % Tracking mode: 0=fixed, 1=1axis, 2=2axis, 3=azi
irrad_model = 0;                % 0=beam & diffuse, 1=total & beam
sky_model = 2;                  % 0=isotropic, 1=hkdr, 2=perez
mismatch_model = 0;             % 0=disable, 1=enable
self_shading_enable = 0;        % 0=disable, 1=enable
wf_albedo = 1;                  % Uses albedo from weather file if provided(yes)
eleDim.string_orientation=1;    % 0=vertical, 1=horizontal

% Derates
soil(1:12)=0.95;                % Monthly Soiling Derate
dc_derate=0.98;                 % DC Power Derate
ac_derate=0.99;                 % Interconnection AC Derate

eleDim.tilt=25; % Placeholder values (after finding most efficient, update this)
eleDim.totH=10;

if usingSSC==1
    SSC.ssccall('load');
    
    % Create a data container to store all the variables
    data = ssccall('data_create');
    % Set TMY3 file location
    TMY3_File_Location= '../../../../Weather Data/724075TY.csv'; % works for all computers with relative path name '../' goes up one directory
    
    % Set input to SSC
    ssccall('data_set_string', data, 'file_name', TMY3_File_Location); %one for weather processor
    ssccall('data_set_string', data, 'weather_file', TMY3_File_Location); % one for pvsam1
    ssccall('data_set_number', data, 'use_wf_albedo', wf_albedo);
    ssccall('data_set_number', data, 'irrad_mode', irrad_model);
    ssccall('data_set_number', data, 'sky_model', sky_model);
    ssccall('data_set_number', data, 'ac_derate', ac_derate);
    ssccall('data_set_number', data, 'modules_per_string', modPV.mps);
    % strings in paralell
    ssccall('data_set_number', data, 'inverter_count', inv.num_inverters);
    ssccall('data_set_number', data, 'enable_mismatch_vmax_calc', mismatch_model);
    % subarray 1 tilt
    ssccall('data_set_number', data, 'subarray1_azimuth', eleDim.azimuth);
    ssccall('data_set_number', data, 'subarray1_track_mode', track_mode);
    % shading factors (not required)
    ssccall('data_set_array',  data, 'subarray1_soiling', soil);
    ssccall('data_set_number', data, 'subarray1_derate', dc_derate);
    % Other Subarray Disabled
    ssccall('data_set_number', data, 'subarray2_enable', 0); %enable actually doesnt disable you must also set tilt to zero
    ssccall('data_set_number', data, 'subarray3_enable', 0);
    ssccall('data_set_number', data, 'subarray4_enable', 0);
    ssccall('data_set_number', data, 'subarray2_tilt', 0);
    ssccall('data_set_number', data, 'subarray3_tilt', 0);
    ssccall('data_set_number', data, 'subarray4_tilt', 0);
    % Module Model
    ssccall('data_set_number', data, 'module_model', module_model);
    if module_model ==1 % 1 represents the CEC model
        [data]=CECmodel(data); %inputs data appropriate for the CEC model into the data container
    end
    % Inverter Model
    ssccall('data_set_number', data, 'inverter_model', inverter_model);
    if inverter_model==1
        [data]=sandiaInvModel(data);
    end
    ssccall('data_set_number', data, 'self_shading_enabled', self_shading_enable);
    ssccall('data_set_number', data, 'strings_in_parallel', 10000);
    ssccall('data_set_number', data, 'self_shading_rowspace', eleDim.totH);
    ssccall('data_set_number', data, 'subarray1_tilt', eleDim.tilt);
    % Create the pvsamv1 module
    module = ssccall('module_create', 'pvsamv1');
    % Run the module
    % data_readable=displayDataContainer(data);
    % disp(data_readable);
    ok=ssccall('module_exec', module, data);
    % Check for SAM errors
    if ok,
        WF=WFreader(data);
        pv6parmodule(data,WF); %calculates
        
        Tcellmax= max(modPV.t_cell);
        Tcellmin= min(modPV.t_cell);
        %% Calculates maximum cell temperature
        modPV.Vmpmax =modPV.mps * (modPV.Vmp - ((modPV.gamma_r) * (25 - Tcellmax))); % used for VD calc of string wiring
    else
        % if it failed, print all the errors
        disp('pvsam1 errors:');
        ii=0;
        while 1,
            err = SSC.ssccall('module_log', module, ii);
            if strcmp(err,''),
                break;
            end
            disp( err );
            ii=ii+1;
        end
    end
end
% run pv6parmodule must be after pvsam1
% 6 parameter module gives hourly voltage and current
% WF Reader
% WF=WFreader(data);
% [data]=pv6parmodule(data,WF);
% tilt=20:.5:30;
% totH=5:15;
% [bestangle,besttotH]=totH_Optim(data,qH,qW,tilt,totH,0);


global inputs %gui inputs
%% Conventional

% Raw cost per Length
% conductors omitted, their cost per length is in .mat file

% tray
inputs.costs.raw.m2cbtray = 23;
inputs.costs.raw.cb2invtray = 40;
% CBs
inputs.costs.raw.cbs = 1500;

% Labor cost per Length
%conductors
inputs.costs.labor.m2cb = .25;
inputs.costs.labor.cb2inv = 20;
%tray
inputs.costs.labor.m2cbtray = 2;
inputs.costs.labor.cb2invtray = 5;
%CB
inputs.costs.labor.cbs = 500;

% Inverter Cost per watt
inputs.costs.raw.inverter.ACdollarPerWatt=.3;

%% Alencon Default Inputs

% Raw cost per Length
% conductors omitted, their cost per length is in .mat file

% tray
inputs.costs.raw.prefabTray = 23;
inputs.costs.raw.trunk2gripTray = 26;
% SPOTs
inputs.costs.raw.spots = 1500;


% Labor cost per Length
% conductors
inputs.costs.labor.m2spot = .25;
inputs.costs.labor.spot2prefab = 1.5;
inputs.costs.labor.prefab = 3;
inputs.costs.labor.trunk2grip = 3;
% tray
inputs.costs.labor.m2cbtray = 1;
inputs.costs.labor.cb2invtray = 1;

% SPOTs
inputs.costs.labor.spots = 200;

% Inverter Cost per watt
inputs.costs.raw.inverter.GrIP=.17;

% Efficiency input
inputs.misc.efficiency.GrIP = 99.1;
inputs.misc.efficiency.spots = 98;

