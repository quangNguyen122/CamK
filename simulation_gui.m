function varargout = simulation_gui(varargin)
% SIMULATION_GUI MATLAB code for simulation_gui.fig
%      SIMULATION_GUI, by itself, creates a new SIMULATION_GUI or raises the existing
%      singleton*.
%
%      H = SIMULATION_GUI returns the handle to a new SIMULATION_GUI or the handle to
%      the existing singleton*.
%
%      SIMULATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMULATION_GUI.M with the given input arguments.
%
%      SIMULATION_GUI('Property','Value',...) creates a new SIMULATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simulation_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simulation_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simulation_gui

% Last Modified by GUIDE v2.5 24-Jul-2016 22:59:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simulation_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @simulation_gui_OutputFcn, ...
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


% --- Executes just before simulation_gui is made visible.
function simulation_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simulation_gui (see VARARGIN)

% Choose default command line output for simulation_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes simulation_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simulation_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ************************ BROWSE BUTTON *********************************
% --- Executes on button press in btn_browse.
function btn_browse_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get new video file
[filename, path] = uigetfile({'*.*','All Files' });
set(handles.text_filename, 'String', filename);
if filename == 0
    msgbox('No file chosen', 'Warning: no file selected')
    return
end

% Loading video
set(handles.text_status, 'String', 'Loading video... Please wait')
handles.v = VideoReader([path,filename]);
handles.nFrames = handles.v.NumberOfFrames;
handles.vidH = handles.v.Height;
handles.vidW = handles.v.Width;

% Preallocate movie structure
set(handles.text_status, 'String', 'Preallocating... It may take a while. Please wait')
handles.mov(1:handles.nFrames) = ...
    struct('cdata', zeros(handles.vidH, handles.vidW, 3, 'uint8'), ...
            'colormap', []);
        
% Read on frame at a time
hwb = waitbar(0, 'Prellocating movie structure. Please wait ...');
for i = 1:handles.nFrames
    handles.mov(i).cdata = read(handles.v, i);
    waitbar(i/handles.nFrames);
end
close(hwb);
set(handles.text_status, 'String', 'Done')

% Set up slider
set(handles.slider_framenum, 'Min', 1,...
                     'Max', handles.nFrames', ...
                     'Value', 1);
                 
imshow(handles.mov(get(handles.slider_framenum, 'Value')).cdata, 'Parent', handles.axes_rawimage);
        
% Update handles
guidata(hObject, handles);


% ************************ SLIDER *********************************
% --- Executes during object creation, after setting all properties.
function slider_framenum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_framenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider_framenum_Callback(hObject, eventdata, handles)
% hObject    handle to slider_framenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Get current frame
curFrame = ceil(get(hObject, 'Value'));
handles = singleframe_processing(handles, curFrame);

guidata(hObject, handles)


% ******************** SET CURRENT FRAME *********************************
% --- Executes during object creation, after setting all properties.
function edit_framenum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_framenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_framenum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_framenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_framenum as text
%        str2double(get(hObject,'String')) returns contents of edit_framenum as a double

set(handles.slider_framenum, 'Value', str2double(get(hObject, 'String')));


% ************************** SET OFFSET *********************************
% --- Executes during object creation, after setting all properties.
function edit_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_offset as text
%        str2double(get(hObject,'String')) returns contents of edit_offset as a double
offset = str2double(get(hObject, 'String'));
[Ori_GrK, curPoint] = fingertipdetection(I, offset);


% ******************** START/PLAY/PAUSE BUTTON ***************************
% --- Executes during object creation, after setting all properties.
function pb_play_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes on button press in pb_play.

function pb_play_Callback(hObject, eventdata, handles)
% hObject    handle to pb_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nFrame = handles.nFrames;

% Perfome frame-to-frame simulation
if(strcmp(get(hObject,'String'),'Start'))
    set(hObject, 'String', 'Pause')
    for curFrame = 1:nFrame
        fprintf('Frame no. %d\n', curFrame);
        try
            tic;
            handles = singleframe_processing(handles, curFrame);
            tElapsed = toc
            drawnow;
        catch e
            if strcmp(e.identifier, 'MATLAB:class:InvalidHandle')
                return
            end
            disp('THE PROGRAM TERMINATED')
        end
    end
elseif (strcmp(get(hObject,'String'),'Pause'))
    set(hObject, 'String', 'Play')
    uiwait();
elseif (strcmp(get(hObject, 'String'), 'Play'))
    set(hObject, 'String', 'Pause');
    uiresume();
end

guidata(hObject, handles);



% **************** CUSTOMIZED FUNCTIONS *********************************
% ==================== MAIN FUNCTION - PROCESSING ========================
function handles = singleframe_processing(handles, curFrame)
persistent preCanddt curCanddt

if isempty(preCanddt) preCanddt = zeros(1,2); end
if isempty(curCanddt) curCanddt = 100*ones(1,2); end    % 100: arbitrary large enough number

% Update GUI
set(handles.edit_framenum, 'String', num2str(curFrame));    % edit framenum
set(handles.slider_framenum, 'Value', curFrame);                     % slider

% Show image
I = handles.mov(curFrame).cdata;
imshow(I, 'Parent', handles.axes_rawimage);

% ========================= Process image ===============================
set(handles.text_status, 'String', 'Processing ...');
offset = str2double(get(handles.edit_offset, 'String'));

% Detect fingertips and show them
[Ori_GrK, curPoint] = fingertipdetection(I, offset); % Significant cost = 0.35-0.38s
if ~isscalar(curPoint)  % means fingertip detected
    set(handles.text_fingertip, 'ForegroundColor', [1 0 0]);
    
    % ===== Keystroke Detection ====
    % 1. Find candidate finger
    preCanddt = curCanddt;
    curCanddt = findCanddt(curPoint);
    if isKeyStroke(curCanddt, preCanddt, 5)
        set(handles.text_keystroke, 'ForegroundColor', [0.1 0.5 0.5])
    else
        set(handles.text_keystroke, 'ForegroundColor', [0.2 0.2 0.2]);
    end
else
    set(handles.text_fingertip, 'ForegroundColor', [0.2 0.2 0.2]);
end

set(handles.text_status, 'String', 'Done');

drawnow;

% -----------------------------------------------------
function canddt = findCanddt(curPoint)
% In:
%   curPoint: cell containing all coordinates of fingertip
% Out:
%   canddit:  vector containing coordinate of candidate finger (lowest y)
y = curPoint(:,1);
if size(curPoint, 1) == 1
    canddt = curPoint;
else
    canddt = curPoint(find(y== max(y)), :);
end

% -----------------------------------------------------
function bol = isKeyStroke(curCanddt, preCanddt, delta_r)
    % In case there are more than 1 finger detected, skip
    if size(curCanddt, 1) == 2
        bol = 0;
        return
    end
    
    term = sum((curCanddt - preCanddt).^2);
    if term <= delta_r
        bol = 1;
    else
        bol = 0;
    end
  
% -------------------------------------------------------
% TODO: Generalize this function, determine keyboard from the calibration
% process
function K = loadkeyboard()
try 
    K_temp = load('Key_Struct');
catch e
    if strcmp(e.identifier, 'MATLAB:load:couldNotReadFile')
        errordlg('Could not found the keyboard layout')
    end
end
K = K_temp.K;

% -------------------------------------------------------
function setKeyboard()
global S_avg
global K

K = loadkeyboard();

% Find S_avg as Average size of key area
if ~exist(S_avg)
    S_avg = 0;
    for i = 1 : length(K)
        S_avg = S_avg + K{i}.area;
    end
    S_avg = S_avg / (64 + 5 - 1);
end