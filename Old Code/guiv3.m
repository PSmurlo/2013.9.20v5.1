function varargout = guiv3(varargin)
% GUIV3 MATLAB code for guiv3.fig
%      GUIV3, by itself, creates a new GUIV3 or raises the existing
%      singleton*.
%
%      H = GUIV3 returns the handle to a new GUIV3 or the handle to
%      the existing singleton*.
%
%      GUIV3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIV3.M with the given input arguments.
%
%      GUIV3('Property','Value',...) creates a new GUIV3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiv3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiv3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiv3

% Last Modified by GUIDE v2.5 27-Aug-2013 11:15:30

%#ok<*DEFNU,*INUSD,*INUSL>

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiv3_OpeningFcn, ...
                   'gui_OutputFcn',  @guiv3_OutputFcn, ...
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


% --- Executes just before guiv3 is made visible.
function guiv3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiv3 (see VARARGIN)

%% Global declaration
global modality
modality=0;                 %portrait=0;
global Tmin
Tmin= -14;                  % ASHRAE Mean Low Temp
global Ta
Ta = 37;                    % ASHRAE High Ambient Temperature
% *FIND CORRESPONDING CELL TEMPERATURES*

%% Load Module Data
% Load CEC module database
if (exist('finishdata','var')==0 || exist('finishdatacell','var')==0)
    load('Libraries\CEClibrary.mat');
    load('Libraries\CEClib_strings.mat');
end

% Search for Module Name
moduleName='Renesola Jiangsu JC300M-24-Ab'; % must be exact from library
mod_addr=(find(strcmp(moduleName,finishdatacell))/2+.5); %/2+.5 because counts both values

% % Search for Inverter Name (NOT Included yet)
% pv_inverter='SMA America: SC500CP-US 270V [CEC 2012]'; % must be exact from library
% inv_addr=(find(strcmp(pv_inverter,finishdatacell))/2+.5);

% Module Manual Entry
modPV.module_length=1.956;                      % Module length (m)
modPV.ncellx=6;                                 % Number of cells on top

% CEC Module Parameters
global modPV
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
modPV.module_width=modPV.mod_area/modPV.module_length;% Module width (m)
modPV.ncelly=modPV.cells/modPV.ncellx;                % Number of cells longways
modPV.ndiode=modPV.ncellx/2;                          % Number of bypass diodes
modPV.type=       finishdatacell{2,mod_addr};   % Module Type
modPV.module_string=moduleName; % Module Name
% modPV.mps= floor(inv.vdcmax/(modPV.Voc-(modPV.beta_oc*(25-modPV.Tmin)))); % Module Per String
% modPV.vmpmax = modPV.mps * (modPV.Vmp - ((modPV.gamma_r/modPV.Imp) * (25 - modPV.Ta))); % used for VD calc of string wiring
% celltype=type2celltypebool(modPV.type);       % Module type index (6par)
clear 'finishdatacell'
clear 'finishdata'

% Wire Prices
load('wirePriceFt.mat');
global wirePriceCu
global wirePriceAl
% *Add 1kv Cu price*
wirePriceCu = wirePriceFtCu * 3.28; % dollars per kilometer
wirePriceAl = wirePriceFtAl * 3.28; % dollars per kilometer

global Tc % Temperature rating of the conductor
Tc =    [75, 75,NaN,NaN;
         75, 75, 75, 75]; 
global type % The material of the conductor
type =  [1,0,NaN,NaN;
         1,1,1,1];
% Resistances
    % Conventional
global m2cbRes
m2cbRes = resistLookup(Tc(1,1),type(1,1));
global cb2invRes
cb2invRes = resistLookup(Tc(1,2),type(1,2));
    % Alencon
global m2spotRes
m2spotRes = resistLookup(Tc(2,1),type(2,1));
global spot2prefabRes
spot2prefabRes = resistLookup(Tc(2,2),type(2,2));
global prefabRes
prefabRes = resistLookup(Tc(2,3),type(2,3));
global trunk2gripRes
trunk2gripRes = resistLookup(Tc(2,4),type(2,4));

global tablelabels
tablelabels = {'Array',...
    'Total Cost of System',...
    'Max Volt Drop %',...
    '$/W',...
    'Cost of Conductor',...
    'Cost of Tray',...
    'Cost of Labor',...
    'Length of Module Wiring',...
    'Length of Trunk Wiring',...
    'Array Height in tables',...
    'Array Width in tables',...
    'Number of Combiner Boxes/SPOTs',...
    'Cost of Combiner Boxes/SPOTs',...
    'Inverters Total Cost',...
    'Trunk Wire Size'};

%% Conventional


%% Alencon Default Inputs

global inputs

inputs.costs.raw.m2cbtray = 23;
inputs.costs.raw.cb2invtray = 40;
inputs.costs.raw.cbs = 1500;
% inputs.costs.raw.strings = str2double(get(handles.textRawStrings,'String'));
% inputs.costs.raw.s2t = str2double(get(handles.textRawSpot2Trunk,'String'));
% inputs.costs.raw.t2i = str2double(get(handles.textRawTrunk2Inv,'String'));

inputs.costs.labor.m2cbtray = 2;
inputs.costs.labor.cb2invtray = 2;
inputs.costs.labor.cbs = 500;
% inputs.costs.labor.strings = str2double(get(handles.textLaborStrings,'String'));
inputs.costs.labor.m2cb = .25;
inputs.costs.labor.cb2inv = 20;


inputs.costs.raw.s2ttray = 23;
inputs.costs.raw.t2itray = 26;
inputs.costs.raw.spots = 2000;

inputs.costs.labor.s2ttray = 1;
inputs.costs.labor.t2itray = 1;
inputs.costs.labor.spots = 200;
inputs.costs.labor.strings = .25;
inputs.costs.labor.s2t = 1.5;
inputs.costs.labor.t2i = 3;

set(handles.sliderRawS2TTray,'Value',inputs.costs.raw.s2ttray)
set(handles.textRawS2TTray,'String',inputs.costs.raw.s2ttray)
set(handles.sliderRawT2ITray,'Value',inputs.costs.raw.t2itray)
set(handles.textRawT2ITray,'String',inputs.costs.raw.t2itray)
set(handles.sliderRawSpot,'Value',inputs.costs.raw.spots)
set(handles.textRawSpot,'String',inputs.costs.raw.spots)
set(handles.sliderLaborS2T,'Value',inputs.costs.labor.s2t)
set(handles.textLaborS2T,'String',inputs.costs.labor.s2t)
set(handles.sliderLaborS2TTray,'Value',inputs.costs.labor.s2ttray)
set(handles.textLaborS2TTray,'String',inputs.costs.labor.s2ttray)
set(handles.sliderLaborT2I,'Value',inputs.costs.labor.t2i)
set(handles.textLaborT2I,'String',inputs.costs.labor.t2i)
set(handles.sliderLaborT2ITray,'Value',inputs.costs.labor.t2itray)
set(handles.textLaborT2ITray,'String',inputs.costs.labor.t2itray)
set(handles.sliderLaborStrings,'Value',inputs.costs.labor.strings)
set(handles.textLaborStrings,'String',inputs.costs.labor.strings)
set(handles.sliderLaborSpots,'Value',inputs.costs.labor.spots)
set(handles.textLaborSpots,'String',inputs.costs.labor.spots)

load('sizesAWG.mat')

global finalDataA sortedDataA finalDataC sortedDataC tableData
[finalDataA] = optGraphAlencon(inputs);
[finalDataC] = ConventionalOptimizationv3(inputs);
sortedDataA = sortrows(finalDataA,3);
sortedDataC = sortrows(finalDataC,3);

handles.s1 = scatter(handles.axes,finalDataA(:,3),finalDataA(:,2),45,'x');
hold on
handles.s2 = scatter(handles.axes,finalDataC(:,3),finalDataC(:,2),45,'red','x');
grid on
xlim([.2 .4]);
ylim([0 4]);
legend([handles.s1 handles.s2],{'Alencon','Conventional'},'Location','Southeast')
set(get(handles.axes,'XLabel'),'String','BOS $/W');
set(get(handles.axes,'YLabel'),'String','Max Voltage Drop Percent');
set(get(handles.axes,'Title'),'String','Max VDP vs. $/W');
% line([min(finalData(:,3)),min(finalData(:,3))],[0,2])

global i
i = 1;
handles.sp1 = scatter(handles.axes,sortedDataA(i,3),sortedDataA(i,2),60,'k','o');
handles.sp2 = scatter(handles.axes,sortedDataC(i,3),sortedDataC(i,2),60,'k','o');

tableDataA = sortedDataA(1,:);
wireNames = sizes(tableDataA(:,14))';
tableDataA(:,14) = [];
tableDataA = num2cell(tableDataA);
tableDataA = horzcat('Alencon',tableDataA,wireNames);

tableDataC = sortedDataC(1,:);
wireNames = sizes(tableDataC(:,14))';
tableDataC(:,14) = [];
tableDataC = num2cell(tableDataC);
tableDataC = horzcat('Conventional',tableDataC,wireNames);

tableData = vertcat(tablelabels,tableDataA,tableDataC);

set(handles.uitable3,'Data',tableData);

handles.timer = timer('ExecutionMode','fixedRate',...
                    'Period', .5,...
                    'TimerFcn', {@GUIUpdate,handles});
                

% Choose default command line output for guiv3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes guiv3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiv3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderRawSpot_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawSpot,'String',num2str(get(handles.sliderRawSpot,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawSpot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function textRawSpot_Callback(hObject, eventdata, handles)
% hObject    handle to textRawSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawSpot,'Value',str2double(get(handles.textRawSpot,'String')));

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

function textRawTrunk2Inv_Callback(hObject, eventdata, handles)
% hObject    handle to textRawTrunk2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawTrunk2Inv,'Value',str2double(get(handles.textRawTrunk2Inv,'String')));

% Hints: get(hObject,'String') returns contents of textRawTrunk2Inv as text
%        str2double(get(hObject,'String')) returns contents of textRawTrunk2Inv as a double


% --- Executes during object creation, after setting all properties.
function textRawTrunk2Inv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawTrunk2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawTrunk2Inv_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawTrunk2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawTrunk2Inv,'String',num2str(get(handles.sliderRawTrunk2Inv,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawTrunk2Inv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawTrunk2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textLaborT2I_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborT2I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborT2I,'Value',str2double(get(handles.textLaborT2I,'String')));

% Hints: get(hObject,'String') returns contents of textLaborT2I as text
%        str2double(get(hObject,'String')) returns contents of textLaborT2I as a double


% --- Executes during object creation, after setting all properties.
function textLaborT2I_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborT2I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborT2I_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborT2I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborT2I,'String',num2str(get(handles.sliderLaborT2I,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborT2I_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborT2I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function textLaborS2T_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborS2T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborS2T,'Value',str2double(get(handles.textLaborS2T,'String')));

% Hints: get(hObject,'String') returns contents of textLaborS2T as text
%        str2double(get(hObject,'String')) returns contents of textLaborS2T as a double


% --- Executes during object creation, after setting all properties.
function textLaborS2T_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborS2T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborS2T_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborS2T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborS2T,'String',num2str(get(handles.sliderLaborS2T,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborS2T_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborS2T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textLaborS2TTray_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborS2TTray,'Value',str2double(get(handles.textLaborS2TTray,'String')));

% Hints: get(hObject,'String') returns contents of textLaborS2TTray as text
%        str2double(get(hObject,'String')) returns contents of textLaborS2TTray as a double


% --- Executes during object creation, after setting all properties.
function textLaborS2TTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborS2TTray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborS2TTray,'String',num2str(get(handles.sliderLaborS2TTray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborS2TTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textLaborSpots_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborSpots,'Value',str2double(get(handles.textLaborSpots,'String')));

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


% --- Executes on slider movement.
function sliderLaborSpots_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborSpots,'String',num2str(get(handles.sliderLaborSpots,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborSpots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textLaborStrings_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborStrings,'Value',str2double(get(handles.textLaborStrings,'String')));

% Hints: get(hObject,'String') returns contents of textLaborStrings as text
%        str2double(get(hObject,'String')) returns contents of textLaborStrings as a double


% --- Executes during object creation, after setting all properties.
function textLaborStrings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborStrings_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborStrings,'String',num2str(get(handles.sliderLaborStrings,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborStrings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textLaborT2ITray_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborT2ITray,'Value',str2double(get(handles.textLaborT2ITray,'String')));

% Hints: get(hObject,'String') returns contents of textLaborT2ITray as text
%        str2double(get(hObject,'String')) returns contents of textLaborT2ITray as a double


% --- Executes during object creation, after setting all properties.
function textLaborT2ITray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborT2ITray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborT2ITray,'String',num2str(get(handles.sliderLaborT2ITray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborT2ITray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawT2ITray_Callback(hObject, eventdata, handles)
% hObject    handle to textRawT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawT2ITray,'Value',str2double(get(handles.textRawT2ITray,'String')));

% Hints: get(hObject,'String') returns contents of textRawT2ITray as text
%        str2double(get(hObject,'String')) returns contents of textRawT2ITray as a double


% --- Executes during object creation, after setting all properties.
function textRawT2ITray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawT2ITray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawT2ITray,'String',num2str(get(handles.sliderRawT2ITray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawT2ITray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawT2ITray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawSpot2Trunk_Callback(hObject, eventdata, handles)
% hObject    handle to textRawSpot2Trunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawSpot2Trunk,'Value',str2double(get(handles.textRawSpot2Trunk,'String')));

% Hints: get(hObject,'String') returns contents of textRawSpot2Trunk as text
%        str2double(get(hObject,'String')) returns contents of textRawSpot2Trunk as a double


% --- Executes during object creation, after setting all properties.
function textRawSpot2Trunk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawSpot2Trunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawSpot2Trunk_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawSpot2Trunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawSpot2Trunk,'String',num2str(get(handles.sliderRawSpot2Trunk,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawSpot2Trunk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawSpot2Trunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawStrings_Callback(hObject, eventdata, handles)
% hObject    handle to textRawStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawStrings,'Value',str2double(get(handles.textRawStrings,'String')));

% Hints: get(hObject,'String') returns contents of textRawStrings as text
%        str2double(get(hObject,'String')) returns contents of textRawStrings as a double


% --- Executes during object creation, after setting all properties.
function textRawStrings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawStrings_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawStrings,'String',num2str(get(handles.sliderRawStrings,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawStrings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawStrings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawS2TTray_Callback(hObject, eventdata, handles)
% hObject    handle to textRawS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawS2TTray,'Value',str2double(get(handles.textRawS2TTray,'String')));

% Hints: get(hObject,'String') returns contents of textRawS2TTray as text
%        str2double(get(hObject,'String')) returns contents of textRawS2TTray as a double


% --- Executes during object creation, after setting all properties.
function textRawS2TTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawS2TTray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawS2TTray,'String',num2str(get(handles.sliderRawS2TTray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawS2TTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function uitable3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawS2TTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start(handles.timer)


function GUIUpdate(obj,event,handles)

global i finalDataA sortedDataA finalDataC sortedDataC inputs tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value') == 1
    inputs.costs.raw.s2ttray = str2double(get(handles.textRawS2TTray,'String'));
    inputs.costs.raw.t2itray = str2double(get(handles.textRawT2ITray,'String'));
    inputs.costs.raw.spots = str2double(get(handles.textRawSpot,'String'));
    
    inputs.costs.labor.s2ttray = str2double(get(handles.textLaborS2TTray,'String'));
    inputs.costs.labor.t2itray = str2double(get(handles.textLaborT2ITray,'String'));
    inputs.costs.labor.spots = str2double(get(handles.textLaborSpots,'String'));
    inputs.costs.labor.strings = str2double(get(handles.textLaborStrings,'String'));
    inputs.costs.labor.s2t = str2double(get(handles.textLaborS2T,'String'));
    inputs.costs.labor.t2i = str2double(get(handles.textLaborT2I,'String'));

    [finalDataA] = optGraphAlencon(inputs);
    pause(.5)

    set(handles.s1,'xdata',finalDataA(:,3));
    set(handles.s1,'ydata',finalDataA(:,2));

    sortedDataA = sortrows(finalDataA,3);
    tableDataA = sortedDataA(1,:);
    wireNames = sizes(tableDataA(:,14))';
    tableDataA(:,14) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);

    tableData(2,:) = tableDataA;

    set(handles.sp1,'xdata',sortedDataA(i,3));
    set(handles.sp1,'ydata',sortedDataA(i,2));
    set(handles.uitable3,'Data',[]);
    set(handles.uitable3,'Data',tableData);
else
    inputs.costs.raw.m2cbtray = str2double(get(handles.textRawS2TTray,'String'));
    inputs.costs.raw.cb2invtray = str2double(get(handles.textRawT2ITray,'String'));
    inputs.costs.raw.cbs = str2double(get(handles.textRawSpot,'String'));

    inputs.costs.labor.m2cbtray = str2double(get(handles.textLaborS2TTray,'String'));
    inputs.costs.labor.cb2invtray = str2double(get(handles.textLaborT2ITray,'String'));
    inputs.costs.labor.cbs = str2double(get(handles.textLaborSpots,'String'));
    inputs.costs.labor.m2cb = str2double(get(handles.textLaborS2T,'String'));
    inputs.costs.labor.cb2inv = str2double(get(handles.textLaborT2I,'String'));

    [finalDataC] = ConventionalOptimizationv3(inputs);
    pause(.5)

    set(handles.s2,'xdata',finalDataC(:,3));
    set(handles.s2,'ydata',finalDataC(:,2));

    sortedDataC = sortrows(finalDataC,3);
    tableDataC = sortedDataC(1,:);
    wireNames = sizes(tableDataC(:,14))';
    tableDataC(:,14) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);

    tableData(3,:) = tableDataC;

    set(handles.sp2,'xdata',sortedDataC(i,3));
    set(handles.sp2,'ydata',sortedDataC(i,2));
    set(handles.uitable3,'Data',[]);
    set(handles.uitable3,'Data',tableData);
end

% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stop(handles.timer)


% --- Executes on button press in toggleButton.
function toggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to toggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



if strcmp(get(handles.toggleButton,'String'),'Alencon')

else
    
end

% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i sortedDataA sortedDataC tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value')
    if i >= size(sortedDataA,1)
        i = 1;
    else
        i = i + 1;
    end
    
    set(handles.sp1,'xdata',sortedDataA(i,3));
    set(handles.sp1,'ydata',sortedDataA(i,2));
    
    tableDataA = sortedDataA(i,:);
    wireNames = sizes(tableDataA(:,14))';
    tableDataA(:,14) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(2,:) = tableDataA;
    
    set(handles.uitable3,'Data',tableData);
else
    if i >= size(sortedDataC,1)
        i = 1;
    else
        i = i + 1;
    end
    
    set(handles.sp2,'xdata',sortedDataC(i,3));
    set(handles.sp2,'ydata',sortedDataC(i,2));
    
    tableDataC = sortedDataC(i,:);
    wireNames = sizes(tableDataC(:,14))';
    tableDataC(:,14) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(3,:) = tableDataC;
    
    set(handles.uitable3,'Data',tableData);
end


% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i sortedDataA sortedDataC tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value') == 1
    
    if i <= 1
        i = size(sortedDataA,1);
    else
        i = i - 1;
    end
    
    set(handles.sp1,'xdata',sortedDataA(i,3));
    set(handles.sp1,'ydata',sortedDataA(i,2));
    
    tableDataA = sortedDataA(i,:);
    wireNames = sizes(tableDataA(:,14))';
    tableDataA(:,14) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);
    
    tableData(2,:) = tableDataA;
    
    set(handles.uitable3,'Data',tableData);
else
    if i <= 1
        i = size(sortedDataC,1);
    else
        i = i - 1;
    end
    
    set(handles.sp2,'xdata',sortedDataC(i,3));
    set(handles.sp2,'ydata',sortedDataC(i,2));
    
    tableDataC = sortedDataC(i,:);
    wireNames = sizes(tableDataC(:,14))';
    tableDataC(:,14) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);
    
    tableData(3,:) = tableDataC;
    
    set(handles.uitable3,'Data',tableData);
end


% --- Executes on button press in radioAlencon.
function radioAlencon_Callback(hObject, eventdata, handles)
% hObject    handle to radioAlencon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global i sortedDataA finalDataA inputs tableData
load('sizesAWG.mat')

set(handles.radioConventional,'Value',0);

%% Saving Values and Changing Display
    
    inputs.costs.raw.m2cbtray = str2double(get(handles.textRawS2TTray,'String'));
    inputs.costs.raw.cb2invtray = str2double(get(handles.textRawT2ITray,'String'));
    inputs.costs.raw.cbs = str2double(get(handles.textRawSpot,'String'));

    inputs.costs.labor.m2cbtray = str2double(get(handles.textLaborS2TTray,'String'));
    inputs.costs.labor.cb2invtray = str2double(get(handles.textLaborT2ITray,'String'));
    inputs.costs.labor.cbs = str2double(get(handles.textLaborSpots,'String'));
    inputs.costs.labor.strings = str2double(get(handles.textLaborStrings,'String'));
    inputs.costs.labor.m2cb = str2double(get(handles.textLaborS2T,'String'));
    inputs.costs.labor.cb2inv = str2double(get(handles.textLaborT2I,'String'));
    
    set(handles.sliderRawS2TTray,'Value',inputs.costs.raw.s2ttray)
    set(handles.textRawS2TTray,'String',inputs.costs.raw.s2ttray)
    set(handles.sliderRawT2ITray,'Value',inputs.costs.raw.t2itray)
    set(handles.textRawT2ITray,'String',inputs.costs.raw.t2itray)
    set(handles.sliderRawSpot,'Value',inputs.costs.raw.spots)
    set(handles.textRawSpot,'String',inputs.costs.raw.spots)
    set(handles.sliderLaborS2T,'Value',inputs.costs.labor.s2t)
    set(handles.textLaborS2T,'String',inputs.costs.labor.s2t)
    set(handles.sliderLaborS2TTray,'Value',inputs.costs.labor.s2ttray)
    set(handles.textLaborS2TTray,'String',inputs.costs.labor.s2ttray)
    set(handles.sliderLaborT2I,'Value',inputs.costs.labor.t2i)
    set(handles.textLaborT2I,'String',inputs.costs.labor.t2i)
    set(handles.sliderLaborT2ITray,'Value',inputs.costs.labor.t2itray)
    set(handles.textLaborT2ITray,'String',inputs.costs.labor.t2itray)
    set(handles.sliderLaborStrings,'Value',inputs.costs.labor.strings)
    set(handles.textLaborStrings,'String',inputs.costs.labor.strings)
    set(handles.sliderLaborSpots,'Value',inputs.costs.labor.spots)
    set(handles.textLaborSpots,'String',inputs.costs.labor.spots)
    
    %%
    
    set(handles.toggleButton,'String','Alencon')
    set(handles.boxRawText,'String','SPOTs')
    set(handles.boxLaborText,'String','SPOTs')
    set(handles.uipanel3,'Title','SPOT to Trunk');
    set(handles.uipanel5,'Title','SPOT to Trunk');
    set(handles.uipanel4,'Title','Trunk to Inverter');
    set(handles.uipanel6,'Title','Trunk to Inverter');

    [finalDataA] = optGraphAlencon(inputs);

    set(handles.s1,'xdata',finalDataA(:,3));
    set(handles.s1,'ydata',finalDataA(:,2));

    sortedDataA = sortrows(finalDataA,3);
    tableDataA = sortedDataA(1,:);
    wireNames = sizes(tableDataA(:,14))';
    tableDataA(:,14) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);

    tableData(2,:) = tableDataA;

    set(handles.sp1,'xdata',sortedDataA(i,3));
    set(handles.sp1,'ydata',sortedDataA(i,2));
    set(handles.uitable3,'Data',[]);
    set(handles.uitable3,'Data',tableData);
    set(handles.sliderLaborStrings,'Enable','on');
    set(handles.textLaborStrings,'Enable','on');

% Hint: get(hObject,'Value') returns toggle state of radioAlencon


% --- Executes on button press in radioConventional.
function radioConventional_Callback(hObject, eventdata, handles)
% hObject    handle to radioConventional (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global i sortedDataC finalDataC inputs tableData
load('sizesAWG.mat')

set(handles.radioAlencon,'Value',0);
    %% Saving Values and Changing Displays
    
    inputs.costs.raw.s2ttray = str2double(get(handles.textRawS2TTray,'String'));
    inputs.costs.raw.t2itray = str2double(get(handles.textRawT2ITray,'String'));
    inputs.costs.raw.spots = str2double(get(handles.textRawSpot,'String'));
    
    inputs.costs.labor.s2ttray = str2double(get(handles.textLaborS2TTray,'String'));
    inputs.costs.labor.t2itray = str2double(get(handles.textLaborT2ITray,'String'));
    inputs.costs.labor.spots = str2double(get(handles.textLaborSpots,'String'));
    inputs.costs.labor.strings = str2double(get(handles.textLaborStrings,'String'));
    inputs.costs.labor.s2t = str2double(get(handles.textLaborS2T,'String'));
    inputs.costs.labor.t2i = str2double(get(handles.textLaborT2I,'String'));
    
    set(handles.sliderRawS2TTray,'Value',inputs.costs.raw.m2cbtray)
    set(handles.textRawS2TTray,'String',inputs.costs.raw.m2cbtray)
    set(handles.sliderRawT2ITray,'Value',inputs.costs.raw.cb2invtray)
    set(handles.textRawT2ITray,'String',inputs.costs.raw.cb2invtray)
    set(handles.sliderRawSpot,'Value',inputs.costs.raw.cbs)
    set(handles.textRawSpot,'String',inputs.costs.raw.cbs)
    set(handles.sliderLaborS2T,'Value',inputs.costs.labor.m2cb)
    set(handles.textLaborS2T,'String',inputs.costs.labor.m2cb)
    set(handles.sliderLaborS2TTray,'Value',inputs.costs.labor.m2cbtray)
    set(handles.textLaborS2TTray,'String',inputs.costs.labor.m2cbtray)
    set(handles.sliderLaborT2I,'Value',inputs.costs.labor.cb2inv)
    set(handles.textLaborT2I,'String',inputs.costs.labor.cb2inv)
    set(handles.sliderLaborT2ITray,'Value',inputs.costs.labor.cb2invtray)
    set(handles.textLaborT2ITray,'String',inputs.costs.labor.cb2invtray)
    set(handles.sliderLaborSpots,'Value',inputs.costs.labor.cbs)
    set(handles.textLaborSpots,'String',inputs.costs.labor.cbs)
    %%
    [finalDataC] = ConventionalOptimizationv3(inputs);
    
    set(handles.s2,'xdata',finalDataC(:,3));
    set(handles.s2,'ydata',finalDataC(:,2));

    sortedDataC = sortrows(finalDataC,3);
    tableDataC = sortedDataC(1,:);
    wireNames = sizes(tableDataC(:,14))';
    tableDataC(:,14) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);

    tableData(3,:) = tableDataC;

    set(handles.sp2,'xdata',sortedDataC(i,3));
    set(handles.sp2,'ydata',sortedDataC(i,2));
    set(handles.uitable3,'Data',[]);
    set(handles.uitable3,'Data',tableData);
    set(handles.sliderLaborStrings,'Enable','off');
    set(handles.textLaborStrings,'Enable','off');
    
    set(handles.toggleButton,'String','Conventional')
    set(handles.boxRawText,'String','CBs')
    set(handles.boxLaborText,'String','CBs')
    set(handles.uipanel3,'Title','String to CB');
    set(handles.uipanel5,'Title','String to CB');
    set(handles.uipanel4,'Title','CB to Inverter');
    set(handles.uipanel6,'Title','CB to Inverter');

% Hint: get(hObject,'Value') returns toggle state of radioConventional


% --- Executes on button press in updateButton.
function updateButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global i finalDataA sortedDataA finalDataC sortedDataC inputs tableData
load('sizesAWG.mat')

if get(handles.radioAlencon,'Value') == 1
    inputs.costs.raw.s2ttray = str2double(get(handles.textRawS2TTray,'String'));
    inputs.costs.raw.t2itray = str2double(get(handles.textRawT2ITray,'String'));
    inputs.costs.raw.spots = str2double(get(handles.textRawSpot,'String'));
    
    inputs.costs.labor.s2ttray = str2double(get(handles.textLaborS2TTray,'String'));
    inputs.costs.labor.t2itray = str2double(get(handles.textLaborT2ITray,'String'));
    inputs.costs.labor.spots = str2double(get(handles.textLaborSpots,'String'));
    inputs.costs.labor.strings = str2double(get(handles.textLaborStrings,'String'));
    inputs.costs.labor.s2t = str2double(get(handles.textLaborS2T,'String'));
    inputs.costs.labor.t2i = str2double(get(handles.textLaborT2I,'String'));

    [finalDataA] = optGraphAlencon(inputs);

    set(handles.s1,'xdata',finalDataA(:,3));
    set(handles.s1,'ydata',finalDataA(:,2));

    sortedDataA = sortrows(finalDataA,3);
    tableDataA = sortedDataA(1,:);
    wireNames = sizes(tableDataA(:,14))';
    tableDataA(:,14) = [];
    tableDataA = num2cell(tableDataA);
    tableDataA = horzcat('Alencon',tableDataA,wireNames);

    tableData(2,:) = tableDataA;

    set(handles.sp1,'xdata',sortedDataA(i,3));
    set(handles.sp1,'ydata',sortedDataA(i,2));
    set(handles.uitable3,'Data',[]);
    set(handles.uitable3,'Data',tableData);
else
    inputs.costs.raw.m2cbtray = str2double(get(handles.textRawS2TTray,'String'));
    inputs.costs.raw.cb2invtray = str2double(get(handles.textRawT2ITray,'String'));
    inputs.costs.raw.cbs = str2double(get(handles.textRawSpot,'String'));

    inputs.costs.labor.m2cbtray = str2double(get(handles.textLaborS2TTray,'String'));
    inputs.costs.labor.cb2invtray = str2double(get(handles.textLaborT2ITray,'String'));
    inputs.costs.labor.cbs = str2double(get(handles.textLaborSpots,'String'));
    inputs.costs.labor.m2cb = str2double(get(handles.textLaborS2T,'String'));
    inputs.costs.labor.cb2inv = str2double(get(handles.textLaborT2I,'String'));

    [finalDataC] = ConventionalOptimizationv3(inputs);

    set(handles.s2,'xdata',finalDataC(:,3));
    set(handles.s2,'ydata',finalDataC(:,2));

    sortedDataC = sortrows(finalDataC,3);
    tableDataC = sortedDataC(1,:);
    wireNames = sizes(tableDataC(:,14))';
    tableDataC(:,14) = [];
    tableDataC = num2cell(tableDataC);
    tableDataC = horzcat('Conventional',tableDataC,wireNames);

    tableData(3,:) = tableDataC;

    set(handles.sp2,'xdata',sortedDataC(i,3));
    set(handles.sp2,'ydata',sortedDataC(i,2));
    set(handles.uitable3,'Data',[]);
    set(handles.uitable3,'Data',tableData);
end
