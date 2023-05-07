function varargout = microWiz(varargin)
% MICROWIZ MATLAB code for microWiz.fig
%      MICROWIZ, by itself, creates a new MICROWIZ or raises the existing
%      singleton*.
%
%      H = MICROWIZ returns the handle to a new MICROWIZ or the handle to
%      the existing singleton*.
%
%      MICROWIZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MICROWIZ.M with the given input arguments.
%
%      MICROWIZ('Property','Value',...) creates a new MICROWIZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before microWiz_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to microWiz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help microWiz

% Last Modified by GUIDE v2.5 08-Jan-2022 12:30:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @microWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @microWiz_OutputFcn, ...
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


% --- Executes just before microWiz is made visible.
function microWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to microWiz (see VARARGIN)

% Choose default command line output for microWiz
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

saveEd = imread('saveNew.png');
set(handles.save,'CData', saveEd);
cross = imread('cross.png');
set(handles.clearFields,'CData', cross);
wizIm = imread('wizIm.png');
imshow(wizIm);
params = [60; 5; 3.8; 30; 5; 8; 2.5; 4; 3];
setappdata(findobj('Tag', 'microWiz'), 'params', params);
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);

% bespoke icon
javaFrame = get(hObject,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon('icon.png'));
% UIWAIT makes microWiz wait for user response (see UIRESUME)
% uiwait(handles.microWiz);


% --- Outputs from this function are returned to the command line.
function varargout = microWiz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% for reference:
% flowLength = params(1);
% offSet = params(2);
% bore = params(3);
% drainCut = params(4);
% inletLength = params(5);
% wallDim = params(6);
% headDepth = params(7);
% coverDepth = params(8);
% flowDepth = params(9);
% baseDepth = params(10);
params = getappdata(findobj('Tag', 'microWiz'),'params');
params

% parameter check
if any(params == 0)
    f = msgbox('Inputs must be non-zero!');
    pause(1);
    close(f);
else if any(sign(params) == -1)
        f = msgbox('Inputs must be positive!');
        pause(1);
        close(f);
    else
        setappdata(findobj('Tag', 'sliceView'), 'Mparams', params);
        close(gcf);
    end
end


% --- Executes on button press in save.
function clearFields_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = zeros(10,1);
setappdata(findobj('Tag', 'microWiz'), 'params', params);
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
set(handles.A,'string','0');
set(handles.B,'string','0');
set(handles.C,'string','0');
set(handles.D,'string','0');
set(handles.E,'string','0');
set(handles.F,'string','0');
set(handles.G,'string','0');
set(handles.H,'string','0');
set(handles.I,'string','0');


function A_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.A,'String'); %returns contents of input as text
a = [text];
if isnan(str2double(a))
    f = msgbox('Input must be numeric!');
    pause(1);
    close(f);
    set(handles.A,'string','0');
else
    params(1) = str2num(a);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function B_Callback(hObject, eventdata, handles)
% hObject    handle to B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.B,'String'); %returns contents of input as text
b = [text];
if isnan(str2double(b))
    f = msgbox('Input must be numeric!');
    pause(1);
    close(f);
    set(handles.B,'string','0');
else
    params(2) = str2num(b);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of B as text
%        str2double(get(hObject,'String')) returns contents of B as a double


% --- Executes during object creation, after setting all properties.
function B_CreateFcn(hObject, eventdata, handles)
% hObject    handle to B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C_Callback(hObject, eventdata, handles)
% hObject    handle to C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.C,'String'); %returns contents of input as text
c = [text];
if isnan(str2double(c))
    f = msgbox('Input must be numeric!');
    pause(1);
    close(f);
    set(handles.C,'string','0');
else
    params(3) = str2num(c);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of C as text
%        str2double(get(hObject,'String')) returns contents of C as a double


% --- Executes during object creation, after setting all properties.
function C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function D_Callback(hObject, eventdata, handles)
% hObject    handle to D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.D,'String'); %returns contents of input as text
d = [text];
if isnan(str2double(d))
    f = msgbox('Input must be numeric!');
    pause(1);
    close(f);
    set(handles.D,'string','0');
else
    params(4) = str2num(d);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of D as text
%        str2double(get(hObject,'String')) returns contents of D as a double


% --- Executes during object creation, after setting all properties.
function D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Callback(hObject, eventdata, handles)
% hObject    handle to E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.E,'String'); %returns contents of input as text
e = [text];
if isnan(str2double(e))
    f = msgbox('Input must be numeric!');
    pause(1);
    close(f);
    set(handles.E,'string','0');
else
    params(5) = str2num(e);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of E as text
%        str2double(get(hObject,'String')) returns contents of E as a double


% --- Executes during object creation, after setting all properties.
function E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function F_Callback(hObject, eventdata, handles)
% hObject    handle to F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.F,'String'); %returns contents of input as text
f = [text];
if isnan(str2double(f))
    fig = msgbox('Input must be numeric!');
    pause(1);
    close(fig);
    set(handles.F,'string','0');
else
    params(6) = str2num(f);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of F as text
%        str2double(get(hObject,'String')) returns contents of F as a double


% --- Executes during object creation, after setting all properties.
function F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G_Callback(hObject, eventdata, handles)
% hObject    handle to G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.G,'String'); %returns contents of input as text
g = [text];
if isnan(str2double(g))
    fig = msgbox('Input must be numeric!');
    pause(1);
    close(fig);
    set(handles.G,'string','0');
else
    params(7) = str2num(g);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of G as text
%        str2double(get(hObject,'String')) returns contents of G as a double


% --- Executes during object creation, after setting all properties.
function G_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function H_Callback(hObject, eventdata, handles)
% hObject    handle to H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.H,'String'); %returns contents of input as text
h = [text];
if isnan(str2double(h))
    fig = msgbox('Input must be numeric!');
    pause(1);
    close(fig);
    set(handles.H,'string','0');
else
    params(8) = str2num(h);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of H as text
%        str2double(get(hObject,'String')) returns contents of H as a double


% --- Executes during object creation, after setting all properties.
function H_CreateFcn(hObject, eventdata, handles)
% hObject    handle to H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function I_Callback(hObject, eventdata, handles)
% hObject    handle to I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'microWiz'), 'params');
setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);
text=get(handles.I,'String'); %returns contents of input as text
i = [text];
if isnan(str2double(i))
    fig = msgbox('Input must be numeric!');
    pause(1);
    close(fig);
    set(handles.I,'string','0');
else
    params(9) = str2num(i);
    setappdata(findobj('Tag', 'microWiz'), 'params', params);
end
% Hints: get(hObject,'String') returns contents of I as text
%        str2double(get(hObject,'String')) returns contents of I as a double


% --- Executes during object creation, after setting all properties.
function I_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
