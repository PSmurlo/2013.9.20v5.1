function varargout = guiconv(varargin)
% GUICONV MATLAB code for guiconv.fig
%      GUICONV, by itself, creates a new GUICONV or raises the existing
%      singleton*.
%
%      H = GUICONV returns the handle to a new GUICONV or the handle to
%      the existing singleton*.
%
%      GUICONV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUICONV.M with the given input arguments.
%
%      GUICONV('Property','Value',...) creates a new GUICONV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiconv_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiconv_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiconv

% Last Modified by GUIDE v2.5 19-Aug-2013 10:27:44

%#ok<*DEFNU,*INUSD,*INUSL>

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiconv_OpeningFcn, ...
                   'gui_OutputFcn',  @guiconv_OutputFcn, ...
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


% --- Executes just before guiconv is made visible.
function guiconv_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiconv (see VARARGIN)

% Choose default command line output for guiconv
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiconv wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiconv_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function textLaborCb2Inv_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborCb2Inv,'Value',str2double(get(handles.textLaborCb2Inv,'String')));

% Hints: get(hObject,'String') returns contents of textLaborCb2Inv as text
%        str2double(get(hObject,'String')) returns contents of textLaborCb2Inv as a double


% --- Executes during object creation, after setting all properties.
function textLaborCb2Inv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborCb2Inv_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborCb2Inv,'String',num2str(get(handles.sliderLaborCb2Inv,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborCb2Inv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in buttonCalculate.
function buttonCalculate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCalculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

costs.inputs.raw.stringtray = str2double(get(handles.textRawStringsTray,'String'));
costs.inputs.raw.invtray = str2double(get(handles.textRawCBTray,'String'));
costs.inputs.raw.cbs = str2double(get(handles.textRawCBs,'String'));
costs.inputs.raw.strings = str2double(get(handles.textRawStrings,'String'));
costs.inputs.raw.cb2inv = str2double(get(handles.textRawCb2Inv,'String'));

costs.inputs.labor.stringtray = str2double(get(handles.textLaborCBTray,'String'));
costs.inputs.labor.invtray = str2double(get(handles.textLaborCBTray,'String'));
costs.inputs.labor.cbs = str2double(get(handles.textLaborCBs,'String'));
costs.inputs.labor.strings = str2double(get(handles.textLaborStrings,'String'));
costs.inputs.labor.cb2inv = str2double(get(handles.textLaborCBTray,'String'));


function textLaborCBTray_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborCBTray,'Value',str2double(get(handles.textLaborCBTray,'String')));

% Hints: get(hObject,'String') returns contents of textLaborCBTray as text
%        str2double(get(hObject,'String')) returns contents of textLaborCBTray as a double


% --- Executes during object creation, after setting all properties.
function textLaborCBTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborCBTray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborCBTray,'String',num2str(get(handles.sliderLaborCBTray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborCBTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textLaborCBs_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborCBs,'Value',str2double(get(handles.textLaborCBs,'String')));

% Hints: get(hObject,'String') returns contents of textLaborCBs as text
%        str2double(get(hObject,'String')) returns contents of textLaborCBs as a double


% --- Executes during object creation, after setting all properties.
function textLaborCBs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborCBs_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborCBs,'String',num2str(get(handles.sliderLaborCBs,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborCBs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawStringsTray_Callback(hObject, eventdata, handles)
% hObject    handle to textRawStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawStringsTray,'Value',str2double(get(handles.textRawStringsTray,'String')));

% Hints: get(hObject,'String') returns contents of textRawStringsTray as text
%        str2double(get(hObject,'String')) returns contents of textRawStringsTray as a double


% --- Executes during object creation, after setting all properties.
function textRawStringsTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawStringsTray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawStringsTray,'String',num2str(get(handles.sliderRawStringsTray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawStringsTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawCBs_Callback(hObject, eventdata, handles)
% hObject    handle to textRawCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawCBs,'Value',str2double(get(handles.textRawCBs,'String')));

% Hints: get(hObject,'String') returns contents of textRawCBs as text
%        str2double(get(hObject,'String')) returns contents of textRawCBs as a double


% --- Executes during object creation, after setting all properties.
function textRawCBs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawCBs_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawCBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawCBs,'String',num2str(get(handles.sliderRawCBs,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawCBs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawCBs (see GCBO)
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



function textLaborStringsTray_Callback(hObject, eventdata, handles)
% hObject    handle to textLaborStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderLaborStringsTray,'Value',str2double(get(handles.textLaborStringsTray,'String')));

% Hints: get(hObject,'String') returns contents of textLaborStringsTray as text
%        str2double(get(hObject,'String')) returns contents of textLaborStringsTray as a double


% --- Executes during object creation, after setting all properties.
function textLaborStringsTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textLaborStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLaborStringsTray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLaborStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textLaborStringsTray,'String',num2str(get(handles.sliderLaborStringsTray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderLaborStringsTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLaborStringsTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function textRawCb2Inv_Callback(hObject, eventdata, handles)
% hObject    handle to textRawCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawCb2Inv,'Value',str2double(get(handles.textRawCb2Inv,'String')));

% Hints: get(hObject,'String') returns contents of textRawCb2Inv as text
%        str2double(get(hObject,'String')) returns contents of textRawCb2Inv as a double


% --- Executes during object creation, after setting all properties.
function textRawCb2Inv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawCb2Inv_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawCb2Inv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawCb2Inv,'String',num2str(get(handles.sliderRawCb2Inv,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawCb2Inv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawCb2Inv (see GCBO)
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



function textRawCBTray_Callback(hObject, eventdata, handles)
% hObject    handle to textRawCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderRawCBTray,'Value',str2double(get(handles.textRawCBTray,'String')));

% Hints: get(hObject,'String') returns contents of textRawCBTray as text
%        str2double(get(hObject,'String')) returns contents of textRawCBTray as a double


% --- Executes during object creation, after setting all properties.
function textRawCBTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRawCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRawCBTray_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRawCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textRawCBTray,'String',num2str(get(handles.sliderRawCBTray,'Value')));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRawCBTray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRawCBTray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
