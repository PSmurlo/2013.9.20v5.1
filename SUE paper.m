function varargout = guiv4(varargin)
% GUIV4 MATLAB code for guiv4.fig
%      GUIV4, by itself, creates a new GUIV4 or raises the existing
%      singleton*.
%
%      H = GUIV4 returns the handle to a new GUIV4 or the handle to
%      the existing singleton*.
%
%      GUIV4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIV4.M with the given input arguments.
%
%      GUIV4('Property','Value',...) creates a new GUIV4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiv4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiv4_OpeningFcn via varargin.rff
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiv4

% Last Modified by GUIDE v2.5 19-Sep-2013 14:45:04

%#ok<*DEFNU,*INUSD,*INUSL>

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiv4_OpeningFcn, ...
    'gui_OutputFcn',  @guiv4_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guiv4 is made visible.
function guiv4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiv4 (see VARARGIN)


addpath('Voltage Drop','NEC','SAM functions','Draw Functions');
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

set(handles.textLoading,'Visible','off');

load('sizesAWG.mat')

global tablelabels
tablelabels = {'Array';...
    'Total Cost of System';...
    'Max Volt Drop %';...
    'kWh loss over 25yrs';...
    '$/W';...
    'Cost of Conductor';...
    'Cost of Tray';...
    'Cost of Labor';...
    'Length of Module Wiring';...
    'Length of Trunk Wiring';...
    'Array Height in tables';...
    'Array Width in tables';...
    '# of CBs/SPOTs';...
    'Cost of CBs/SPOTs';...
    'Inverters Total Cost';...
    'SPOTs per Prefab';...
    'Prefab Direction';...
    'Trunk Wire Size'};


global tableDataA sortedDataA tableDataC sortedDataC tableData
global i j
[tableDataA] = AlenconOptimizationv4();
[tableDataC] = ConventionalOptimizationv4();
% check to see if output is being done correctly
if (isempty(tableDataA) || isempty(tableDataC))
    disp('no output from optimization functions');
end
sortedDataA = sortrows(tableDataA,4);
sortedDataC = sortrows(tableDataC,4);

%% VD
% Graph in GUI
handles.s1 = scatter(handles.axes,tableDataA(:,4),tableDataA(:,2),45,'x');
hold on
handles.s2 = scatter(handles.axes,tableDataC(:,4),tableDataC(:,2),45,'red','x');
grid on
xlim([0 1]);
ylim([0 maxVD]);
legend([handles.s1 handles.s2],{'Alencon','Conventional'},'Location','Southeast')
set(get(handles.axes,'XLabel'),'String','BOS $/W');
set(get(handles.axes,'YLabel'),'String','Max Voltage Drop Percent');
set(get(handles.axes,'Title'),'String','Max VDP vs. $/W');
% line([min(tableData(:,4)),min(tableData(:,4))],[0,2]);

% circle placeholder
i = 1; %Alencon placeholder kwh index
j = 1; %Conventional placeholder kwh Index
handles.sp1 = scatter(handles.axes,sortedDataA(i,4),sortedDataA(i,2),60,'k','o');
handles.sp2 = scatter(handles.axes,sortedDataC(j,4),sortedDataC(j,2),60,'k','o');

tableDataA = sortedDataA(1,:);
wireNames = sizes(tableDataA(:,17))';
tableDataA(:,17) = [];
tableDataA = num2cell(tableDataA);
tableDataA = horzcat('Alencon',tableDataA,wireNames);

tableDataC = sortedDataC(1,:);
wireNames = sizes(tableDataC(:,17))';
tableDataC(:,17) = [];
tableDataC = num2cell(tableDataC);
tableDataC = horzcat('Conventional',tableDataC,wireNames);

tableData = horzcat(tablelabels,tableDataA',tableDataC');

set(handles.uitable,'Data',tableData); % puts the data on the table

% handles.timer = timer('ExecutionMode','fixedRate',...
%     'Period', .5,...
%     'TimerFcn', {@GUIUpdate,handles});


% Choose default command line output for guiv4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes guiv4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = guiv4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i j sortedDataA sortedDataC tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value') == 1
    if i >= size(sortedDataA,1)
        i = 1;
    else
        i = i + 1;
    end
    
    set(handles.textIndex,'String',num2str(i));
    
    setSelectCircle(handles,sortedDataA,i);
    
    tableDataA = sortedDataA(i,:);
    wireNames = sizes(tableDataA(:,17))';
    tableDataA(:,17) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(:,2) = tableDataA';
    
    set(handles.uitable,'Data',tableData);
else
    if j >= size(sortedDataC,1)
        j = 1;
    else
        j = j + 1;
    end
    
    set(handles.textIndex,'String',num2str(j));
    
    setSelectCircle(handles,sortedDataC,j);
    
    tableDataC = sortedDataC(j,:);
    wireNames = sizes(tableDataC(:,17))';
    tableDataC(:,17) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(:,3) = tableDataC';
    
    set(handles.uitable,'Data',tableData);
end



% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i j sortedDataA sortedDataC tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value') == 1
    
    if i <= 1
        i = size(sortedDataA,1);
    else
        i = i - 1;
    end
    
    set(handles.textIndex,'String',num2str(i));
    
    setSelectCircle(handles,sortedDataA,i);
    
    tableDataA = sortedDataA(i,:);
    wireNames = sizes(tableDataA(:,17))';
    tableDataA(:,17) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(:,2) = tableDataA';
    
    set(handles.uitable,'Data',tableData);
    
else
    if j <= 1
        j = size(sortedDataC,1);
    else
        j = j - 1;
    end
 
    set(handles.textIndex,'String',num2str(j));
    
    setSelectCircle(handles,sortedDataC,j);
    
    tableDataC = sortedDataC(j,:);
    wireNames = sizes(tableDataC(:,17))';
    tableDataC(:,17) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(:,3) = tableDataC';
    
    set(handles.uitable,'Data',tableData);
end



% --- Executes on button press in radioAlencon.
function radioAlencon_Callback(hObject, eventdata, handles)
% hObject    handle to radioAlencon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.radioConventional,'Value',0);
set(handles.panelIndex,'Title','Alencon Index');

global i sortedDataA tableDataA inputs tableData
load('sizesAWG.mat')

%% Saving Values and Changing Display

retrieveAllHandlesConventional(handles);
setAllHandlesAlencon(inputs,handles);
[tableDataA] = AlenconOptimizationv4();
%%
    setDataScatter(handles,tableDataA);
    
    sortedDataA = sortrows(tableDataA,4);
    tableDataA = sortedDataA(1,:);
    wireNames = sizes(tableDataA(:,17))';
    tableDataA(:,17) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(:,2) = tableDataA';
    
    setSelectCircle(handles,sortedDataA,i);

set(handles.uitable,'Data',[]);
set(handles.uitable,'Data',tableData);

% set third conductor to visible
set(handles.textLaborCond2,'Visible','on');
set(handles.textLaborWireLeft,'Visible','on');
set(handles.text43,'Visible','on');
% replace 'CB' with 'SPOT'
set(handles.boxRawText,'String','SPOTs')
set(handles.boxLaborText,'String','SPOTs')
set(handles.textRawTrayLeft,'String','SPOT to Trunk');
set(handles.textRawTrayRight,'String','Trunk to GrIP');
set(handles.textLaborTrayLeft,'String','SPOT to Trunk');
set(handles.textLaborTrayRight,'String','Trunk to GrIP');
set(handles.textLaborWireLeft,'String','SPOT to Trunk');
set(handles.textLaborWireRight,'String','Trunk to GrIP');
set(handles.textModToSpot,'String','Module to SPOT');



% Hint: get(hObject,'Value') returns toggle state of radioAlencon


% --- Executes on button press in radioConventional.
function radioConventional_Callback(hObject, eventdata, handles)
% hObject    handle to radioConventional (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.radioAlencon,'Value',0);
set(handles.panelIndex,'Title','Conventional Index');

global j sortedDataC tableDataC inputs tableData
load('sizesAWG.mat')

%% Saving Values and Changing Displays
retrieveAllHandlesAlencon(handles);
setAllHandlesConventional(inputs,handles)

%%
[tableDataC] = ConventionalOptimizationv4();
    
    setDataScatter(handles,tableDataC);
    
    sortedDataC = sortrows(tableDataC,4);
    tableDataC = sortedDataC(1,:);
    wireNames = sizes(tableDataC(:,17))';
    tableDataC(:,17) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(:,3) = tableDataC';
    
    setSelectCircle(handles,sortedDataC,j);


set(handles.uitable,'Data',[]);
set(handles.uitable,'Data',tableData);

% set third conductor to inviz
set(handles.textLaborCond2,'Visible','off');
set(handles.textLaborWireLeft,'Visible','off');
set(handles.text43,'Visible','off');
% replace 'CB' with 'SPOT'
set(handles.boxRawText,'String','CBs')
set(handles.boxLaborText,'String','CBs')
set(handles.textRawTrayLeft,'String','Module to CB');
set(handles.textModToSpot,'String','Module to CB');
set(handles.textRawTrayRight,'String','CB to Inverter');
set(handles.textLaborTrayLeft,'String','Module to CB');
set(handles.textLaborTrayRight,'String','CB to Inverter');
set(handles.textLaborWireRight,'String','CB to Inverter');

% Hint: get(hObject,'Value') returns toggle state of radioConventional


% --- Executes on button press in updateButton.
function updateButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global i j tableDataA sortedDataA tableDataC sortedDataC tableData inv maxVD
load('sizesAWG.mat')
maxVD = str2double(get(handles.textVD,'String'));
ylim(handles.axes,[0 maxVD])

inv.DC_AC.target = str2double(get(handles.textDCACRatio,'String'));

% Global Changes

% if get(handles.popupModality,'Value') == 1
%     modality = 0; % Portrait
% else
%     modality = 1; % Landscape
% end

if get(handles.radioAlencon,'Value') == 1
    i=1;
    set(handles.textIndex,'String','1')
    retrieveAllHandlesAlencon(handles);
    [tableDataA] = AlenconOptimizationv4();
    
    setDataScatter(handles,tableDataA);
    
    sortedDataA = sortrows(tableDataA,4);
    tableDataA = sortedDataA(1,:);
    wireNames = sizes(tableDataA(:,17))';
    tableDataA(:,17) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(:,2) = tableDataA';
    
    setSelectCircle(handles,sortedDataA,i);
    
    set(handles.uitable,'Data',[]);
    set(handles.uitable,'Data',tableData);
else
%     oldData=tableDataC
    j=1;
    set(handles.textIndex,'String','1')
    retrieveAllHandlesConventional(handles);
    [tableDataC] = ConventionalOptimizationv4();
%     if length(oldData) > length(tableDataC)5
%     elseif length(oldData) < length(tableDataC)
%     end
    clear oldData
    
    setDataScatter(handles,tableDataC);
    
    sortedDataC = sortrows(tableDataC,4);
    tableDataC = sortedDataC(1,:);
    wireNames = sizes(tableDataC(:,17))';
    tableDataC(:,17) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(:,3) = tableDataC';
    
    setSelectCircle(handles,sortedDataC,j);
    
    set(handles.uitable,'Data',[]);
    set(handles.uitable,'Data',tableData);
end



function textConductorRating_Callback(hObject, eventdata, handles)
% hObject    handle to textConductorRating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textConductorRating as text
%        str2double(get(hObject,'String')) returns contents of textConductorRating as a double


% --- Executes during object creation, after setting all properties.
function textConductorRating_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textConductorRating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCondChoice.
function popupCondChoice_Callback(hObject, eventdata, handles)
% hObject    handle to popupCondChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupCondChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCondChoice


% --- Executes during object creation, after setting all properties.
function popupCondChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCondChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textInverterCost_Callback(hObject, eventdata, handles)
% hObject    handle to textInverterCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textInverterCost as text
%        str2double(get(hObject,'String')) returns contents of textInverterCost as a double


% --- Executes during object creation, after setting all properties.
function textInverterCost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textInverterCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textSpotEfficiency_Callback(hObject, eventdata, handles)
% hObject    handle to textSpotEfficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textSpotEfficiency as text
%        str2double(get(hObject,'String')) returns contents of textSpotEfficiency as a double


% --- Executes during object creation, after setting all properties.
function textSpotEfficiency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSpotEfficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textGripEfficiency_Callback(hObject, eventdata, handles)
% hObject    handle to textGripEfficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textGripEfficiency as text
%        str2double(get(hObject,'String')) returns contents of textGripEfficiency as a double


% --- Executes during object creation, after setting all properties.
function textGripEfficiency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textGripEfficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textDCACRatio_Callback(hObject, eventdata, handles)
% hObject    handle to textDCACRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textDCACRatio as text
%        str2double(get(hObject,'String')) returns contents of textDCACRatio as a double


% --- Executes during object creation, after setting all properties.
function textDCACRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textDCACRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCondTemp.
function popupCondTemp_Callback(hObject, eventdata, handles)
% hObject    handle to popupCondTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupCondTemp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCondTemp


% --- Executes during object creation, after setting all properties.
function popupCondTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCondTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupModality.
function popupModality_Callback(hObject, eventdata, handles)
% hObject    handle to popupModality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupModality contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupModality


% --- Executes during object creation, after setting all properties.
function popupModality_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupModality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on uitable and none of its controls.
function uitable_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function textLaborSpots_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLaborSpots as text
%        str2double(get(hObject,'String')) returns contents of textLaborSpots as a double


% --- Executes during object creation, after setting all properties.
function textLaborSpots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textRawSpot_Callback(hObject, eventdata, handles)
% hObject    handle to textRawSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRawSpot as text
%        str2double(get(hObject,'String')) returns contents of textRawSpot as a double


% --- Executes during object creation, after setting all properties.
function textRawSpot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textRawTray1_Callback(hObject, eventdata, handles)
% hObject    handle to textRawTray1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRawTray1 as text
%        str2double(get(hObject,'String')) returns contents of textRawTray1 as a double


% --- Executes during object creation, after setting all properties.
function textRawTray1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawTray1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textRawTray2_Callback(hObject, eventdata, handles)
% hObject    handle to textRawTray2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textRawTray2 as text
%        str2double(get(hObject,'String')) returns contents of textRawTray2 as a double


% --- Executes during object creation, after setting all properties.
function textRawTray2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawTray2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textLaborCond2_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborCond2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLaborCond2 as text
%        str2double(get(hObject,'String')) returns contents of textLaborCond2 as a double


% --- Executes during object creation, after setting all properties.
function textLaborCond2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborCond2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textLaborCond1_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborCond1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLaborCond1 as text
%        str2double(get(hObject,'String')) returns contents of textLaborCond1 as a double


% --- Executes during object creation, after setting all properties.
function textLaborCond1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborCond1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textLaborCond3_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborCond3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLaborCond3 as text
%        str2double(get(hObject,'String')) returns contents of textLaborCond3 as a double


% --- Executes during object creation, after setting all properties.
function textLaborCond3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborCond3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textLaborTray1_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborTray1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLaborTray1 as text
%        str2double(get(hObject,'String')) returns contents of textLaborTray1 as a double


% --- Executes during object creation, after setting all properties.
function textLaborTray1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborTray1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textLaborTray2_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborTray2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textLaborTray2 as text
%        str2double(get(hObject,'String')) returns contents of textLaborTray2 as a double


% --- Executes during object creation, after setting all properties.
function textLaborTray2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborTray2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showArray.
function showArray_Callback(hObject, eventdata, handles)
global tableData
figure
tic
set(handles.textLoading,'Visible','on');

if get(handles.radioAlencon,'Value') == 1    
    pvFarmDraw(tableData{11,2},tableData{12,2},0);
elseif get(handles.radioConventional,'Value') == 1
    pvFarmDraw(tableData{11,3},tableData{12,3},tableData{13,3});    
end
set(handles.textLoading,'Visible','off');
disp('Drawing the PV array took ')
disp(toc)
disp(' seconds');

% hObject    handle to showArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showArray


% --- Executes on button press in VD_DPW.
function VD_DPW_Callback(hObject, eventdata, handles)


set(handles.kWh_DPW,'Value',0)
%% VD
global sortedDataA sortedDataC i j

    % Graph in GUI
    setDataScatter(handles,sortedDataA)
    set(handles.radioAlencon,'Value',0)
    setDataScatter(handles,sortedDataC)
    set(handles.radioAlencon,'Value',1)
    set(get(handles.axes,'XLabel'),'String','BOS $/W');
    set(get(handles.axes,'YLabel'),'String','Max Voltage Drop Percent');
    set(get(handles.axes,'Title'),'String','Max VDP vs. $/W');
    % line([min(tableData(:,4)),min(tableData(:,4))],[0,2]);  
    
        % circle placeholder
    i = 1; %Alencon placeholder kwh index
    j = 1; %Conventional placeholder kwh Index

    setSelectCircle(handles,sortedDataA,i);
    setSelectCircle(handles,sortedDataC,j);

% hObject    handle to VD_DPW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VD_DPW


% --- Executes on button press in kWh_DPW.
function kWh_DPW_Callback(hObject, eventdata, handles)


set(handles.VD_DPW,'Value',0)
global sortedDataA sortedDataC i j

%% kWh

    setDataScatter(handles,sortedDataA)
    set(handles.radioAlencon,'Value',0)
    setDataScatter(handles,sortedDataC)
    set(handles.radioAlencon,'Value',1)
    set(get(handles.axes,'XLabel'),'String','BOS $/W');
    set(get(handles.axes,'YLabel'),'String','kWh Losses through conductors over system lifecycle');
    set(get(handles.axes,'Title'),'String','Max VDP vs. kWh Loss');
    
        % circle placeholder
    i = 1; %Alencon index
    j = 1; %Conventional Index
    setSelectCircle(handles,sortedDataA,i);
    setSelectCircle(handles,sortedDataC,j);
    

% hObject    handle to kWh_DPW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of kWh_DPW


% function GUIUpdate(obj,event,handles)
% 
% global i tableDataA sortedDataA tableDataC sortedDataC tableData
% load('sizesAWG.mat')
% 
% if get(handles.radioAlencon,'Value') == 1
%     retrieveAllHandlesAlencon(handles);   
%     [tableDataA] = AlenconOptimizationv4();
%     pause(.5)
%     
%     set(handles.s1,'xdata',tableDataA(:,4));
%     set(handles.s1,'ydata',tableDataA(:,2));
%     
%     sortedDataA = sortrows(tableDataA,4);
%     tableDataA = sortedDataA(1,:);
%     wireNames = sizes(tableDataA(:,17))';
%     tableDataA(:,17) = [];
%     tableDataA = num2cell(tableDataA);
%     tableDataA = horzcat('Alencon',tableDataA,wireNames);
%     
%     tableData(:,2) = tableDataA';
%     
%     set(handles.sp1,'xdata',sortedDataA(i,4));
%     set(handles.sp1,'ydata',sortedDataA(i,2));
%     set(handles.uitable,'Data',[]);
%     set(handles.uitable,'Data',tableData);
% else
%     retrieveAllHandlesConventional(handles);   
%     [tableDataC] = ConventionalOptimizationv4();
%     pause(.5)
%     
%     set(handles.s2,'xdata',tableDataC(:,4));
%     set(handles.s2,'ydata',tableDataC(:,2));
%     
%     sortedDataC = sortrows(tableDataC,4);
%     tableDataC = sortedDataC(1,:);
%     wireNames = sizes(tableDataC(:,17))';
%     tableDataC(:,17) = [];
%     tableDataC = num2cell(tableDataC);
%     tableDataC = horzcat('Conventional',tableDataC,wireNames);
%     
%     tableData(:,4) = tableDataC';
%     
%     set(handles.sp2,'xdata',sortedDataC(i,4));
%     set(handles.sp2,'ydata',sortedDataC(i,2));
%     set(handles.uitable,'Data',[]);
%     set(handles.uitable,'Data',tableData);
% end
% 
% % --- Executes on button press in stopButton.
% function stopButton_Callback(hObject, eventdata, handles)
% % hObject    handle to stopButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% stop(handles.timer)



function textIndex_Callback(hObject, eventdata, handles)
% hObject    handle to textIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textIndex as text
%        str2double(get(hObject,'String')) returns contents of textIndex as a double


% --- Executes during object creation, after setting all properties.
function textIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonIndex.
function buttonIndex_Callback(hObject, eventdata, handles)
% hObject    handle to buttonIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global i j sortedDataA sortedDataC tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value') == 1    
    i = str2double(get(handles.textIndex,'String'));
    
    setSelectCircle(handles,sortedDataA,i);
    
    tableDataA = sortedDataA(i,:);
    wireNames = sizes(tableDataA(:,17))';
    tableDataA(:,17) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(:,2) = tableDataA';
    
    set(handles.uitable,'Data',tableData);
    
else 
    j = str2double(get(handles.textIndex,'String'));
    
    setSelectCircle(handles,sortedDataC,j);
    
    tableDataC = sortedDataC(j,:);
    wireNames = sizes(tableDataC(:,17))';
    tableDataC(:,17) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(:,3) = tableDataC';
    
    set(handles.uitable,'Data',tableData);
end



function textVD_Callback(hObject, eventdata, handles)
% hObject    handle to textVD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textVD as text
%        str2double(get(hObject,'String')) returns contents of textVD as a double


% --- Executes during object creation, after setting all properties.
function textVD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textVD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
