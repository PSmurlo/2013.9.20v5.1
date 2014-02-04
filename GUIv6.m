function varargout = GUIv6(varargin)
% GUIV6 MATLAB code for GUIv6.fig
%      GUIV6, by itself, creates a new GUIV6 or raises the existing
%      singleton*.
%
%      H = GUIV6 returns the handle to a new GUIV6 or the handle to
%      the existing singleton*.
%
%      GUIV6('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIV6.M with the given input arguments.
%
%      GUIV6('Property','Value',...) creates a new GUIV6 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIv6_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIv6_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIv6

% Last Modified by GUIDE v2.5 26-Nov-2013 13:12:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIv6_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIv6_OutputFcn, ...
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


% --- Executes just before GUIv6 is made visible.
function GUIv6_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIv6 (see VARARGIN)

% Choose default command line output for GUIv6
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIv6 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIv6_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
