
function varargout = guiv5(varargin)
% GUIV5 MATLAB code for guiv5.fig
%      GUIV5, by itself, creates a new GUIV5 or raises the existing
%      singleton*.
%
%      H = GUIV5 returns the handle to a new GUIV5 or the handle to
%      the existing singleton*.
%
%      GUIV5('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIV5.M with the given input arguments.
%
%      GUIV5('Property','Value',...) creates a new GUIV5 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiv5_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiv5_OpeningFcn via varargin.rff
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiv5

% Last Modified by GUIDE v2.5 13-Dec-2013 17:52:10

%#ok<*DEFNU,*INUSD,*INUSL>

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiv5_OpeningFcn, ...
    'gui_OutputFcn',  @guiv5_OutputFcn, ...
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


% --- Executes just before guiv5 is made visible.
function guiv5_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiv5 (see VARARGIN)

% Ensure MEX is setup for use with SSC
if strcmp(computer('arch'),'win64')
    disp('CPU type: OK')
else
    disp('This program was only designed to operate on 64 bit Windows');
end
if ~isempty(mex.getCompilerConfigurations('C','Selected'))
    disp('SSC Enabled');   
else
    disp('SSC not Enabled');
    
    % if SSC not enabled, turn these options invisible
    set(handles.popupLocation,'Visible','off');
    set(handles.LocationText,'Visible','off');
    set(handles.kWh_DPW,'Visible','off');
    set(handles.textkWh,'Visible','off');
    set(handles.text77,'Visible','off');
    
end

%[pathstr, fn, fext] = fileparts(mfilename('fullpath'));

%if %~isempty(strfind(pathstr,'\F12_Clinic_ECE10_Inverter\MATLAB\ssc-sdk-2013-9-20 v5 Working Copy\languages\matlab'))
  %  disp('Correct Path')
%else
    %% Add path to folders containing used functions
 %   DropboxPath=input('Please Enter the %Path of the Dropbox folter:','s');
    %path=strcat(DropboxPath,'\F12_Clinic_ECE10_Inverter\MATLAB\ssc-sdk-2013-9-20 v5 %Working Copy\languages\matlab');
  %  cd(path);
   % [pathstr_fixed, ~, ~] = %fileparts(mfilename('fullpath'));
  %  if ~strcmp(pathstr_fixed,path)
   %     disp('Incorrect Path');
  %  end
%end

format long

addpath('Voltage Drop','NEC','SAM functions','Draw Functions');

%% Load appropriate mat files
global sizesAWG wirePriceAl1kV wirePriceAl2kV wirePriceCu1kV wirePriceCu2kV ...
    wireSourceAl1kV wireSourceAl2kV wireSourceCu1kV wireSourceCu2kV...
    resAl resCu modPV inv TMY3_address
load('sizesAWG.mat');
sizesAWG=sizes;
load('wirePrice.mat');
wirePriceAl1kV; wirePriceAl2kV; wirePriceCu1kV; wirePriceCu2kV;
wireSourceAl1kV; wireSourceAl2kV; wireSourceCu1kV; wireSourceCu2kV;
load('resistance.mat');
resAl;
resCu;
load('CBdata.mat')
set(handles.CBtable,'Data',CBtable);

% Starting conductor Information
global Tc % Temperature rating of the conductor
Tc =    [75, 75,NaN,NaN;
    75, 75, 75, 75];
global type % The material of the conductor
type =  [1,0,NaN,NaN; % 1=Cu, 0=Al
    1,1,1,1];

global ACMW
ACMW=str2double(get(handles.ACMW,'String'));
%% Global declaration

TMY3_address= 'Select Pulldowns\Weather Files\'; % works for all locations using the dropbox with relative path name '../' goes up one directory

% Select module Product name from CSV file
moduleProductName='Renesola Jiangsu JC305M-24-Ab';

% Select inverter Product name from CSV file
inverterProductName='SMA America: SC500CP-US 270V [CEC 2012]';

% ASHRAE Mean Low Temp
global Tmin                 % used to calculate Vocmax per NEC guidelines
Tmin= -14;

% Update global variables with the new module and inverter
global moduleWidth ncellsx
moduleWidth =.992;
ncellsx =6;

global eleDim
eleDim.vertModules=2;
eleDim.modality=0;
eleDim.tilt=str2double(get(handles.editTilt,'String')); % Placeholder values (after finding most efficient, update this)
eleDim.totH=str2double(get(handles.editSpace,'String'));
eleDim.totW=39.7;

eleDim.azimuth=180;                    % Azimuth, 0=N, 90=E, 180=S, 270=W
eleDim.gapSpacing= .001;                % Spacing between modules
eleDim.vertSpace =.5;
eleDim.array2Inverter=30;

global corner
corner=1;


updateModuleAndInverter(moduleProductName,inverterProductName,moduleWidth,ncellsx);

% Chooses the modality of the modules, either portrait or landascape
% Insert text for the selected module
set(handles.textVoc,'String',strcat('Voc: ',num2str(modPV.Voc)));
set(handles.textIsc,'String',strcat('Isc: ',num2str(modPV.Isc)));
set(handles.textPmax,'String',strcat('Pmax: ',num2str(modPV.Vmp*modPV.Imp)));
set(handles.textCells,'String',strcat('Cells: ',num2str(modPV.cells)));
set(handles.textMpS,'String',strcat('Modules per String: ',num2str(modPV.mps)));
set(handles.InvkW,'String',num2str(inv.paco))
set(handles.textSpotkW,'String',num2str((modPV.Vmp*modPV.Imp*modPV.mps*4)/1000))

% ASHRAE High Ambient Temperature
global Ta
Ta = 37;                   % used to calculate temperature derate for conductor per NEC guidelines

% axis limits
global xLim yLim yLimPrevious
yLimPrevious=[];
yLim =    [str2double(get(handles.minLoss,'String')),str2double(get(handles.maxLoss,'String'))];
xLim =      [str2double(get(handles.minCostDPW,'String')),str2double(get(handles.maxCostDPW,'String'))];
ylim(handles.axesData,yLim)
xlim(handles.axesData,xLim)

%AlenconOnlyGlobals
global prefab
prefab.spotPer=1;
prefab.dir=0; % Vertical=1

%% Conventional Default Inputs
% Labels for the table which is shown in the GUI
global tableData
tableData = {'Total Cost of System';...
    'Max Volt Drop (%)';...
    'Loss over 25yrs (GWh)';...
    '$/W';...
    'Rated DC Power of Array (MW)';...
    'Rated AC Power of Inverters (MW)';...
    'Exact DC:AC Ratio';...
    'Number of Modules';...
    'Number of Strings';...
    'Number of Inverters';...
    'Cost of Inverters ($)';...
    '# of CBs/SPOTs';...
    'Cost of CBs/SPOTs ($)';...
    '# of Strings per CB/SPOT';...
    'Array Area (m^2)';...
    'Array Height in meters';...
    'Array Width in meters';...
    'Array Height in tables';...
    'Array Width in tables';...
    'Total Cost of Conductor ($)';...
    'Length of String Wiring (m)';...
    'Length of SPOT to Prefab (m)';...
    'Length of Prefab Wiring (m)';...
    'Length of Trunk Wiring (m)';...
    'Trunk (and Prefab) Wire Size'};
%gui inputs for both Conventional and Alencon

%% Begin GUI code
global i j
% initialize indecies since each time GUI is updated the indexes change
i = 1;
j = 1;

% Initialize plot in GUI
axes(handles.axesData);
grid on

% Main Plot
handles.s2 = scatter(handles.axesData,NaN,NaN,45,'red','x');
hold on
handles.s1 = scatter(handles.axesData,NaN,NaN,45,'blue','x'); %[0 135/255 26/255]

% Data Selector Circle
handles.sp1 = scatter(handles.axesData,NaN,NaN,60,'k','o');
handles.sp2 = scatter(handles.axesData,NaN,NaN,60,'k','o');

% Data Optimal Selection
handles.so1 = scatter(handles.axesData,NaN,NaN,40,'k','v');
handles.so2 = scatter(handles.axesData,NaN,NaN,40,'k','v');

% Legend and titles
legend([handles.s1, handles.s2],{'Alencon','Conventional'},'Location','SouthWest');
set(get(handles.axesData,'XLabel'),'String','BOS $/W');
set(get(handles.axesData,'YLabel'),'String','Max Voltage Drop Percent');
set(get(handles.axesData,'Title'),'String','Max VDP vs. $/W');

% set conventional inverter selection to invisible
set(handles.panelConventional,'Visible','off');

% module #
guidata(hObject, handles);
popupModuleNumber_Callback(hObject, eventdata, guidata(hObject));
% Resistance and Wire Cost
guidata(hObject, handles);
toggleCondType_Callback(hObject, eventdata, guidata(hObject));


% % Table Data
% [ tableDataA ] = getTableData(sortedDataA,'Alencon',i);       % Gets Alencon Data
% [ tableDataC ] = getTableData(sortedDataC,'Conventional',j);  % Gets Conventional Data
% 
% tableData(:,2) = tableDataA';
% tableData(:,3) = tableDataC';
% set(handles.textMaxIndex,'String',length(sortedDataA));
% 
% % Puts the data on the table
% set(handles.uitable,'Data',tableData);


% 
% kWhA=sortedDataA(:,3);
% kWhC=sortedDataC(:,3);
% costA=sortedDataA(:,1);
% costC=sortedDataC(:,1);
% paneldollarperkwh=str2num(get(handles.editDollarPerKWH,'String'));
% 
% totalCostA=costA+kWhA*paneldollarperkwh;
% totalCostC=costC+kWhC*paneldollarperkwh;
% [~,iA]=min(totalCostA);
% [~,iC]=min(totalCostC);
% 

% 
% set(handles.optimalIndexAlencon,'String',iA)
% set(handles.optimalIndexConventional,'String',iC)
% Choose default command line output for guiv5

% % show image Inverter
axes(handles.axesInverter);
alenconPic=imread('AlenconPic.jpg');
image(alenconPic);
axis off
axis image

% show image Sun
axes(handles.axesSun);
sunPic=imread('sun2.jpg');
image(sunPic);
axis off
axis image

axes(handles.AlenconLogo);
alenconLogo=imread('AlenconLogo.png');
image(alenconLogo);
axis off
axis image

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes guiv5 wait for user response (see UIRESUME)
% uiwait(handles.GUIfigure);

% --- Executes on button press in updateButton.
function updateButton_Callback(hObject, eventdata, handles)
global i j tableData sortedDataA sortedDataC tableActive
global wirePriceAl1kV wirePriceAl2kV wirePriceCu1kV wirePriceCu2kV...
    resAl resCu
global eleDim modPV TMY3_File_Location TMY3_address 
global Alencon m2spotRes internal

if get(handles.kWh_DPW,'Value') == 1
    %% SAM code for finding nominal voltage and current and Alencon Performance model
    
    % Read Alencon Data from Excel
    AlenconExcelRead(handles)
    % used in finding kWh loss
    
    % Load the SAM simulation core (SSC) modules
    % Set TMY3 file location if using SSC
    Station_name = get(handles.popupLocation,'String');
    Station_index = get(handles.popupLocation,'Value');
    Station_name = strsplit(Station_name{Station_index},'-');
    Station_name = Station_name{2};
    TMY3_File_Location=strcat(TMY3_address,Station_name,'TY.csv');
    
    
    % Simulation Selection Parameters
    inverter_model = 0;             % Inverter_model specifier,
    % 0=sandia, 1=spe
    module_model = 1;               % Photovoltaic module_model specifier
    % 0=spe, 1=cec, 2=6par_user, 3=snl
    
    % Heat transfer CEC variables
    global CECheat
    CECheat.temp_corr_model = 0;            % Cell temperature model, % 0=noct, 1=mc
    CECheat.standoff=6;                     % 6 means rack mounted
    CECheat.cec_height=0;                   % Array mounting height (0=one, 1=two)
    CECheat.mounting_config=0;              % (0=rack, 1=flush, 2=intergrated, 3=gap)
    CECheat.heat_transfer = 1;              % 0=module, 1=array;
    CECheat.mounting_orientation =1;        % 0= do not impede flow, 1=vertical, 2=horizontal supports
    
    % Options or toggles relating to the performance model calculation
    global options
    options.track_mode=0;                   % Tracking mode: 0=fixed, 1=1axis, 2=2axis, 3=azi
    options.irrad_model = 0;                % 0=beam & diffuse, 1=total & beam
    options.sky_model = 2;                  % 0=isotropic, 1=hkdr, 2=perez
    options.mismatch_model = 1;             % 0=disable, 1=enable
    self_shading_enable = 1;                % 0=disable, 1=enable
    options.wf_albedo = 1;                  % Uses albedo from weather file if provided(yes)
    
    % Direction of string wiring, always horizontal.
    eleDim.string_orientation=1;    % 0=vertical, 1=horizontal
    
    % Derates
    global derate
    derate.soil(1:12)=0.95;                 % Monthly Soiling Derate
    % *this is what is calculated with this entire code*
    derate.DC=.98;                         % DC Power Derate
    derate.AC=.99;                         % Interconnection AC Derate
    
    ssccall('load');
    
    % Create a data container to store all the variables
    data = ssccall('data_create');
    
    % Set input to SSC
    [data]=SSCoptionInput(options, derate, TMY3_File_Location,data);
    
    % Module Model
    ssccall('data_set_number', data, 'module_model', module_model);
    if module_model ==1 % 1 represents the CEC model
        [data]=CECmodel(data); %inputs data appropriate for the CEC model into the data container
    end
    
    % Inverter Model
    ssccall('data_set_number', data, 'inverter_model', inverter_model);
    if inverter_model==0
        [data]=sandiaInvModel(data);
    end
    
    % Parameters used for inter-row shading optimization
    ssccall('data_set_number', data, 'self_shading_enabled', self_shading_enable);
    ssccall('data_set_number', data, 'self_shading_length', modPV.module_length);
    ssccall('data_set_number', data, 'self_shading_width', modPV.module_width);
    ssccall('data_set_number', data, 'self_shading_mod_orient', eleDim.modality);
    ssccall('data_set_number', data, 'self_shading_str_orient', eleDim.string_orientation);
    ssccall('data_set_number', data, 'self_shading_ncellx', modPV.ncellx);
    ssccall('data_set_number', data, 'self_shading_ncelly', modPV.ncelly);
    ssccall('data_set_number', data, 'self_shading_ndiode', modPV.ndiode);
    ssccall('data_set_number', data, 'self_shading_nmodx', modPV.mps);
    ssccall('data_set_number', data, 'self_shading_nstrx', 4/eleDim.vertModules);
    ssccall('data_set_number', data, 'self_shading_nmody', eleDim.vertModules);
    ssccall('data_set_number', data, 'self_shading_nrows', 10); % Random number placeholder
    ssccall('data_set_number', data, 'self_shading_rowspace', eleDim.totH);
    ssccall('data_set_number', data, 'self_shading_mask_angle_calc_method', 0);
    
    ssccall('data_set_number', data, 'subarray1_tilt', eleDim.tilt);
    % set range in tables
    tables_range=get(handles.listTables,'String');
    % set range in SPOTs
    SPOT_range=get(handles.listSPOTs,'String');
    numTable=min(str2double(SPOT_range{1}),str2double(tables_range{1}));
    
    ssccall('data_set_number', data, 'strings_in_parallel',numTable*4 );
    % Function to optimize inter row shading
    % tilt=20:.5:30;
    % totH=5:15;
    % [bestangle,besttotH]=totH_Optim(data,qH,qW,tilt,totH,0);
%     module = ssccall('module_create', 'pvsamv1');
%     ok=ssccall('module_exec', module, data);
%     if ok,
%         sum(ssccall('data_get_array', data, 'hourly_subarray1_dc_gross'))/1000
%     end
    % Create the pvsamv1 module
    module = ssccall('module_create', 'pvsamv1');
    
    % Display data held in the data container
    % data_readable=displayDataContainer(data);
    % disp(data_readable);
    
    % Run the module
    data2=data;
    ok=ssccall('module_exec', module, data);
    % Check for SAM errors
    if ok,
        % Voltage for both systems
        
        SAM.dc_voltage=     ssccall('data_get_array', data, 'hourly_subarray1_dc_voltage');  
        dc_rating=ssccall('data_get_number', data, 'nameplate_dc_rating');
        
        
        % Find Conventional current
        modPV.kWh_perTable= ssccall('data_get_array', data, 'hourly_subarray1_dc_gross')/numTable; % kwh
        modPV.dc_current=((1000*modPV.kWh_perTable)./(SAM.dc_voltage))/4;
        modPV.dc_current(isnan(modPV.dc_current))=0; % Amps
       
        %% Alencon
        ssccall('data_set_number', data2, 'inverter_count', numTable); % set number of inverters
       
        % Find Alencon Current and Power
        Alencon.dc_current=modPV.dc_current;
        Alencon.dc_current(Alencon.dc_current>Alencon.SPOT.currentLimit)=Alencon.SPOT.currentLimit;
        Alencon.kWh_perTable=4*(Alencon.dc_current.*SAM.dc_voltage)./1000;
      
        % Alencon First year conductor losses
        sImpHourly = (.97*Alencon.dc_current).^2; %hourly curent for strings (s)
        m2SPOTResTotal = internal*(m2spotRes(5)/1000); % Resistance of conductor from module to SPOT
        m2spotKWhLoss=(sImpHourly*m2SPOTResTotal/1000)*4; % losses of conductor from module to spot
        
        Alencon.SPOT.inputDCderate=sum(Alencon.kWh_perTable-m2spotKWhLoss)/sum(modPV.kWh_perTable);
        ssccall('data_set_number', data2, 'subarray1_derate', Alencon.SPOT.inputDCderate); % set DC conductor losses
        
        Alencon.inverterModel=1;%(get(handles.modelSPOT,'Value')-1); % 0 for CEC, 1 for datasheet, 2 for Partload
        [data2]=SPOTmodel(data2);
        ok=ssccall('module_exec',module,data2);
        if ok,
            % *SPOT*
            Alencon.SPOT.clipping=ssccall('data_get_number', data2, 'annual_inv_cliploss')/1000; %Mwh
            Alencon.SPOT.Losses=ssccall('data_get_number', data2, 'annual_inv_psoloss')/1000;  %Mwh  
            Alencon.SPOT.DCoutput= ssccall('data_get_array', data2, 'hourly_ac_net');
            Alencon.SPOT.yeild=sum(Alencon.SPOT.DCoutput)/dc_rating;
            % Alencon.SPOT.DCoutCurrent=(Alencon.SPOT.DCoutput./numTable)./2500;
            % *GRIP*
            Alencon.GrIP.kWhInput=Alencon.SPOT.DCoutput;
            % clipping Losses
                %initialize
            Alencon.GrIP.clipping=zeros(length(Alencon.GrIP.kWhInput),1);
            Alencon.GrIP.shutoff=zeros(length(Alencon.GrIP.kWhInput),1);
                %calculate
            Alencon.GrIP.clipping(Alencon.GrIP.kWhInput>Alencon.GrIP.DCmaxPower)=Alencon.GrIP.kWhInput(Alencon.GrIP.kWhInput>Alencon.GrIP.DCmaxPower); 
            Alencon.GrIP.shutoff(Alencon.GrIP.kWhInput<Alencon.GrIP.inversionStart)=Alencon.GrIP.kWhInput((Alencon.GrIP.kWhInput<Alencon.GrIP.inversionStart));
                %Apply Clipping
            Alencon.GrIP.kWhInput(Alencon.GrIP.kWhInput>Alencon.GrIP.DCmaxPower)=Alencon.GrIP.DCmaxPower; 
            Alencon.GrIP.kWhInput(Alencon.GrIP.kWhInput<Alencon.GrIP.inversionStart)=0;
            
            % Night Consumption
            Alencon.GrIP.nightConsumption.kWh(Alencon.GrIP.kWhInput==0)=Alencon.GrIP.nightConsumption.w/1000;
            Alencon.GrIP.kWhInput(Alencon.GrIP.kWhInput==0)=-Alencon.GrIP.nightConsumption.w;
            
            % Inverter Partload/Static Efficiency losses
            if get(handles.partLoad,'Value')
                partLoad=Alencon.GrIP.kWhInput/Alencon.GrIP.ACmaxPower;
                partLoad(partLoad<(Alencon.GrIP.inversionStart/Alencon.GrIP.ACmaxPower))=0;
                Alencon.GrIP.kWhOutput=polyval(polyfit(Alencon.GrIP.PL.part,Alencon.GrIP.PL.eff,10),partLoad)*Alencon.GrIP.ACmaxPower; 
            else
                Alencon.GrIP.kWhOutput=Alencon.GrIP.kWhInput*(Alencon.GrIP.conversionEfficiency/100);
                Alencon.GrIP.yeild=sum(Alencon.GrIP.kWhOutput)/dc_rating;
            end
            % Inverter Losses
            Alencon.GrIP.Losses=(Alencon.GrIP.kWhInput-Alencon.GrIP.kWhOutput)+Alencon.GrIP.shutoff;

        else
            % if it failed, print all the errors
            disp('pvsam1 errors:');
            ii=0;
            while 1,
                err = ssccall('module_log', module, ii);
                if strcmp(err,''),
                    break;
                end
                disp( err );
                ii=ii+1;
            end
        end
        
        % Conventional

        SAM.ss_derate=ssccall('data_get_array', data, 'hourly_ss_derate'); % 0...1
        SAM.SSloss=sum(((1-SAM.ss_derate).*(modPV.kWh_perTable/1000)*numTable)); % Mwh
        SAM.inv.cliploss=ssccall('data_get_number', data, 'annual_inv_cliploss')/1000000; %Mwh
        SAM.inv.pconsumption=ssccall('data_get_number', data, 'annual_inv_psoloss')/1000000;  %Mwh  
        SAM.inv.pnightloss=ssccall('data_get_number', data, 'annual_inv_pntloss')/1000000; %Mwh
        AC_production=ssccall('data_get_number', data, 'annual_ac_net')/1000; %GWh
        yeild=(1000*AC_production)/dc_rating; % kwh/W
        
        
        %% Plot Outputs
        tabledataGrIP=vertcat(sum(Alencon.GrIP.kWhInput)/1000,...
            NaN,...
            sum(Alencon.GrIP.clipping)/1000,...
            sum(Alencon.GrIP.Losses)/1000,...
            sum(Alencon.GrIP.nightConsumption.kWh)/1000,...
            sum(Alencon.GrIP.kWhOutput)/1000,...
            Alencon.GrIP.yeild);
        
        tabledataSPOT=vertcat(sum(modPV.kWh_perTable)*numTable/1000,...
            SAM.SSloss,...
            sum(Alencon.SPOT.clipping)/1000,...
            sum(Alencon.SPOT.Losses)/1000,...
            NaN,...
            sum(Alencon.SPOT.DCoutput)/1000,...
            Alencon.SPOT.yeild);
        
        tabledataConventional=vertcat(sum(modPV.kWh_perTable)*numTable/1000,...
            SAM.SSloss,...
            SAM.inv.cliploss,...
            SAM.inv.pconsumption,...
            SAM.inv.pnightloss,...
            AC_production,...
            yeild);
        
        tabledata=horzcat(round(tabledataConventional),round(tabledataSPOT),round(tabledataGrIP));
        
        set(handles.SAMtable,'Data',tabledata);
%         % if successful, extract data from the weather file
%         
%         % then run the 6 parameter pv model module
%         % pv6parmodule must be run after pvsam1 because it uses the output
%         % data from pvsam1
%         
%         % 6 parameter module gives hourly voltage current and cell
%         % temperature
%         [WF]=WFreader(data);
%         pv6parmodule(WF,data);
%         
%         % Select the maximum and minimum of the cell temperature vector
%         % maximum is used to calculate the maximum voltage
%         Tcellmax= max(modPV.t_cell);
%         Tcellmin= min(modPV.t_cell);
%         
%         % Calculates maximum and minimum maximum power voltages (nominal
%         % voltage) for one string
%         
%         % used for VD calc of string wiring
%         modPV.Vmpmax =modPV.mps * (modPV.Vmp*(1+((-modPV.gamma_r * (25 - Tcellmax))/100)));
%         % *DO NOT USE TO CALCULATE MODULES PER STRING, DEMONSTRATIONAL PURPOUSES ONLY*
%         modPV.Vmpmin =modPV.mps * (modPV.Vmp*(1+((-modPV.gamma_r * (25 - Tcellmin))/100)));
    else
        % if it failed, print all the errors
        disp('pvsam1 errors:');
        ii=0;
        while 1,
            err = ssccall('module_log', module, ii);
            if strcmp(err,''),
                break;
            end
            disp( err );
            ii=ii+1;
        end
    end
    set(get(handles.axesData,'XLabel'),'String','BOS $/W');
    set(get(handles.axesData,'YLabel'),'String','kWh Losses through conductors over system lifecycle');
    set(get(handles.axesData,'Title'),'String','kWh Loss vs. $/W');
else
    set(get(handles.axesData,'XLabel'),'String','BOS $/W');
    set(get(handles.axesData,'YLabel'),'String','Max Voltage Drop Percent');
    set(get(handles.axesData,'Title'),'String','Max VDP vs. $/W');
end

% Reset the indicies
set(handles.textIndex,'String','1')
i=1;
j=1;



% axis limits
global xLim yLim
if get(handles.VD_DPW,'Value')==1;
    yLim = [str2double(get(handles.minLoss,'String')),str2double(get(handles.maxLoss,'String'))];
    if get(handles.toggleScroll,'Value')==0
        sortRow=2;
    elseif get(handles.toggleScroll,'Value')==1
        sortRow=4;
    end
    ylim(handles.axesData,yLim)
elseif get(handles.kWh_DPW,'Value')==1;
    yLim = [str2double(get(handles.minLoss,'String')),str2double(get(handles.maxLoss,'String'))]*1000000;
    if get(handles.toggleScroll,'Value')==0
        sortRow=3;
    elseif get(handles.toggleScroll,'Value')==1
        sortRow=4;
    end
    ylim(handles.axesData,yLim)
end
xLim = [str2double(get(handles.minCostDPW,'String')),str2double(get(handles.maxCostDPW,'String'))];

xlim(handles.axesData,xLim)


% Running live with wire prices open
if strcmp(get(handles.AWGtable,'Visible'),'on');
    activeTable=get(handles.AWGtable,'Data');
    activePrices=activeTable(:,2);
    
    if strcmp(tableActive,'Al1kV')
        wirePriceAl1kV = cell2mat(activePrices');
    elseif strcmp(tableActive,'Al2kV')
        wirePriceAl2kV = cell2mat(activePrices');
    elseif strcmp(tableActive,'Cu1kV')
        wirePriceCu1kV = cell2mat(activePrices');
    elseif strcmp(tableActive,'Cu2kV')
        wirePriceCu2kV = cell2mat(activePrices');
    end
end

% Running live with resistance open
if strcmp(get(handles.ResTable,'Visible'),'on');
    activeTable=get(handles.ResTable,'Data');
    activePrices=activeTable(:,2);
    if strcmp(tableActive,'Al')
        resAl = cell2mat(activePrices');
    elseif strcmp(tableActive,'Cu')
        resCu = cell2mat(activePrices');
    end
end

dollarPerKwh=str2num(get(handles.editDollarPerKWH,'String'));

if get(handles.radioAlencon,'Value') == 1
    retrieveAllHandlesAlencon(handles);
    
    [optimDataC] = ConventionalOptimization(handles);
    sortedDataC = sortrows(optimDataC,sortRow);
    set(handles.radioAlencon,'Value',0);
    set(handles.radioConventional,'Value',1);
    setDataScatter(handles,sortedDataC);
    setSelectCircle(handles,sortedDataC,j)
    kWhC=sortedDataC(:,3);
    costC=sortedDataC(:,1);
    totalCostC=costC+kWhC*dollarPerKwh;
    [~,iC]=min(totalCostC);
    set(handles.optimalIndexConventional,'String',iC)
    setOptimalTriangle(handles,sortedDataC,iC)
    
    [optimDataA] = AlenconOptimization(handles);
    sortedDataA = sortrows(optimDataA,sortRow);
    set(handles.radioAlencon,'Value',1);
    set(handles.radioConventional,'Value',0);
    setDataScatter(handles,sortedDataA);
    setSelectCircle(handles,sortedDataA,i)
    kWhA=sortedDataA(:,3);
    costA=sortedDataA(:,1);
    totalCostA=costA+kWhA*dollarPerKwh;
    [~,iA]=min(totalCostA);
    set(handles.optimalIndexAlencon,'String',iA)
    setOptimalTriangle(handles,sortedDataA,iA)
    
    set(handles.textMaxIndex,'String',length(sortedDataA));
else
    retrieveAllHandlesConventional(handles);
    
    [optimDataA] = AlenconOptimization(handles);
    sortedDataA = sortrows(optimDataA,sortRow);
    set(handles.radioAlencon,'Value',1);
    set(handles.radioConventional,'Value',0);
    setDataScatter(handles,sortedDataA);
    setSelectCircle(handles,sortedDataA,i)
    kWhA=sortedDataA(:,3);
    costA=sortedDataA(:,1);
    totalCostA=costA+kWhA*dollarPerKwh;
    [~,iA]=min(totalCostA);
    set(handles.optimalIndexAlencon,'String',iA)
    setOptimalTriangle(handles,sortedDataA,iA)
    
    [optimDataC] = ConventionalOptimization(handles);
    sortedDataC = sortrows(optimDataC,sortRow);
    set(handles.radioAlencon,'Value',0);
    set(handles.radioConventional,'Value',1);
    setDataScatter(handles,sortedDataC);
    setSelectCircle(handles,sortedDataC,j)
    kWhC=sortedDataC(:,3);
    costC=sortedDataC(:,1);
    totalCostC=costC+kWhC*dollarPerKwh;
    [~,iC]=min(totalCostC);
    set(handles.optimalIndexConventional,'String',iC)
    setOptimalTriangle(handles,sortedDataC,iC)
    
    set(handles.textMaxIndex,'String',length(sortedDataC));
end

[tableDataA] = getTableData(sortedDataA,'Alencon',i);       % Gets Alencon Data
tableData(:,2) = tableDataA';
[tableDataC] = getTableData(sortedDataC,'Conventional',j);       % Gets Conventional Data
tableData(:,3) = tableDataC';

set(handles.uitable,'Data',[]);
set(handles.uitable,'Data',tableData);



% --- Outputs from this function are returned to the command line.
function varargout = guiv5_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user clicks the 'Next' button in the GUI.
function nextButton_Callback(hObject, eventdata, handles)
global i j sortedDataA sortedDataC tableData

if get(handles.radioAlencon,'Value') == 1 % if in Alencon mode
    % if the index is greater than the number of possible entrys
    if i >= size(sortedDataA,1)
        % make it one
        i = 1;
    else
        % otherwise increment
        i = i + 1;
    end
    
    % sets the index to visible in the GUI
    set(handles.textIndex,'String',num2str(i));
    % Selects the index with a circle in the GUI
    setSelectCircle(handles,sortedDataA,i);
    % Gets the data for the table
    tableDataA = getTableData(sortedDataA,'Alencon',i); % Gets Alencon Data
    % Sets alencon into the tabledata
    tableData(:,2) = tableDataA';
    
    set(handles.uitable,'Data',tableData);
else
    % if the index is greater than the number of possible entrys
    if j >= size(sortedDataC,1)
        % make it one
        j = 1;
    else
        % otherwise increment
        j = j + 1;
    end
    
    % sets the index to visible in the GUI
    set(handles.textIndex,'String',num2str(j));
    % Selects the index with a circle in the GUI
    setSelectCircle(handles,sortedDataC,j);
    % Gets the data for the table
    tableDataC = getTableData(sortedDataC,'Conventional',j); % Gets Conventional Data
    % Sets conventional into the tabledata
    tableData(:,3) = tableDataC';
    
    set(handles.uitable,'Data',tableData);
end

% --- Executes when user clicks the 'Previous' button in the GUI.
function previousButton_Callback(hObject, eventdata, handles)
global i j sortedDataA sortedDataC tableData

if get(handles.radioAlencon,'Value') == 1 % if in Alencon mode
    % if the index is greater than the number of possible entrys
    if i <= 1
        % make it one
        i = size(sortedDataA,1);
    else
        % otherwise decrement
        i = i - 1;
    end
    
    % sets the index to visible in the GUI
    set(handles.textIndex,'String',num2str(i));
    % Selects the index with a circle in the GUI
    setSelectCircle(handles,sortedDataA,i);
    % Gets the data for the table
    tableDataA = getTableData(sortedDataA,'Alencon',i); % Gets Alencon Data
    % Sets alencon into the tabledata
    tableData(:,2) = tableDataA';
    
    set(handles.uitable,'Data',tableData);
else
    % if the index is greater than the number of possible entrys
    if j <= 1
        % make it one
        j = size(sortedDataC,1);
    else
        % otherwise decrement
        j = j - 1;
    end
    
    % sets the index to visible in the GUI
    set(handles.textIndex,'String',num2str(j));
    % Selects the index with a circle in the GUI
    setSelectCircle(handles,sortedDataC,j);
    % Gets the data for the table
    tableDataC = getTableData(sortedDataC,'Conventional',j); % Gets Conventional Data
    % Sets conventional into the tabledata
    tableData(:,3) = tableDataC';
    
    set(handles.uitable,'Data',tableData);
end



% --- Executes on toggle of changing to Alencon mode
function radioAlencon_Callback(hObject, eventdata, handles)
global sortedDataA
% sets Conventional to zero
set(handles.radioConventional,'Value',0);
% sets index to alencon index
set(handles.panelIndex,'Title','Alencon Index');

% Saving Values in Textboxes
% retrieveAllHandlesConventional(handles);
% Sets all values in textboxes to Alencon values
% setAllHandlesAlencon(inputs,handles);

% sets max index
set(handles.textMaxIndex,'String',length(sortedDataA));
% set inverter selection to invisible
% set inverter selection to invisible
set(handles.SPOTpanel,'Visible','on');
set(handles.GrIPpanel,'Visible','on');
% turn toggles back on
set(handles.togglePrefabSpot,'Visible','on');
set(handles.textSPOTperPrefab,'Visible','on');
set(handles.togglePrefabDir,'Visible','on');
set(handles.textPrefab,'Visible','on');

% set inverter selection to invisible
set(handles.panelConventional,'Visible','off');

axes(handles.axesInverter);
alenconPic=imread('AlenconPic.jpg');
image(alenconPic);
axis off
axis image

% set(handles.popupInverter,'Visible','off');
% set(handles.text75,'Visible','off');
% % sets inverter efficiency to Grip efficiency
% set(handles.uipanel14,'Title','GrIP % Eff.');
% set(handles.textGripEfficiency,'String',int2str(inputs.misc.efficiency.GrIP));
% % set third conductor to visible
% set(handles.textLaborCond2,'Visible','on');
% set(handles.textLaborWireLeft,'Visible','on');
% set(handles.text43,'Visible','on');
% % replace 'CB' with 'SPOT'
% set(handles.boxRawText,'String','SPOTs')
% set(handles.boxLaborText,'String','SPOTs')
% set(handles.textRawTrayLeft,'String','SPOT to Trunk');
% set(handles.textRawTrayRight,'String','Trunk to GrIP');
% set(handles.textLaborTrayLeft,'String','SPOT to Trunk');
% set(handles.textLaborTrayRight,'String','Trunk to GrIP');
% set(handles.textLaborWireLeft,'String','SPOT to Trunk');
% set(handles.textLaborWireRight,'String','Trunk to GrIP');
% set(handles.textModToSpot,'String','Module to SPOT');
% % Enable SPOT efficiency
% set(handles.uipanel19,'Visible','on');
% % done loading
% set(handles.textLoading,'Visible','off');


% --- Executes on button press in radioConventional.
function radioConventional_Callback(hObject, eventdata, handles)
global sortedDataC
% sets Alencon to zero
set(handles.radioAlencon,'Value',0);
% sets index to Conventional index
set(handles.panelIndex,'Title','Conventional Index');
% Saving Values in Textboxes
retrieveAllHandlesAlencon(handles);

% Sets all values in textboxes to Conventional values
% setAllHandlesConventional(inputs,handles);

set(handles.textMaxIndex,'String',length(sortedDataC));

% set inverter selection to invisible
set(handles.SPOTpanel,'Visible','off');
set(handles.GrIPpanel,'Visible','off');
% Input Parameterers Disable
set(handles.togglePrefabSpot,'Visible','off');
set(handles.textSPOTperPrefab,'Visible','off');
set(handles.togglePrefabDir,'Visible','off');
set(handles.textPrefab,'Visible','off');
% set inverter selection to invisible
set(handles.panelConventional,'Visible','on');


axes(handles.axesInverter);

conventionalPic=imread('ConventionalPic.jpg');
image(conventionalPic);
axis off
axis image
% % set third conductor to inviz
% set(handles.textLaborCond2,'Visible','off');
% set(handles.textLaborWireLeft,'Visible','off');
% set(handles.text43,'Visible','off');
% 
% % sets GrIP efficiency to conv. Inverter efficiency
% set(handles.uipanel14,'Title','Inv % Eff.');
% set(handles.textGripEfficiency,'String',int2str(inputs.misc.efficiency.GrIP));
% 
% % replace 'SPOT' with 'CB'
% set(handles.boxRawText,'String','CBs')
% set(handles.boxLaborText,'String','CBs')
% set(handles.textRawTrayLeft,'String','Module to CB');
% set(handles.textModToSpot,'String','Module to CB');
% set(handles.textRawTrayRight,'String','CB to Inverter');
% set(handles.textLaborTrayLeft,'String','Module to CB');
% set(handles.textLaborTrayRight,'String','CB to Inverter');
% set(handles.textLaborWireRight,'String','CB to Inverter');
% % Disable SPOT Info
% set(handles.uipanel19,'Visible','off');
% % done loading
% set(handles.textLoading,'Visible','off');

% --- Executes on button press in showArray.
function showArray_Callback(hObject, eventdata, handles)
global tableData
figure
tic

if get(handles.radioAlencon,'Value') == 1
    pvFarmDraw(tableData{11,2},tableData{12,2},0);
elseif get(handles.radioConventional,'Value') == 1
    pvFarmDraw(tableData{11,3},tableData{12,3},tableData{13,3});
end
disp('Drawing the PV array took ')
disp(toc)
disp(' seconds');


% --- Executes on button press in VD_DPW.
function VD_DPW_Callback(hObject, eventdata, handles)


set(handles.kWh_DPW,'Value',0)
%% VD
global sortedDataA sortedDataC

% Graph in GUI
setDataScatter(handles,sortedDataA)
set(handles.radioAlencon,'Value',0)
setDataScatter(handles,sortedDataC)
set(handles.radioAlencon,'Value',1)
set(get(handles.axesData,'XLabel'),'String','BOS $/W');
set(get(handles.axesData,'YLabel'),'String','Max Voltage Drop Percent');
set(get(handles.axesData,'Title'),'String','Max VDP vs. $/W');
% line([min(tableData(:,4)),min(tableData(:,4))],[0,2]);

% circle placeholder
setSelectCircle(handles,sortedDataA,1);
setSelectCircle(handles,sortedDataC,1);

% --- Executes on button press in kWh_DPW.
function kWh_DPW_Callback(hObject, eventdata, handles)

set(handles.VD_DPW,'Value',0)
global sortedDataA sortedDataC

setDataScatter(handles,sortedDataA)
set(handles.radioAlencon,'Value',0)
setDataScatter(handles,sortedDataC)
set(handles.radioAlencon,'Value',1)

% circle placeholder
setSelectCircle(handles,sortedDataA,1);
setSelectCircle(handles,sortedDataC,1);

% --- Executes on button press in buttonIndex.
function buttonIndex_Callback(hObject, eventdata, handles)
global i j sortedDataA sortedDataC tableData


if get(handles.radioAlencon,'Value') == 1
    i = str2double(get(handles.textIndex,'String'));
    
    setSelectCircle(handles,sortedDataA,i);
    
    [ tableDataA ] = getTableData(sortedDataA,'Alencon',i);       % Gets Alencon Data
    
    tableData(:,2) = tableDataA';
    
    set(handles.uitable,'Data',tableData);
    
else
    j = str2double(get(handles.textIndex,'String'));
    
    setSelectCircle(handles,sortedDataC,j);
    
    [ tableDataC ] = getTableData(sortedDataC,'Conventional',j);       % Gets Conventional Data
    
    tableData(:,3) = tableDataC';
    
    set(handles.uitable,'Data',tableData);
end

% --- Executes on selection change in popupModul


% --- Executes on selection change in popupLocation.
function popupLocation_Callback(hObject, eventdata, handles)
global TMY3_File_Location TMY3_address

Station_name = get(handles.popupLocation,'String');
Station_index = get(handles.popupLocation,'Value');
Station_name = strsplit(Station_name{Station_index},'-');
Station_name = Station_name{2};
TMY3_File_Location=strcat(TMY3_address,Station_name,'TY.csv');
[num,text,raw]=xlsread(TMY3_File_Location);
longitude=num(1,6);
if longitude<0
    ew='W';
else
    ew='E';
end
set(handles.textLat,'String',strcat(num2str(abs(longitude)),ew))
latitude=num(1,5);
if latitude>0
    ew='N';
else
    ew='S';
end
set(handles.textLong,'String',strcat(num2str(abs(latitude)),ew));
state=text{1,3};
set(handles.textState,'String',state);

function updateModuleAndInverter( moduleProductName,inverterProductName,module_width,ncellx )

if (exist('inverterData','var')==0  || exist('inverterNames','var')==0 ||...
        exist('moduleData','var')==0    || exist('moduleNames','var')==0)
    load('CECSandiaLibraries.mat');
end

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
inv.pnt=        inverterData(10,inverterAddress);% AC power consumed by inverter at night (Wac)

% Inverter constraints
inv.vdcmax=     inverterData(11,inverterAddress); % Maximum DC input operating voltage (V)
inv.idcmax=     inverterData(12,inverterAddress); % Max AC current (A)
inv.mppt_low=   inverterData(13,inverterAddress); % Minimum input voltage (MPPT)
inv.mppt_hi=    inverterData(14,inverterAddress); % Maximum input voltage (MPPT)
inv.num_inverters=20; % Number of inverters
inv.perPad=4;

% CEC Module Model Parameters
global modPV
% Module Manual Entry
modPV.module_width=module_width;                    % Module length (m)
modPV.ncellx=ncellx;                                  % Number of cells on top

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
modPV.module_length=modPV.mod_area/modPV.module_width;% Module width (m)
modPV.ncelly=modPV.cells/modPV.ncellx;                  % Number of cells longways
modPV.ndiode=modPV.ncellx/2;                            % Number of bypass diodes
if modPV.ncellx == 1
    modPV.ncelly=1;
    modPV.ndiode=0;
end
modPV.type=       moduleType{moduleAddress};            % Module Type
modPV.module_string=moduleProductName;                  % Module Name
modPV.STC = modPV.Vmp*modPV.Imp;
T_cell_guess=60;
if exist('modPV.t_cell','var')
    T_cell=max(modPV.t_cell);
else
    T_cell=T_cell_guess;
end
global Tmin
modPV.mps= floor(inv.vdcmax/(modPV.Voc-(modPV.beta_oc*(25-Tmin)))); % Module Per String
modPV.Vmpmax =modPV.mps * (modPV.Vmp*(1+((-modPV.gamma_r * (25 - T_cell))/100)));

global tableW eleDim
eleDim.modperTable=modPV.mps*4;
tableW = eleDim.modperTable*modPV.STC;

% if(ppc==0) % Percent per celcius * Not used only for reference *
%     modPV.mps = floor(inv.vdcmax / (modPV.Voc - (modPV.beta_oc * (25 - Tmin))));
% else % If the data is given in (V/C), use this equation to calculate MpS
%     modPV.mps = floor(inv.vdcmax /(modPV.Voc*(1+((-modPV.beta_oc)*(25-Tmin)/100))));

function [data]=SSCoptionInput(options, derate, TMY3_File_Location, data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global inv modPV eleDim
albedo=[0 0 0 0 0 0 0 0 0 0 0 0];
ssccall('data_set_string', data, 'file_name', TMY3_File_Location); %one for weather processor
ssccall('data_set_string', data, 'weather_file', TMY3_File_Location); % one for pvsam1
ssccall('data_set_number', data, 'use_wf_albedo', options.wf_albedo);
ssccall('data_set_array', data, 'albedo', albedo);
ssccall('data_set_number', data, 'irrad_mode', options.irrad_model);
ssccall('data_set_number', data, 'sky_model', options.sky_model);
ssccall('data_set_number', data, 'ac_derate', derate.AC);
ssccall('data_set_number', data, 'modules_per_string', modPV.mps);
% strings in paralell
ssccall('data_set_number', data, 'inverter_count', inv.num_inverters);
ssccall('data_set_number', data, 'enable_mismatch_vmax_calc', options.mismatch_model);
% subarray 1 tilt
ssccall('data_set_number', data, 'subarray1_azimuth', eleDim.azimuth);
ssccall('data_set_number', data, 'subarray1_track_mode', options.track_mode);
% shading factors (not required)
ssccall('data_set_array',  data, 'subarray1_soiling', derate.soil);
ssccall('data_set_number', data, 'subarray1_derate', derate.DC);
% Other Subarray Disabled
ssccall('data_set_number', data, 'subarray2_enable', 0); %enable actually doesnt disable you must also set tilt to zero
ssccall('data_set_number', data, 'subarray3_enable', 0);
ssccall('data_set_number', data, 'subarray4_enable', 0);
ssccall('data_set_number', data, 'subarray2_tilt', 0);
ssccall('data_set_number', data, 'subarray3_tilt', 0);
ssccall('data_set_number', data, 'subarray4_tilt', 0);

function [WF]=WFreader(data)
% Create the wfreader module and execute it
module = ssccall('module_create', 'wfreader');
ssccall('module_exec', module, data);

WF.site_elevation = ssccall('data_get_number',data, 'elev');
% WF.global = ssccall('data_get_array', data, 'global');
% WF.beam =   ssccall('data_get_array', data, 'beam');
% WF.diffuse =ssccall('data_get_array', data, 'diffuse');
WF.wspd =   ssccall('data_get_array', data, 'wspd');
WF.wdir =   ssccall('data_get_array', data, 'wdir');
WF.tdry =	ssccall('data_get_array', data, 'tdry');
% WF.twet =	ssccall('data_get_array', data, 'twet');
% WF.tdew =	ssccall('data_get_array', data, 'tdew');
% WF.rhum =	ssccall('data_get_array', data, 'rhum');
% WF.pres =	ssccall('data_get_array', data, 'pres');
% WF.snow =	ssccall('data_get_array', data, 'snow');
% WF.albedo =	ssccall('data_get_array', data, 'albedo');

function [] = setOptimalTriangle(handles,sortedData,i)% works for i or j. sorteddataA or sorteddataC
if get(handles.radioAlencon,'Value') == 1
    if get(handles.VD_DPW,'Value') == 1
        set(handles.so1,'xdata',sortedData(i,4));
        set(handles.so1,'ydata',sortedData(i,2));
    else
        set(handles.so1,'xdata',sortedData(i,4));
        set(handles.so1,'ydata',sortedData(i,3));
    end
else
    if get(handles.VD_DPW,'Value') == 1
        set(handles.so2,'xdata',sortedData(i,4));
        set(handles.so2,'ydata',sortedData(i,2));
    else
        set(handles.so2,'xdata',sortedData(i,4));
        set(handles.so2,'ydata',sortedData(i,3));
    end
end

function [] = setSelectCircle(handles,sortedData,i)% works for i or j. sorteddataA or sorteddataC
if get(handles.radioAlencon,'Value') == 1
    if get(handles.VD_DPW,'Value') == 1
        set(handles.sp1,'xdata',sortedData(i,4));
        set(handles.sp1,'ydata',sortedData(i,2));
    else
        set(handles.sp1,'xdata',sortedData(i,4));
        set(handles.sp1,'ydata',sortedData(i,3));
    end
else
    if get(handles.VD_DPW,'Value') == 1
        set(handles.sp2,'xdata',sortedData(i,4));
        set(handles.sp2,'ydata',sortedData(i,2));
    else
        set(handles.sp2,'xdata',sortedData(i,4));
        set(handles.sp2,'ydata',sortedData(i,3));
    end
end


%% Dropdown menu callbacks

%%-------------------------------------------------------------------------
% Resistance Pulldown
function resCu_Callback(hObject, eventdata, handles)

function resAl_Callback(hObject, eventdata, handles)

function resSave_Callback(hObject, eventdata, handles)
global resCu resAl tableResActive
prompt=input('Are the units in ohms/km and you are sure you want to save? This cannot be undone(y/n): ','s');
if strcmp(prompt,'y')||strcmp(prompt,'yes')
    activeTable=get(handles.ResTable,'Data');
    activePrices=activeTable(:,2);
    if strcmp(tableResActive,'Al')
        resAl = cell2mat(activePrices');
    elseif strcmp(tableResActive,'Cu')
        resCu = cell2mat(activePrices');
    end
    save('resistance.mat','resAl','resCu');
    set(handles.ResTable,'Visible', 'off')
    set(handles.resSave,'Visible', 'off')
    set(handles.resClose,'Visible', 'off')
    disp('saved resistance.mat');
elseif strcmp(prompt,'n')||strcmp(prompt,'no')
    disp('did not save resistance.mat');
end
function resValChange_Callback(hObject, eventdata, handles)

function resClose_Callback(hObject, eventdata, handles)
global tableResActive

tableResActive=[];
set(handles.ResTable,'Visible', 'off')
set(handles.resSave,'Visible', 'off')
set(handles.resClose,'Visible', 'off')
set(handles.ResTable,'Data',[]);

function resChangeAl_Callback(hObject, eventdata, handles)
global  sizesAWG  tableResActive resAl
tableResActive='Al';
sizesTable= horzcat(sizesAWG',num2cell(resAl'));
set(handles.ResTable,'Visible', 'on')
set(handles.resSave,'Visible', 'on')
set(handles.resClose,'Visible', 'on')
set(handles.ResTable,'Data', sizesTable)

function resChangeCu_Callback(hObject, eventdata, handles)
global  sizesAWG  tableResActive resCu
tableResActive='Cu';
sizesTable= horzcat(sizesAWG',num2cell(resCu'));
set(handles.ResTable,'Visible', 'on')
set(handles.resSave,'Visible', 'on')
set(handles.resClose,'Visible', 'on')
set(handles.ResTable,'Data', sizesTable)

function resDispAl_Callback(hObject, eventdata, handles)
global resAl sizesAWG
sizesTable= horzcat(sizesAWG',num2cell(resAl'));
disp(sizesTable);

function resDispCu_Callback(hObject, eventdata, handles)
global resCu sizesAWG
sizesTable= horzcat(sizesAWG',num2cell(resCu'));
disp(sizesTable);

%%--------------------------------------------------------------------
% Wire Prices
function edit_Constants_Callback(hObject, eventdata, handles)
function edit_wirePrices_Callback(hObject, eventdata, handles)
function wireAl_Callback(hObject, eventdata, handles)
function wireCu_Callback(hObject, eventdata, handles)

% Select type
function Cu1kV_Callback(hObject, eventdata, handles)
function Cu2kV_Callback(hObject, eventdata, handles)
function Al1kV_Callback(hObject, eventdata, handles)
function Al2kV_Callback(hObject, eventdata, handles)

function Al1kVDisplay_Callback(hObject, eventdata, handles)
global wirePriceAl1kV sizesAWG wireSourceAl1kV
sizesTable= horzcat(sizesAWG',num2cell(wirePriceAl1kV'),wireSourceAl1kV');
disp(sizesTable);

function Al2kVDisplay_Callback(hObject, eventdata, handles)
global wirePriceAl2kV sizesAWG wireSourceAl2kV
sizesTable= horzcat(sizesAWG',num2cell(wirePriceAl2kV'),wireSourceAl2kV');
disp(sizesTable);

function Cu2kVDisplay_Callback(hObject, eventdata, handles)
global wirePriceCu2kV sizesAWG wireSourceCu2kV
sizesTable= horzcat(sizesAWG',num2cell(wirePriceCu2kV'),wireSourceCu2kV');
disp(sizesTable);

function Cu1kVDisplay_Callback(hObject, eventdata, handles)
global wirePriceCu1kV sizesAWG wireSourceCu1kV
sizesTable= horzcat(sizesAWG',num2cell(wirePriceCu1kV'),wireSourceCu1kV');
disp(sizesTable);

function Al1kVChange_Callback(hObject, eventdata, handles)
global wirePriceAl1kV sizesAWG wireSourceAl1kV tableActive
tableActive='Al1kV';
sizesTable= horzcat(sizesAWG',num2cell(wirePriceAl1kV'),wireSourceAl1kV');
set(handles.AWGtable,'Visible', 'on')
set(handles.SaveOpenPrices,'Visible', 'on')
set(handles.closePrices,'Visible', 'on')
set(handles.AWGtable,'Data',sizesTable)

function Al2kVChange_Callback(hObject, eventdata, handles)
global wirePriceAl2kV sizesAWG wireSourceAl2kV tableActive
tableActive='Al2kV';
sizesTable= horzcat(sizesAWG',num2cell(wirePriceAl2kV'),wireSourceAl2kV');
set(handles.AWGtable,'Visible', 'on')
set(handles.SaveOpenPrices,'Visible', 'on')
set(handles.closePrices,'Visible', 'on')
set(handles.AWGtable,'Data', sizesTable)

function Cu2kVChange_Callback(hObject, eventdata, handles)
global wirePriceCu2kV sizesAWG wireSourceCu2kV tableActive
tableActive='Cu2kV';
sizesTable= horzcat(sizesAWG',num2cell(wirePriceCu2kV'),wireSourceCu2kV');
set(handles.AWGtable,'Visible', 'on')
set(handles.SaveOpenPrices,'Visible', 'on')
set(handles.closePrices,'Visible', 'on')
set(handles.AWGtable,'Data', sizesTable)

function Cu1kVChange_Callback(hObject, eventdata, handles)
global wirePriceCu1kV sizesAWG wireSourceCu1kV tableActive
tableActive='Cu1kV';
sizesTable= horzcat(sizesAWG',num2cell(wirePriceCu1kV'),wireSourceCu1kV');
set(handles.AWGtable,'Visible', 'on')
set(handles.SaveOpenPrices,'Visible', 'on')
set(handles.closePrices,'Visible', 'on')
set(handles.AWGtable,'Data', sizesTable)

function SaveOpenPrices_Callback(hObject, eventdata, handles)
global wirePriceAl1kV wirePriceAl2kV wirePriceCu1kV wirePriceCu2kV...
    wireSourceAl1kV wireSourceAl2kV wireSourceCu1kV wireSourceCu2kV...
    tableActive
prompt=input('Are the units in $/km and you are sure you want to save? This cannot be undone(y/n): ','s');
if strcmp(prompt,'y')||strcmp(prompt,'yes')
    activeTable=get(handles.AWGtable,'Data');
    activePrices=activeTable(:,2);
    if strcmp(tableActive,'Al1kV')
        wirePriceAl1kV = cell2mat(activePrices');
    elseif strcmp(tableActive,'Al2kV')
        wirePriceAl2kV = cell2mat(activePrices');
    elseif strcmp(tableActive,'Cu1kV')
        wirePriceCu1kV = cell2mat(activePrices');
    elseif strcmp(tableActive,'Cu2kV')
        wirePriceCu2kV = cell2mat(activePrices');
    end
    
    activeTable=get(handles.AWGtable,'Data');
    activeSource=activeTable(:,3);
    if strcmp(tableActive,'Al1kV')
        wireSourceAl1kV = activeSource';
    elseif strcmp(tableActive,'Al2kV')
        wireSourceAl2kV = activeSource';
    elseif strcmp(tableActive,'Cu1kV')
        wireSourceCu1kV = activeSource';
    elseif strcmp(tableActive,'Cu2kV')
        wireSourceCu2kV = activeSource';
    end
    save('wirePrice.mat','wirePriceAl1kV', 'wirePriceAl2kV', 'wirePriceCu1kV', 'wirePriceCu2kV',...
        'wireSourceAl1kV', 'wireSourceAl2kV', 'wireSourceCu1kV', 'wireSourceCu2kV');
    set(handles.AWGtable,'Visible', 'off')
    set(handles.SaveOpenPrices,'Visible', 'off')
    set(handles.closePrices,'Visible', 'off')
    disp('saved wirePrice.mat');
elseif strcmp(prompt,'n')||strcmp(prompt,'no')
    disp('did not save wirePrice.mat');
    
end

function closePrices_Callback(hObject, eventdata, handles)
global tableActive

tableActive=[];
set(handles.AWGtable,'Data',[]);
set(handles.AWGtable,'Visible', 'off')
set(handles.SaveOpenPrices,'Visible', 'off')
set(handles.closePrices,'Visible', 'off')

%% --------------------------------------------------------------------
%CB
function CBpricePulldown_Callback(hObject, eventdata, handles)

function CBdisplay_Callback(hObject, eventdata, handles)
load('CBdata.mat');
disp(CBtable);

function CBchange_Callback(hObject, eventdata, handles)
load('CBdata.mat');
set(handles.CBtable,'Visible', 'on')
set(handles.CBsave,'Visible', 'on')
set(handles.CBclose,'Visible', 'on')
set(handles.CBadd,'Visible', 'on')
set(handles.CBdelete,'Visible', 'on')
set(handles.CBtable,'Data', CBtable)


function CBsave_Callback(hObject, eventdata, handles)
prompt=input('Are you are sure you want to save? This cannot be undone(y/n): ','s');
if strcmp(prompt,'y')||strcmp(prompt,'yes')
    CBtable=get(handles.CBtable,'Data');
    save('CBdata.mat','CBtable');
    set(handles.CBtable,'Visible', 'off')
    set(handles.CBsave,'Visible', 'off')
    set(handles.CBclose,'Visible', 'off')
    set(handles.CBadd,'Visible', 'off')
    set(handles.CBdelete,'Visible', 'off')
    disp('saved CBdata.mat');
elseif strcmp(prompt,'n')||strcmp(prompt,'no')
    disp('did not save CBdata.mat');
end

function CBclose_Callback(hObject, eventdata, handles)
set(handles.CBtable,'Visible', 'off')
set(handles.CBsave,'Visible', 'off')
set(handles.CBclose,'Visible', 'off')
set(handles.CBadd,'Visible', 'off')
set(handles.CBdelete,'Visible', 'off')
set(handles.CBtable,'Data',[]);

function CBadd_Callback(hObject, eventdata, handles)
CBtable=get(handles.CBtable,'Data');
CBtable=vertcat(CBtable,{0,0,0,0,'Other',' '});
set(handles.CBtable,'Data',CBtable);

function CBdelete_Callback(hObject, eventdata, handles)
CBtable=get(handles.CBtable,'Data');
CBtable(length(CBtable(:,1)),:)=[];
set(handles.CBtable,'Data',CBtable);

%% Creates functions, not edited in this code
function editIRS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textkWh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editTilt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupModality_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupCondTemp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textDCACRatio_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textGripEfficiency_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SpotEff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textInverterCost_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupCondChoice_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textConductorRating_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textVD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textIndex_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textRawSpot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textLaborSpots_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textRawTray1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textRawTray2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textLaborCond2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textLaborCond1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textLaborCond3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textLaborTray1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function textLaborTray2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupModule_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupInverter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupLocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDollarPerKWH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function maxCostDPW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editkWh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editVD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function GrIPeff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function costGrIP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ACMW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function table1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function costSpot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editDCAC1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSpace_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupModuleNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function spotEfficiency_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function costInverter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tableVariance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Array2Inverter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function groundClearance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editTotW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function gapSpace_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function InvPerPad_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listSPOTs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listTables_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function axesInverter_CreateFcn(hObject, eventdata, handles)

function axesSun_CreateFcn(hObject, eventdata, handles)
axes(hObject);
imshow('sun.jpg')

function AlenconLogo_CreateFcn(hObject, eventdata, handles)
axes(hObject);
imshow('AlenconLogo.png')


function toggleScroll_Callback(hObject, eventdata, handles)
global sortedDataC sortedDataA i j
if get(handles.VD_DPW,'Value')==1;
    if get(handles.toggleScroll,'Value')==0
        sortRow=2;
    elseif get(handles.toggleScroll,'Value')==1
        sortRow=4;
    end
elseif get(handles.kWh_DPW,'Value')==1;
    if get(handles.toggleScroll,'Value')==0
        sortRow=3;
    elseif get(handles.toggleScroll,'Value')==1
        sortRow=4;
    end
end

if get(handles.toggleScroll,'Value')==1
    set(handles.toggleScroll,'String','Cost')
elseif get(handles.toggleScroll,'Value')==0
    set(handles.toggleScroll,'String','Loss')
end

[sortedDataA,index1]= sortrows(sortedDataA,sortRow);
[sortedDataC,index2]= sortrows(sortedDataC,sortRow);
i=find(index1==i);
j=find(index2==j);

function togglePrefabSpot_Callback(hObject, eventdata, handles)
global prefab
if get(handles.togglePrefabSpot,'Value')==0
    set(handles.togglePrefabSpot,'String','1')
    prefab.spotPer=1;
elseif get(handles.togglePrefabSpot,'Value')==1
    set(handles.togglePrefabSpot,'String','2')
    prefab.spotPer=2;
end

function toggleCondType_Callback(hObject, eventdata, handles)
global type% 1=Cu, 0=Al
if get(handles.toggleCondType,'Value')==0
    set(handles.toggleCondType,'String','Al')
      type =  [1,0,NaN,NaN; % 1=Cu, 0=Al
    1,0,0,0];
elseif get(handles.toggleCondType,'Value')==1
    set(handles.toggleCondType,'String','Cu')
    type =  [1,1,NaN,NaN; % 1=Cu, 0=Al
    1,1,1,1];
end
global Tc
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

% Prices
global wirePriceCu2kV wirePriceAl2kV wirePriceAl1kV wirePriceCu1kV
global priceString
global convPriceTrunk alenconPriceTrunk 
if type(2,3)==1 %1=copper
    alenconPriceTrunk= wirePriceCu2kV;
elseif type(2,3)==0
    alenconPriceTrunk = wirePriceAl2kV;
end

if type(1,2)==1 %1=copper
    convPriceTrunk = wirePriceCu1kV;
else
    convPriceTrunk = wirePriceAl1kV;
end

priceString=wirePriceCu1kV;


function toggleCondTemp_Callback(hObject, eventdata, handles)
global Tc
if get(handles.toggleCondTemp,'Value')==0
    set(handles.toggleCondTemp,'String','75C')
    Tc =    [75, 75,NaN,NaN;
            75, 75, 75, 75];
elseif get(handles.toggleCondTemp,'Value')==1
    set(handles.toggleCondTemp,'String','90C')
    Tc =    [75, 90,NaN,NaN;
            75, 75, 90, 90];
end


function togglePrefabDir_Callback(hObject, eventdata, handles)
global prefab
if get(handles.togglePrefabDir,'Value')==1
    set(handles.togglePrefabDir,'String','Vertical')
    prefab.dir=1; % Vertical=1
elseif get(handles.togglePrefabDir,'Value')==0
    set(handles.togglePrefabDir,'String','Horizontal')
    prefab.dir=0; % Vertical=1
end
%% Array Layout

function popupModuleNumber_Callback(hObject, eventdata, handles)
global eleDim modPV internal corner alenconInternal
modCellarray=get(handles.popupModuleNumber,'String');
modIndex=get(handles.popupModuleNumber,'Value');
eleDim.vertModules=str2double(modCellarray{modIndex});

guidata(hObject, handles);
editTilt_Callback(hObject, eventdata, guidata(hObject))

if eleDim.modality==1 % Landscape
    stringLength=((modPV.mps-1)*(modPV.module_length+eleDim.gapSpacing));
    toStringLength=((modPV.mps)*(modPV.module_length+eleDim.gapSpacing));
    stringWidth=(eleDim.vertModules)*(modPV.module_width+eleDim.gapSpacing);
    eleDim.totW=(4/eleDim.vertModules)*toStringLength;
    set(handles.editTotW,'String',eleDim.totW)
else %portrait
    stringLength=(modPV.mps*(modPV.module_width+eleDim.gapSpacing));
    toStringLength=((modPV.mps)*(modPV.module_width+eleDim.gapSpacing));
    stringWidth=(eleDim.vertModules)*(modPV.module_length+eleDim.gapSpacing);
    eleDim.totW=(4/eleDim.vertModules)*toStringLength;
    set(handles.editTotW,'String',eleDim.totW)
end

if corner==0 % Center
    if eleDim.modality==0 % Portrait
        if eleDim.vertModules==4 % 4 Portrait center
            internal=stringLength*2+2*((3*(modPV.module_length+eleDim.gapSpacing))+(1*(modPV.module_length+eleDim.gapSpacing)));
        elseif eleDim.vertModules==2 % 2 Portrait center
            internal=stringLength*4+(2*(modPV.module_length+eleDim.gapSpacing));
        elseif eleDim.vertModules==1 % 1 Portrait center
            internal=stringLength*4+2*toStringLength;
        end
        
    elseif eleDim.modality==1 % Landscape 
        if eleDim.vertModules==4 % 4 Landscape center
            internal=stringLength*2+2*(sum([1.5,3.5]*(modPV.module_width+eleDim.gapSpacing)));
        elseif eleDim.vertModules==2 % 2 Landscape center
            internal=stringLength*4;
        end
    end
    
elseif corner==1 % Corner
    if eleDim.modality==0 % Portrait
        if eleDim.vertModules==4 % 4 Portrait
            internal=stringLength*4+(sum([1,2,3]*(modPV.module_length+eleDim.gapSpacing)));
        elseif eleDim.vertModules==2 % 2 Portrait
            internal=stringLength*4+(2*toStringLength)+2*2*(modPV.module_length+eleDim.gapSpacing);
        elseif eleDim.vertModules==1 % 1 Portrait
            internal=stringLength*4+sum(sum([1,2,3]*toStringLength));
        end
    end
    
    if eleDim.modality==1 % Landscape
        if eleDim.vertModules==4 % 4 Landscape
            internal=stringLength*4+sum([.5,1.5,2.5,3.5]*modPV.module_width);
        elseif eleDim.vertModules==2 % 2 Landscape
            internal=stringLength*4+2*toStringLength+(2*(1.5+0.5)*(modPV.module_width+eleDim.gapSpacing));
        end
    end
end

% internal=(internal+(eleDim.tableTop2CB*4))*2;
%         internal=(eleDim.vertModules*sum(stringLength:stringLength:eleDim.totW))+...
%             (sum((0:(modPV.module_length+eleDim.gapSpacing):eleDim.lengthTable)))+...
%             (eleDim.vertModules)*eleDim.tableTop2CB;
%     elseif eleDim.modality==1 %Landscape Center
%         internal=(eleDim.vertModules*sum(stringLength:stringLength:eleDim.totW))+...
%             sum((0:(modPV.module_width+eleDim.gapSpacing):eleDim.lengthTable))+...
%             (eleDim.vertModules)*eleDim.tableTop2CB;
% %     if eleDim.modality==0 %Portrait Corner
% %         internal=(2*eleDim.vertModules*sum(stringLength:stringLength:eleDim.totW))+...
%             (2*sum((0:(modPV.module_length+eleDim.gapSpacing):eleDim.lengthTable)))+...
%             (2*eleDim.vertModules)*eleDim.tableTop2CB;
%     elseif eleDim.modality==1 %Landscape Corner
%         internal=(2*eleDim.vertModules*sum(stringLength:stringLength:eleDim.totW))+...
%             2*sum((0:(modPV.module_width+eleDim.gapSpacing):eleDim.lengthTable))+...
%             (2*eleDim.vertModules)*eleDim.tableTop2CB;
%     end
% % else
% %     alenconInternal = internal;
% end
tables=str2double(get(handles.listTables,'String'));
spots=str2double(get(handles.listSPOTs,'String'));
tables=min(spots(1),tables(1));
set(handles.textArea,'String',num2str(tables*eleDim.totW*eleDim.totH));
set(handles.textInternalResult,'String',num2str(internal));

function toggleModality_Callback(hObject, eventdata, handles)
global eleDim
if get(handles.toggleModality,'Value')==0
    set(handles.popupModuleNumber,'String',{1;2;4})
    set(handles.popupModuleNumber,'Value',2);
    set(handles.toggleModality,'String','Portrait')
    eleDim.modality=0;  %portrait=0;
elseif get(handles.toggleModality,'Value')==1
    set(handles.popupModuleNumber,'String',{1;2;4})
    set(handles.popupModuleNumber,'Value',3);
    set(handles.toggleModality,'String','Landscape')
    eleDim.modality=1;  
end
guidata(hObject, handles);
popupModuleNumber_Callback(hObject, eventdata, guidata(hObject))

function editTilt_Callback(hObject, eventdata, handles)
axes(handles.axesModule)
global eleDim modPV
cla
rowSpace=str2num(get(handles.editSpace,'String'));
tilt=str2num(get(handles.editTilt,'String'));
vertSpace=eleDim.vertSpace;
modNum=eleDim.vertModules;
modality=eleDim.modality;
if modality==0 %portrait
    eleDim.lengthTable=((modPV.module_length+eleDim.gapSpacing)*eleDim.vertModules)-eleDim.gapSpacing;
else
    eleDim.lengthTable=((modPV.module_width+eleDim.gapSpacing)*eleDim.vertModules)-eleDim.gapSpacing;
end
x=eleDim.lengthTable*cosd(tilt);
y=eleDim.lengthTable*sind(tilt);
eleDim.tableTop2CB=y;
plotLength=get(handles.axesModule,'XLim');
for space=0:rowSpace:plotLength(2)
    hold all
    line([space space+x],[vertSpace y+vertSpace])
    line([space+x/2 space+x/2],[0 y/2+vertSpace],'Color',[.2 .2 .2],'LineWidth',1.5)
    plot(space:x/modNum:space+x,vertSpace:y/modNum:vertSpace+y,'y*','MarkerSize',2)
end

function editSpace_Callback(hObject, eventdata, handles)
global eleDim
eleDim.totH=str2double(get(handles.editSpace,'String'));
tables=str2double(get(handles.listTables,'String'));
spots=str2double(get(handles.listSPOTs,'String'));
tables=min(spots(1),tables(1));
set(handles.textArea,'String',num2str(tables*eleDim.totW*eleDim.totH));
guidata(hObject, handles);
editTilt_Callback(hObject, eventdata, guidata(hObject))

function groundClearance_Callback(hObject, eventdata, handles)
global eleDim
eleDim.vertSpace=str2double(get(handles.groundClearance,'String'));
guidata(hObject, handles);
editTilt_Callback(hObject, eventdata, guidata(hObject))

function gapSpace_Callback(hObject, eventdata, handles)
global eleDim
eleDim.gapSpacing=str2double(get(handles.gapSpace,'String'))/100;
guidata(hObject, handles);
editTilt_Callback(hObject, eventdata, guidata(hObject));
guidata(hObject, handles);
popupModuleNumber_Callback(hObject, eventdata, guidata(hObject));

function Array2Inverter_Callback(hObject, eventdata, handles)
global eleDim
eleDim.array2Inverter=str2double(get(handles.Array2Inverter,'String'));

%% DC Size
function editDCAC1_Callback(hObject, eventdata, handles)
global modPV eleDim inv internal
% Array sizes
AC_MW=str2double(get(handles.ACMW,'String'));
tablekW=(modPV.Vmp*modPV.Imp*modPV.mps*4)/1000;
% DC:AC ratios entered
DC_AC1=str2double(get(handles.editDCAC1,'String'));
DC_AC2=str2double(get(handles.editDCAC2,'String'));
% number of tables and SPOTs start
numSPOT_start=floor(((AC_MW*DC_AC1*1000)/tablekW)/4)*4;
numTables_start=floor(((AC_MW*DC_AC1*1000)/tablekW)/(2*(inv.num_inverters/inv.perPad)))*(2*(inv.num_inverters/inv.perPad));
% number of tables and SPOTs stop
numSPOT_stop=floor(((AC_MW*DC_AC2*1000)/tablekW)/4)*4;
numTables_stop=floor(((AC_MW*DC_AC2*1000)/tablekW)/(2*(inv.num_inverters/inv.perPad)))*(2*(inv.num_inverters/inv.perPad));
% number of tables and SPOTs range
SPOT_range=numSPOT_start:4:numSPOT_stop;
tables_range=numTables_start:(2*(inv.num_inverters/inv.perPad)):numTables_stop;
% fixed DC:AC 1
DCAC1=(min(numTables_start,numSPOT_start)*tablekW)/(AC_MW*1000);
set(handles.editDCAC1,'String',num2str(DCAC1));
% fixed DC:AC 21.3      
DCAC2=(max(numTables_stop,numSPOT_stop)*tablekW)/(AC_MW*1000);
set(handles.editDCAC2,'String',num2str(DCAC2));
% set range in tables
set(handles.listTables,'String',mat2cell(tables_range,1,ones(1,length(tables_range)))');
% set range in SPOTs
set(handles.listSPOTs,'String',mat2cell(SPOT_range,1,ones(1,length(SPOT_range)))');

numTable=min(SPOT_range(1),tables_range(1));
% Determine number of modules 
totalModules=(numTable*eleDim.modperTable);
set(handles.numModules,'String',num2str(totalModules));

%Determine updated array area
set(handles.textArea,'String',num2str(numTable*eleDim.totW*eleDim.totH));
% determine updated internal wiring
set(handles.textInternalResult,'String',num2str(numTable*internal));

function editDCAC2_Callback(hObject, eventdata, handles)
global modPV inv
% Array sizes
AC_MW=str2double(get(handles.ACMW,'String'));
tablekW=(modPV.Vmp*modPV.Imp*modPV.mps*4)/1000;
% DC:AC ratios entered
DC_AC1=str2double(get(handles.editDCAC1,'String'));
DC_AC2=str2double(get(handles.editDCAC2,'String'));
% number of tables and SPOTs start
numSPOT_start=floor(((AC_MW*DC_AC1*1000)/tablekW)/4)*4;
numTables_start=floor(((AC_MW*DC_AC1*1000)/tablekW)/(2*(inv.num_inverters/inv.perPad)))*(2*(inv.num_inverters/inv.perPad));
% number of tables and SPOTs stop
numSPOT_stop=floor(((AC_MW*DC_AC2*1000)/tablekW)/4)*4;
numTables_stop=floor(((AC_MW*DC_AC2*1000)/tablekW)/(2*(inv.num_inverters/inv.perPad)))*(2*(inv.num_inverters/inv.perPad));
% number of tables and SPOTs range
SPOT_range=numSPOT_start:4:numSPOT_stop;
tables_range=numTables_start:(2*(inv.num_inverters/inv.perPad)):numTables_stop;
% fixed DC:AC 1
DCAC1=(min(numTables_start,numSPOT_start)*tablekW)/(AC_MW*1000);
set(handles.editDCAC1,'String',num2str(DCAC1));
% fixed DC:AC 2
DCAC2=(max(numTables_stop,numSPOT_stop)*tablekW)/(AC_MW*1000);
set(handles.editDCAC2,'String',num2str(DCAC2));
% set range in tables
set(handles.listTables,'String',mat2cell(tables_range,1,ones(1,length(tables_range)))');
% set range in SPOTs
set(handles.listSPOTs,'String',mat2cell(SPOT_range,1,ones(1,length(SPOT_range)))');

% % Determine number of modules 
% totalModules=(numTable*eleDim.modperTable);
% set(handles.numModules,'String',num2str(totalModules));
% 
% %Determine updated array area
% set(handles.textArea,'String',num2str(numTable*eleDim.totW*eleDim.totH));

% function popupTable_Callback(hObject, eventdata, handles)
% global eleDim modPV
% numTable=str2double(get(handles.table1,'String'));
% numTable=floor(numTable/4)*4;
% set(handles.table1,'String',numTable);
% 
% %Determine DC:AC from tables
% tablekW=(modPV.Vmp*modPV.Imp*modPV.mps*4)/1000;
% AC_MW=str2double(get(handles.ACMW,'String'));
% DCAC=(numTable*tablekW)/(AC_MW*1000);
% set(handles.textDCAC,'String',num2str(DCAC));
% 
% %Determine number of modules
% totalModules=(numTable*eleDim.modperTable);
% set(handles.numModules,'String',num2str(totalModules));
% 
% %Determine updated array area
% set(handles.textArea,'String',num2str(numTable*eleDim.totW*eleDim.totH));

function ACMW_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
editDCAC1_Callback(hObject, eventdata, guidata(hObject))
guidata(hObject, handles);
editDCAC2_Callback(hObject, eventdata, guidata(hObject))
% guidata(hObject, handles);
% popupTable_Callback(hObject, eventdata, guidata(hObject))

function MinTemp_Callback(hObject, eventdata, handles)
global Tmin
Tmin=str2double(get(handles.MinTemp,'String'));
guidata(hObject, handles);
popupModule_Callback(hObject, eventdata, guidata(hObject))

function MinTemp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% Module info
function popupModule_Callback(hObject, eventdata, handles)
moduleProductName=get(handles.popupModule,'String');
inverterProductName=get(handles.popupInverter,'String');
inverterIndex=get(handles.popupInverter,'Value');
moduleIndex=get(handles.popupModule,'Value');
global modPV

global ncellsx
global moduleWidth
if moduleIndex==1
    moduleWidth =.992;
    ncellsx =6;
elseif moduleIndex==2
    moduleWidth = .992;
    ncellsx = 6;
elseif moduleIndex==3
    moduleWidth = .992;
    ncellsx = 6;
elseif moduleIndex==4
    moduleWidth = 1;
    ncellsx = 6;
elseif moduleIndex==5
    moduleWidth = .600;
    ncellsx = 4;
elseif moduleIndex==6
    moduleWidth = 1.046;
    ncellsx = 8;
end

% Update global variables with the new module and inverter
updateModuleAndInverter(moduleProductName{moduleIndex},inverterProductName{inverterIndex},moduleWidth,ncellsx);
set(handles.textVoc,'String',strcat('Voc: ',num2str(modPV.Voc)));
set(handles.textIsc,'String',strcat('Isc: ',num2str(modPV.Isc)));
set(handles.textCells,'String',strcat('Cells: ',num2str(modPV.cells)));
set(handles.textPmax,'String',strcat('Pmax: ',num2str(modPV.Vmp*modPV.Imp)));
set(handles.textMpS,'String',strcat('Modules per String: ',num2str(modPV.mps)));
set(handles.textSpotkW,'String',num2str((modPV.Vmp*modPV.Imp*modPV.mps*4)/1000))

% Change number of tables based on module
guidata(hObject, handles);
editDCAC1_Callback(hObject, eventdata, guidata(hObject));
guidata(hObject, handles);
popupModuleNumber_Callback(hObject, eventdata, guidata(hObject));

% Inverter Info
function popupInverter_Callback(hObject, eventdata, handles)
inverterProductName=get(handles.popupInverter,'String');
moduleProductName=get(handles.popupModule,'String');
inverterIndex=get(handles.popupInverter,'Value');
moduleIndex=get(handles.popupModule,'Value');
global ncellsx
global moduleWidth
% Update global variables with the new module and inverter
updateModuleAndInverter(moduleProductName{moduleIndex},inverterProductName{inverterIndex},moduleWidth,ncellsx);
global inv
set(handles.InvkW,'String',num2str((inv.paco)/1000))


function GUIfigure_ResizeFcn(hObject, eventdata, handles)


function spotEfficiency_Callback(hObject, eventdata, handles)


function costSpot_Callback(hObject, eventdata, handles)


function GrIPeff_Callback(hObject, eventdata, handles)


function costGrIP_Callback(hObject, eventdata, handles)


function maxCostDPW_Callback(hObject, eventdata, handles)


function tableVariance_Callback(hObject, eventdata, handles)



function editDCAC2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in panelLossAnalysis.
function panelLossAnalysis_SelectionChangeFcn(hObject, eventdata, handles)
global yLim yLimPrevious

if isempty(yLimPrevious)
   yLim = [0 2]; % GWh default value
else
    yLim=yLimPrevious;
end

yLimPrevious = [str2double(get(handles.minLoss,'String')),str2double(get(handles.maxLoss,'String'))];
if get(handles.VD_DPW,'Value')==1
    set(handles.textLoss,'String','VD');
    set(handles.minLoss,'String',num2str(yLim(1)));
    set(handles.maxLoss,'String',num2str(yLim(2)));
else
    set(handles.textLoss,'String','GWh');
    set(handles.minLoss,'String',num2str(yLim(1)));
    set(handles.maxLoss,'String',num2str(yLim(2)));
end

function editVD_Callback(hObject, eventdata, handles)
function InvPerPad_Callback(hObject, eventdata, handles)
function listTables_Callback(hObject, eventdata, handles)
function listSPOTs_Callback(hObject, eventdata, handles)
function editkWh_Callback(hObject, eventdata, handles)


function minCostDPW_Callback(hObject, eventdata, handles)


function minCostDPW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function maxLoss_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function minLoss_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu25_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function modelSPOT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu27_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxLoss_Callback(hObject, eventdata, handles)
function minLoss_Callback(hObject, eventdata, handles)
function partLoad_Callback(hObject, eventdata, handles)
function popupmenu25_Callback(hObject, eventdata, handles)
function modelSPOT_Callback(hObject, eventdata, handles)
function popupmenu27_Callback(hObject, eventdata, handles)


function cornerCheck_Callback(hObject, eventdata, handles)
global modPV corner
if (mod(modPV.mps,2)~=0)
    set(handles.cornerCheck,'Value',1);
end
corner=get(handles.cornerCheck,'Value');
% 
% guidata(hObject, handles);
% popupModuleNumber_Callback(hObject, eventdata, guidata(hObject))
