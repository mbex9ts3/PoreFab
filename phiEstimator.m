function varargout = phiEstimator(varargin)
% PHIESTIMATOR MATLAB code for phiEstimator.fig
%      PHIESTIMATOR, by itself, creates a new PHIESTIMATOR or raises the existing
%      singleton*.
%
%      H = PHIESTIMATOR returns the handle to a new PHIESTIMATOR or the handle to
%      the existing singleton*.
%
%      PHIESTIMATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHIESTIMATOR.M with the given input arguments.
%
%      PHIESTIMATOR('Property','Value',...) creates a new PHIESTIMATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before phiEstimator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to phiEstimator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% edit the above text to modify the response to help phiEstimator

% Last Modified by GUIDE v2.5 02-Jan-2021 13:32:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phiEstimator_OpeningFcn, ...
                   'gui_OutputFcn',  @phiEstimator_OutputFcn, ...
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


% --- Executes just before phiEstimator is made visible.
function phiEstimator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to phiEstimator (see VARARGIN)

% Choose default command line output for phiEstimator
handles.output = hObject;

% icons
draw = imread('polygon.png');
set(handles.drawPoly,'CData', draw);
panIm = imread('panIm.png');
set(handles.pan,'CData', panIm);
undo = imread('undo.png');
set(handles.undo,'CData', undo);
% redo = imread('redo.png');
% set(handles.redo,'CData', redo);
zoom = imread('zoom.png');
set(handles.zoom,'CData', zoom);
cropIn = imread('ROIadd.png');
set(handles.crop,'CData', cropIn);
saveEd = imread('saveNew.png');
set(handles.save,'CData', saveEd);
setappdata(gcf,'drawFlag',false); 

% Update handles structure
guidata(hObject, handles);
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');

% create false RGB binary for display
imR = uint8(zeros(size(im,1), size(im,2)));
imG = uint8(zeros(size(im,1), size(im,2)));
imB = uint8(zeros(size(im,1), size(im,2)));
imR(im == true) = 255;
imG(im == true) = 255;
imB(im == true) = 255;
imRGB = uint8(zeros(size(im,1), size(im,2), 3));
imRGB(:,:,1) = imR;
imRGB(:,:,2) = imG;
imRGB(:,:,3) = imB;
imshow(imRGB);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off

setappdata(findobj('Tag', 'editPane'),'im',im);
setappdata(findobj('Tag', 'editPane'),'imBlank',im); 
setappdata(findobj('Tag', 'editPane'),'imRGB',imRGB);

setappdata(findobj('Tag', 'editPane'),'imUndo',nan); 
setappdata(findobj('Tag', 'editPane'),'imRGBUndo',nan);
setappdata(findobj('Tag', 'editPane'),'imBlankUndo',nan); 

setappdata(findobj('Tag', 'editPane'),'imRedo',nan); 
setappdata(findobj('Tag', 'editPane'),'imRGBRedo',nan); 
setappdata(findobj('Tag', 'editPane'),'imBlankRedo',nan); 

% bespoke icon
javaFrame = get(hObject,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon('icon.png'));
% UIWAIT makes phiEstimator wait for user response (see UIRESUME)
% uiwait(handles.editPane);


% --- Outputs from this function are returned to the command line.
function varargout = phiEstimator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pan.
function drawPoly_Callback(hObject, eventdata, handles)
% hObject    handle to pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'editPane'),'im');
% mask = getappdata(findobj('Tag', 'editPane'),'mask');
imRGB = getappdata(findobj('Tag', 'editPane'),'imRGB');
imBlank = getappdata(findobj('Tag', 'editPane'),'imBlank');

% display current image: maintain zoom
L = get(gca,{'xlim','ylim'});  % Get axes limits.
imshow(imRGB);
set(gca,{'xlim','ylim'},L);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off

% save current view
setappdata(findobj('Tag', 'editPane'),'imUndo',im); 
% setappdata(findobj('Tag', 'editPane'),'maskUndo',mask);
setappdata(findobj('Tag', 'editPane'),'imRGBUndo',imRGB);
setappdata(findobj('Tag', 'editPane'),'imBlankUndo',im); 


% sign
drawFlag = getappdata(findobj('Tag', 'editPane'),'drawFlag');

% draw edits
hpoly = impoly(gca);
BW = createMask(hpoly);

% assign edits to RGB for display
imR = imRGB(:,:,1);
imG = imRGB(:,:,2);
imB = imRGB(:,:,3);

if drawFlag == false
    % display false edits as red
    imR(BW == true) = 255;
    imR(imBlank == false) = 0;
    imG(BW == true) = 0;
    imB(BW == true) = 0;
    im(BW == true) = false;
else
    % display positive as white
    imR(BW == true) = 255;
    imG(BW == true) = 255;
    imB(BW == true) = 255;
    im(BW == true) = true;
    imBlank(BW == true) = true;
end
% imR(mask == false) = 0;
% imG(mask == false) = 0;
% imB(mask == false) = 0;
% im(mask == false) = false;
imRGB(:,:,1) = imR;
imRGB(:,:,2) = imG;
imRGB(:,:,3) = imB;

% display edited image: maintain zoom
L = get(gca,{'xlim','ylim'});  % Get axes limits.
imshow(imRGB);
set(gca,{'xlim','ylim'},L);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off

% save
setappdata(findobj('Tag', 'editPane'),'im',im);
setappdata(findobj('Tag', 'editPane'),'imBlank',imBlank);
setappdata(findobj('Tag', 'editPane'),'imRGB',imRGB);
% setappdata(findobj('Tag', 'editPane'),'mask',mask);


% --- Executes on button press in zoom.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save current view
im = getappdata(findobj('Tag', 'editPane'),'imUndo'); 
imBlank = getappdata(findobj('Tag', 'editPane'),'imBlankUndo'); 
% mask = getappdata(findobj('Tag', 'editPane'),'maskUndo');
imRGB = getappdata(findobj('Tag', 'editPane'),'imRGBUndo'); 
if isnan(im)
    f = msgbox('No previous image exists');
    pause(1);
    close(f);
else
    imUndo = getappdata(findobj('Tag', 'editPane'),'im');
%     maskUndo = getappdata(findobj('Tag', 'editPane'),'mask');
    imRGBUndo = getappdata(findobj('Tag', 'editPane'),'imRGB'); 
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imRGB);
    
    if isequal(sum(im), sum(imUndo)) % uncropped - keep same view
        set(gca,{'xlim','ylim'},L);
    end
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off

    setappdata(findobj('Tag', 'editPane'),'imUndo', imUndo);
%     setappdata(findobj('Tag', 'editPane'),'maskUndo', maskUndo);
    setappdata(findobj('Tag', 'editPane'),'imRGBUndo', imRGBUndo);
    setappdata(findobj('Tag', 'editPane'),'im', im);
%     setappdata(findobj('Tag', 'editPane'),'mask', mask);
    setappdata(findobj('Tag', 'editPane'),'imRGB', imRGB);
end
    



% --- Executes on button press in calcPhi.
function pan_Callback(hObject, eventdata, handles)
% hObject    handle to calcPhi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan on

% --- Executes on button press in calcPhi.
function zoom_Callback(hObject, eventdata, handles)
% hObject    handle to calcPhi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on

% --- Executes on button press in calcPhi.
function redo_Callback(hObject, eventdata, handles)
% hObject    handle to calcPhi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in calcPhi.
function edit_Callback(hObject, eventdata, handles)
% hObject    handle to calcPhi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function negative_Callback(hObject, eventdata, handles)
% hObject    handle to negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'positive'), 'Checked','off');
setappdata(gcf,'drawFlag',false);   


% --------------------------------------------------------------------
function positive_Callback(hObject, eventdata, handles)
% hObject    handle to positive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'negative'), 'Checked','off');
setappdata(gcf,'drawFlag',true);   


% --- Executes on button press in crop.
function crop_Callback(hObject, eventdata, handles)
% hObject    handle to crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'editPane'),'im');
imRGB = getappdata(findobj('Tag', 'editPane'),'imRGB');

% display current image: maintain zoom
L = get(gca,{'xlim','ylim'});  % Get axes limits.
imshow(imRGB);
set(gca,{'xlim','ylim'},L);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off
[imTRGB,rect] = imcrop(imRGB);
imT = imcrop(im, rect);

setappdata(findobj('Tag', 'editPane'),'imRGB',imTRGB);
setappdata(findobj('Tag', 'editPane'),'im',imT);
setappdata(findobj('Tag', 'editPane'),'imBlank',imT);

imshow(imTRGB);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'editPane'),'im');
setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
setappdata(findobj('Tag', 'sliceView'), 'editFlag', true);
% uiresume(gcf);
delete(gcf);
