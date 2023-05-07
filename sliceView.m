function varargout = sliceView(varargin)
% SLICEVIEW MATLAB code for sliceView.fig
%      SLICEVIEW, by itself, creates a new SLICEVIEW or raises the existing
%      singleton*.
%
%      H = SLICEVIEW returns the handle to a new SLICEVIEW or the handle to
%      the existing singleton*.
%
%      SLICEVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLICEVIEW.M with the given input arguments.
%
%      SLICEVIEW('Property','Value',...) creates a new SLICEVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sliceView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sliceView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sliceView

% Last Modified by GUIDE v2.5 10-Mar-2023 21:29:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sliceView_OpeningFcn, ...
                   'gui_OutputFcn',  @sliceView_OutputFcn, ...
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


% --- Executes just before sliceView is made visible.
function sliceView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sliceView (see VARARGIN)
iconPhoto = imread('folder_photo3.png');
set(handles.loadStack,'CData',iconPhoto);
iconImDisp = imread('imDisplay.png');
set(handles.imDisp,'CData', iconImDisp);
panIm = imread('panIm.png');
set(handles.panIm,'CData', panIm);
mask = imread('maskIn.png');
set(handles.mask,'CData', mask);
% redo = imread('redo.png');
% set(handles.rotate,'CData', redo);
zoom = imread('zoom.png');
set(handles.zoomIm,'CData', zoom);
draw = imread('pencil.png');
set(handles.drawEdit,'CData', draw);
mod = imread('micro.png');
set(handles.cellBuild,'CData', mod);
mod2 = imread('cellTick.png');
set(handles.cellSave,'CData', mod2);

% Create uipanel and daughter tabs
hp = findobj('Tag','topBar');
hp.Position
% p = uipanel('Position',[0 0 1 1-hp.Position(4)]);
p = uipanel('Position',[0 0 1 0.935]);

% p.Position = [0 0 1 1];
p.BackgroundColor = [0 0 0];
% uistack(p,'bottom');
[hleft,hright,hDiv1] = uisplitpane(p,'Orientation','hor','dividercolor',[173 235 255]/255, 'DividerWidth', 5, 'DividerLocation', 0.15);
hleft.Tag = 'pleft';
hright.Tag = 'pright';
vax2=axes('parent',hright); 
axis off; 
vax2.Tag = 'vaxr';
tgroup = uitabgroup('Parent', hleft);
imtab = uitab('Parent', tgroup, 'Title', 'Images', 'Tag', 'imtab');
meshtab = uitab('Parent', tgroup, 'Title', '...', 'Tag', 'meshtag');

% Choose default command line output for sliceView
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% [173 235 255]/255
% bespoke icon
javaFrame = get(hObject,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon('icon.png'));

% Choose default command line output for meshView
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% PC input flag
setappdata(gcf,'ptflag',false);    

% PC input flag
setappdata(gcf,'panFlag',false);    

% rotate style flag
setappdata(gcf,'rotflag',false);   

% draw tool sign (default is negative)
setappdata(gcf,'drawFlag',false);   

% lights off
setappdata(gcf, 'lightpos', 0);

% polygon not active
setappdata(gcf, 'polyState', 0);

% default view state 2D
setappdata(gcf, 'dimFlag', '2D');

% default view state 2D
setappdata(gcf, 'editflag', false); 

setappdata(findobj('Tag', 'sliceView'), 'imCurrent', nan);

setappdata(findobj('Tag', 'sliceView'), 'meshCurrent', nan);

setappdata(findobj('Tag', 'sliceView'), 'Mparams', nan);

% Initialize a timer, which executes its callback once after one second
timer1 = timer('Period', 0.5, 'TasksToExecute', 1, ...
          'ExecutionMode', 'fixedRate', ...
          'StartDelay', 0.5);
% Set the callback function and declare GUI handle as parameter
timer1.TimerFcn = {@timer1_Callback, findobj('name', 'PoreFab v1.1')};
timer1.StopFcn = @timer1_StopFcn;
start(timer1);
% compile command
% buildResults = compiler.build.standaloneWindowsApplication(appFile, 'ExecutableIcon','C:\PoreFab\microIcon.png', 'ExecutableName','PoreFab');


% timer1_Callback        
% --- Executes after each timer event of timer1.
function timer1_Callback(obj, eventdata, handle)

% Maximize the GUI window
maximize(handle);

% timer1_StopFcn        
% --- Executes after timer stop event of timer1.
function timer1_StopFcn(obj, eventdata)

% Delete the timer object
delete(obj);

% turn off java warning
w = warning('query','last');
id = w.identifier;
warning('off',id);


% global inputVolume
% inputVolume = false;
% UIWAIT makes sliceView wait for user response (see UIRESUME)
% uiwait(handles.sliceView);



% --- Outputs from this function are returned to the command line.
function varargout = sliceView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in loadStack.
function loadStack_Callback(hObject, eventdata, handles)
% hObject    handle to loadStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cutFlag = false;
[imList, pathname] = uigetfile({'*.tif;*.tiff*;*.bmp*; *.jpg*; *.jpeg*; *.png*', 'Image Data';...
          '*.*','All Files' },'Select slices',...
          'C:\', 'MultiSelect', 'on');

if ischar(imList) % duplicate single input then cut
    imList = [{imList} {imList}];
    cutFlag = true;
end

% load stack
% check if isempty
if iscell(imList) == false
    f = msgbox('Image selection cancelled');
    pause(1);
    close(f);
else
    h = waitbar(0,'Loading image data: Please wait...');
    steps = size(imList,2);
    for i = 1:size(imList,2)
        waitbar(i / steps);
        imStore{i} = imread([pathname imList{i}]);
    end
    close(h);
end

% imshow(imStore{i}, 'Parent', gca);
% caption = sprintf('Slide %d', 1);
% set(handles.slideLabel, 'String', caption);
% sizeX = num2str(size(testSlice,2)); sizeY = num2str(size(testSlice,1));

% locate tabs created at gui generation
hp1 = findobj('Tag','imtab');
hp1.Position
hp2 = findobj('Tag','topBar');
hp2.Position
p = uipanel('Parent', hp1, 'Position',[hp1.Position(1) hp1.Position(2) 1 1-hp2.Position(4)]);
% p = uipanel('Parent', hp1, 'Position',[0.5 0.5 0.5 0.5]);

% setup tree table
images = transpose(imList);
folderRoot = repmat({pathname}, size(images,1),1);
logi = repmat({false}, size(images,1),1);
dimString = cell(size(imList,2),1);
for i = 1:size(imList,2)
   dimString{i} = [num2str(size(imStore{i},2)) 'x' num2str(size(imStore{i},1))];
end


if cutFlag == true
    imStore(2) = [];
    folderRoot(2) = [];
    images(2) = [];
    logi(2) = [];
    dimString(2) = [];
end
setappdata(gcf,'imStore',imStore); 

% build uitree IO
headers = {'Folder','Name','Visible','Size'};
data = horzcat(folderRoot, images, logi, dimString);
colTypes = {'char','char','logical','char'};
colEditable = {false, true, false, false};
icons = {fullfile('image2.png'), ...
         fullfile(matlabroot,'/toolbox/matlab/icons/file_open.png'), ...
         fullfile(matlabroot,'/toolbox/matlab/icons/foldericon.gif'), ...
};

% check box flag
imActive = false(size(images,1),1);
setappdata(gcf,'imActive',imActive); 

% Create the table in the current figure
jtable = treeTable('Container',p, 'Headers',headers, 'Data',data, ...
                   'ColumnTypes',colTypes, 'ColumnEditable',colEditable, ...
                   'IconFilenames',icons, 'Groupable',true, 'InteractiveGrouping',false);

               
% --- Executes on button press in imDisp.
function imDisp_Callback(hObject, eventdata, handles)
% hObject    handle to imDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in cropRegion.
setappdata(findobj('Tag', 'sliceView'), 'meshCurrent', nan);
setappdata(gcf,'rotflag', false);
setappdata(findobj('Tag', 'sliceView'), 'meshCurrent', nan);


im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');

% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else
    % axes(hAxis.axesImage);
    cla;
    view(2);
    zoom reset;
    zoom off;
    rotate3d off;
    set(gca, 'units','normalized', 'Position',[-0.01 0 1.02 1]);
    imshow(im);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off    
    zoom(1);

end

% --- Executes on button press in panIm.
function panIm_Callback(hObject, eventdata, handles)
% hObject    handle to panIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% panFlag = getappdata(gcf,'panFlag')   
% if panFlag == false
%     pan on
%     setappdata(gcf,'panFlag', true);
% else
%     pan off
%     setappdata(gcf,'panFlag', false);
% end
pan on

% --- Executes on button press in zoomIm.
function zoomIm_Callback(hObject, eventdata, handles)
% hObject    handle to zoomIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on


% --- Executes on button press in cellBuild.
function cellBuild_Callback(hObject, eventdata, handles)
microWiz


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadStack.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to loadStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)
% hObject    handle to setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadImages_Callback(hObject, eventdata, handles)
% hObject    handle to loadImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function editIn_Callback(hObject, eventdata, handles)
% hObject    handle to editIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewSelect_Callback(hObject, eventdata, handles)
% hObject    handle to viewSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveStl_Callback(hObject, eventdata, handles)
% hObject    handle to saveStl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mesh = getappdata(findobj('Tag', 'sliceView'), 'meshCurrent');
if iscell(mesh) == false
    f = msgbox('No model created!');
    pause(1);
    close(f);
else
    faces = mesh{1};
    vertices = mesh{2};
    [file, path] = uiputfile('*.stl','Save model as .stl');
    stlwrite([path file], faces, vertices);
    f = msgbox('Your model is ready for printing!');
    pause(1);
    close(f);
end

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when sliceView is resized.
function sliceView_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to sliceView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function imProc_Callback(hObject, eventdata, handles)
% hObject    handle to imProc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in throats.
function throats_Callback(hObject, eventdata, handles)
% hObject    handle to throats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in modCell.
function modCell_Callback(hObject, eventdata, handles)
% hObject    handle to modCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function meshProc_Callback(hObject, eventdata, handles)
% hObject    handle to meshProc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function loadStack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function ImFilters_Callback(hObject, eventdata, handles)
% hObject    handle to ImFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RGB2gray_Callback(hObject, eventdata, handles)
% hObject    handle to RGB2gray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else
    % check if RGB
    if size(im,3) == 3 % RGB
        % axes(hAxis.axesImage);
        im = rgb2gray(im);
%         set(gca, 'units','normalized', 'Position',[-0.01 0 1.02 1]);
        setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
        L = get(gca,{'xlim','ylim'});  % Get axes limits.
        imshow(im);        
        set(gca,{'xlim','ylim'},L);
        ax = gca;               % get the current axis
        ax.Clipping = 'off';    % turn clipping off
        
    else
        f = msgbox('Input must be RGB');
        pause(1);
        close(f);
    end
end

% --- Executes on button press in drawEdit.
function drawEdit_Callback(hObject, eventdata, handles)
% hObject    handle to drawEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% L = get(gca,{'xlim','ylim'});  % Get axes limits.
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% drawFlag = getappdata(findobj('Tag', 'sliceView'), 'drawFlag');

if islogical(im) == false
    f = msgbox('Edited image must be binary!');
    pause(1);
    close(f);
else
    phiEstimator;
end

% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mask.
function mask_Callback(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if size(im,3) ~= 3
    f = msgbox('Edited image must be RGB!');
    pause(1);
    close(f);
else
    phiEstimator2;
end


% --- Executes on button press in rotate.
function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotFlag = getappdata(gcf,'rotflag');   
if rotFlag == false
    f = msgbox('Rotation is supported in 3D view only');
    pause(1);
    close(f);
else
    rotate3d on
%     trackball on; 
end


% --------------------------------------------------------------------
function imSeg_Callback(hObject, eventdata, handles)
% hObject    handle to imSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');

% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else if islogical(im) | size(im, 3) == 3
        f = msgbox('Image must be grayscale');
        pause(1);
        close(f);
        
    else
        imT = im;
%         xT = size(imT,2);
%         yT = size(imT,1);
%         
%         % compute n pixels needed
%         Target = xT/1.2;
%         pads = round((Target-yT)/2);
%         padOut = zeros(pads, xT);
%         imT = vertcat(padOut, imT, padOut);
        
        [lowThreshold, highThreshold, lastThresholdedBand] = threshold(83, 255, imT);
        imB = false(size(im,1), size(im,2));        
        imB(im > lowThreshold & im < highThreshold) = true;
        setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imB);
        set(gca, 'units','normalized', 'Position',[-0.01 0 1.02 1]);
        imshow(imB);
        ax = gca;               % get the current axis
        ax.Clipping = 'off';    % turn clipping off
    end
end


% --------------------------------------------------------------------
function invBin_Callback(hObject, eventdata, handles)
% hObject    handle to invBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else

    % populate
    im2 = false(size(im,1), size(im,2));
    im2(im == false) = true;
    
%     % repad
%     pads = cell2mat(padStore(imLogi));
%     pads = false(size(pads,1), size(pads,2));
%     size(pads)
%     size(im2)
%     logi = padLogi(imLogi);
%     if logi == true % vertical pads
%         im2(1:size(pads,1),:) = [];
%         im2(end-size(pads,2):end,:) = [];
%         im2 = vertcat(pads, im2, pads);
%     else % horizontal
%         size(im2)
%         size(pads)
%           im2(:,1:size(pads,2)) = [];
%           im2(:,end-size(pads,2):end) = [];
%           im2 = horzcat(pads, im2, pads);
%     end
    
%     set(gca, 'units','normalized', 'Position',[-0.01 0 1.02 1]);
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im2);    
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(im2);    
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
end

% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function morph_Callback(hObject, eventdata, handles)
% hObject    handle to morph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function erodeB_Callback(hObject, eventdata, handles)
% hObject    handle to erodeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');


% --------------------------------------------------------------------
function dilateB_Callback(hObject, eventdata, handles)
% hObject    handle to dilateB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function skelB_Callback(hObject, eventdata, handles)
% hObject    handle to skelB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
    im = bwmorph(im,'skel',Inf);
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(im);    
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    %     set(gca, 'units','normalized', 'Position',[-0.01 0 1.02 1]);
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
end

% --------------------------------------------------------------------
function perimB_Callback(hObject, eventdata, handles)
% hObject    handle to perimB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
    im = bwmorph(im,'remove');
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(im);    
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
end


% --------------------------------------------------------------------
function dilRect_Callback(hObject, eventdata, handles)
% hObject    handle to dilRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel x length (pixels):','Kernel x length (pixels):', 'Iterations:'};
    dlgtitle = 'Square dilate';
    dims = [1 45];
    definput = {'3','3', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    SE = strel('rectangle',[str2num(answer{1}) str2num(answer{2})]);
    imIn = im;
    for i = 1:str2num(answer{3})
        imIn = imdilate(imIn,SE);
    end
    
    % populate
    im2 = true(size(imIn,1), size(imIn,2));
    
    imIn(im2 == false) = false;
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);    
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off    
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);
end

% --------------------------------------------------------------------
function dilDiam_Callback(hObject, eventdata, handles)
% hObject    handle to dilDiam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel radius (pixels):', 'Iterations:'};
    dlgtitle = 'Diamond dilate';
    dims = [1 45];
    definput = {'3', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    SE = strel('diamond', str2num(answer{1}));
    imIn = im;
    for i = 1:str2num(answer{2})
        imIn = imdilate(imIn,SE);
    end            

    % populate
    im2 = true(size(imIn,1), size(imIn,2));
    imIn(im2 == false) = false;
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);
end

% --------------------------------------------------------------------
function dilDisk_Callback(hObject, eventdata, handles)
% hObject    handle to dilDisk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel x radius (pixels):','Structure approximations (integer):', 'Iterations:'};
    dlgtitle = 'Disk dilate';
    dims = [1 45];
    definput = {'3','8', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    SE = strel('disk',str2num(answer{1}), round(str2num(answer{2})));
    imIn = im;
    for i = 1:str2num(answer{3})
        imIn = imdilate(imIn,SE);
    end        

    % populate
    im2 = true(size(imIn,1), size(imIn,2));
    imIn(im2 == false) = false;
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);

end

% --------------------------------------------------------------------
function dilLine_Callback(hObject, eventdata, handles)
% hObject    handle to dilLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel length (pixels):','Kernel angle (degrees):', 'Iterations:'};
    dlgtitle = 'Line dilate';
    dims = [1 45];
    definput = {'3','90', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    degz = str2num(answer{2});
    if degz > 360
        degz = 360;
    end
    if degz < 0 
        degz = 0;
    end
    SE = strel('line',str2num(answer{1}), degz);
    imIn = im;
    for i = 1:str2num(answer{3})
        imIn = imdilate(imIn,SE);
    end        

    % populate
    im2 = true(size(imIn,1), size(imIn,2));
    imIn(im2 == false) = false;
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);

end

% --------------------------------------------------------------------
function erodeRect_Callback(hObject, eventdata, handles)
% hObject    handle to erodeRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel x length (pixels):','Kernel x length (pixels):', 'Iterations:'};
    dlgtitle = 'Square erode';
    dims = [1 45];
    definput = {'3','3', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    SE = strel('rectangle',[str2num(answer{1}) str2num(answer{2})]);
    imIn = im;
    for i = 1:str2num(answer{3})
        imIn = imerode(imIn,SE);
    end
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);
end

% --------------------------------------------------------------------
function erodeDia_Callback(hObject, eventdata, handles)
% hObject    handle to erodeDia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel radius (pixels):', 'Iterations:'};
    dlgtitle = 'Diamond erode';
    dims = [1 45];
    definput = {'3', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    SE = strel('diamond', str2num(answer{1}));
    imIn = im;
    for i = 1:str2num(answer{2})
        imIn = imerode(imIn,SE);
    end        
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);
end

% --------------------------------------------------------------------
function erodeDisk_Callback(hObject, eventdata, handles)
% hObject    handle to erodeDisk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel x radius (pixels):','Structure approximations (integer):', 'Iterations:'};
    dlgtitle = 'Disk erode';
    dims = [1 45];
    definput = {'3','8', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    SE = strel('disk',str2num(answer{1}), round(str2num(answer{2})));
    imIn = im;
    for i = 1:str2num(answer{3})
        imIn = imerode(imIn,SE);
    end        
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);
end

% --------------------------------------------------------------------
function erodeLine_Callback(hObject, eventdata, handles)
% hObject    handle to erodeLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel length (pixels):','Kernel angle (degrees):', 'Iterations:'};
    dlgtitle = 'Line erode';
    dims = [1 45];
    definput = {'3','90', '1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    degz = str2num(answer{2});
    if degz > 360
        degz = 360;
    end
    if degz < 0 
        degz = 0;
    end
    SE = strel('line',str2num(answer{1}), degz);
    imIn = im;
    for i = 1:str2num(answer{3})
        imIn = imerode(imIn,SE);
    end        
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imIn);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', imIn);
end


% --------------------------------------------------------------------
function imSharpen_Callback(hObject, eventdata, handles)
% hObject    handle to imSharpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else if islogical(im) | size(im, 3) == 3
        f = msgbox('Image must be grayscale');
        pause(1);
        close(f);
    else
        
    im = imsharpen(im);
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(im);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
    end
end


% --------------------------------------------------------------------
function smallSpot_Callback(hObject, eventdata, handles)
% hObject    handle to smallSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
prompt = {'Kernel length (pixels):'};
    dlgtitle = 'Small spot removal';
    dims = [1 45];
    definput = {'28'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    im = bwareaopen(im,str2num(answer{1}));
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(im);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
end


% --------------------------------------------------------------------
function holeFill_Callback(hObject, eventdata, handles)
% hObject    handle to holeFill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~islogical(im)
    f = msgbox('Input image must be binary');
    pause(1);
    close(f);
else
    im = imfill(im,'holes');
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(im);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
end


% --------------------------------------------------------------------
function draw_tool_sign_Callback(hObject, eventdata, handles)
% hObject    handle to draw_tool_sign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cellBuild.
function pushbutton39_Callback(hObject, eventdata, handles)
% hObject    handle to cellBuild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dispImC_Callback(hObject, eventdata, handles)
% hObject    handle to dispImC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flag = getappdata(findobj('Tag', 'sliceView'), 'editFlag');
if flag == true
    im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
    imshow(im);
    setappdata(findobj('Tag', 'sliceView'), 'editFlag', false);
else
    f = msgbox('No recently edited image available');
    pause(1);
    close(f);
end


% --- Executes on button press in cellSave.
function cellSave_Callback(hObject, eventdata, handles)
% hObject    handle to cellSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = getappdata(findobj('Tag', 'sliceView'), 'Mparams');
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if isnan(params)
    f = msgbox('Parameters not set!');
    pause(1);
    close(f);
else if ~islogical(im)
        f = msgbox('Image is not binary!');
        pause(1);
        close(f);
    else
        f = msgbox('Building mesh: please be patient');
        [faces, vertices, sizeInnerF, sizeInnerV] = microBuild2(params, im);
        close(f);
        mesh = cell(4,1);
        mesh{1} = faces;
        mesh{2} = vertices;
        mesh{3} = sizeInnerF;
        mesh{4} = sizeInnerV;
        setappdata(findobj('Tag', 'sliceView'), 'meshCurrent', mesh);
        f = msgbox('Mesh generation complete!');
        pause(1);
        close(f);
    end
end


% --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveIm_Callback(hObject, eventdata, handles)
% hObject    handle to saveIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
if ~isnan(im)
    [fn, ext, ucancel] = imputfile
end
if ucancel == false
    imwrite(im,fn);
end


% --------------------------------------------------------------------
function dispMesh_Callback(hObject, eventdata, handles)
% hObject    handle to dispMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% visualize inner mesh
mesh = getappdata(findobj('Tag', 'sliceView'), 'meshCurrent');
if ~iscell(mesh)
    f = msgbox('No active mesh available!');
    pause(1);
    close(f);
else
    setappdata(gcf,'rotflag', true);
    params = getappdata(findobj('Tag', 'sliceView'), 'Mparams');
    sc = params(1) + params(5);
    faces = mesh{1};
    vertices = mesh{2};
    sizeInnerF = mesh{3};
    sizeInnerV = mesh{4};
    
    cla;
    trimesh(faces(1:sizeInnerF-720,:),vertices(:,1), vertices(:,2), vertices(:,3), 'EdgeColor', [0.5 0.1 0.1], 'FaceColor', 'r', 'FaceAlpha', 0.6, 'EdgeAlpha', 0.6); axis equal;
    lighting gouraud
    grid off
    axis off
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
    set(gca,'CameraViewAngleMode','Manual')
    
%     hold on; % visualize outer mesh
%     trimesh(faces(sizeInnerF+1:end,:), vertices(:,1), vertices(:,2), vertices(:,3), 'EdgeColor', [0.5 0.1 0.1], 'FaceColor', 'r', 'FaceAlpha', 0.10, 'EdgeAlpha', 0); axis equal;
%     lighting gouraud
%     grid off
%     axis off
%     ax = gca;               % get the current axis
%     ax.Clipping = 'off';    % turn clipping off
%     set(gca,'CameraViewAngleMode','Manual')
    
%     % render wireframe
%     lines = vertices(sizeInnerV+1:end,:);
%     hold on; line(vertcat(lines(1:4,1), lines(1,1)), vertcat(lines(1:4,2), lines(1,2)), vertcat(lines(1:4,3), lines(1,3)), 'color', 'r');
%     hold on; line(vertcat(lines(5:8,1), lines(5,1)), vertcat(lines(5:8,2), lines(5,2)), vertcat(lines(5:8,3), lines(5,3)), 'color', 'r');
%     hold on; line(vertcat(lines(9:10,1), lines(9,1)), vertcat(lines(9:10,2), lines(9,2)), vertcat(lines(9:10,3), lines(9,3)), 'color', 'r');
%     hold on; line(vertcat(lines(11:12,1), lines(12,1)), vertcat(lines(11:12,2), lines(12,2)), vertcat(lines(11:12,3), lines(12,3)), 'color', 'r');
%     hold on; line(vertcat(lines(13:16,1), lines(13,1)), vertcat(lines(13:16,2), lines(13,2)), vertcat(lines(13:16,3), lines(13,3)), 'color', 'r');
%     hold on; line(vertcat(lines(13:16,1), lines(13,1)), vertcat(lines(13:16,2), lines(13,2)), vertcat(lines(13:16,3), lines(13,3)), 'color', 'r');
%     hold on; line(vertcat(lines(17:376,1), lines(17,1)), vertcat(lines(17:376,2), lines(17,2)), vertcat(lines(17:376,3), lines(17,3)), 'color', 'r');
%     hold on; line(vertcat(lines(377:736,1), lines(377,1)), vertcat(lines(377:736,2), lines(377,2)), vertcat(lines(377:736,3), lines(377,3)), 'color', 'r');
%     hold on; line(vertcat(lines(737:1096,1), lines(737,1)), vertcat(lines(737:1096,2), lines(737,2)), vertcat(lines(737:1096,3), lines(737,3)), 'color', 'r');
%     hold on; line(vertcat(lines(1097:1456,1), lines(1097,1)), vertcat(lines(1097:1456,2), lines(1097,2)), vertcat(lines(1097:1456,3), lines(1097,3)), 'color', 'r');
%     hold on; line(lines([1 5 8 4 1],1), lines([1 5 8 4 1],2), lines([1 5 8 4 1],3), 'color', 'r');
%     hold on; line(lines([2 9 13],1), lines([2 9 13],2), lines([2 9 13],3), 'color', 'r');
%     hold on; line(lines([3 10 16],1), lines([3 10 16],2), lines([3 10 16],3), 'color', 'r');
%     hold on; line(lines([6 11 14],1), lines([6 11 14],2), lines([6 11 14],3), 'color', 'r');
%     hold on; line(lines([7 12 15],1), lines([7 12 15],2), lines([7 12 15],3), 'color', 'r');
%     sphMesh = icoSphereMesh(1);
%     Fm = sphMesh(1).face;
%     Vm = [sphMesh(1).x sphMesh(1).y sphMesh(1).z];
%     Vm = Vm*sc;
%     % Cent shift
%     T = [mean(vertices(:,1)) mean(vertices(:,2)) mean(vertices(:,3))];
%     Vm = Vm + T;
%     trimesh(Fm,Vm(:,1), Vm(:,2), Vm(:,3), 'FaceAlpha', 0, 'EdgeAlpha', 0); axis equal;
    set(gcf,'Renderer','OpenGL');
    set(gcf,'color','k');
    camproj('perspective');
    material dull
end


% --------------------------------------------------------------------
function med_Callback(hObject, eventdata, handles)
% hObject    handle to med (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else
    % check if grayscale
    if size(im,3) == 3 % RGB
        f = msgbox('Input must be grayscale!');
        pause(1);
        close(f);
    else if islogical(im)
        f = msgbox('Input must be grayscale!');
        pause(1);
        close(f);   
        
        else
            
            % axes(hAxis.axesImage);
            im = medfilt2(im);
            
            setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
            L = get(gca,{'xlim','ylim'});  % Get axes limits.
            imshow(im);
            set(gca,{'xlim','ylim'},L);
            ax = gca;               % get the current axis
            ax.Clipping = 'off';    % turn clipping off
        end
    end
end


% --------------------------------------------------------------------
function nlm_Callback(hObject, eventdata, handles)
% hObject    handle to nlm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else
    % check if grayscale
    if size(im,3) == 3 % RGB
        f = msgbox('Input must be grayscale!');
        pause(1);
        close(f);
    else if islogical(im)
        f = msgbox('Input must be grayscale!');
        pause(1);
        close(f);   
        
        else
            
            % axes(hAxis.axesImage);
            prompt = {'Degree of smoothing:','Search window size:', 'Comparison window size:'};
            dlgtitle = 'NLM filter';
            dims = [1 45];
            definput = {'10','21', '5'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            DoS = round(str2num(answer{1}));
            SWS = round(str2num(answer{2}));
            CWS = round(str2num(answer{3}));
            if isempty(DoS) | isempty(SWS) | isempty(CWS)
                DoS = 10
                SWS = 21
                CWS = 5
            else if DoS < 1 | SWS < 1 | CWS < 1
                    DoS = 10
                    SWS = 21
                    CWS = 5
                else if round(SWS/2) ~= SWS/2 | round(CWS/2) ~= CWS/2
                        DoS = 10
                        SWS = 21
                        CWS = 5
                    else if SWS < CWS
                            DoS = 10
                            SWS = 21
                            CWS = 5
                        end
                    end
                end
            end

            im = imnlmfilt(im,'DegreeOfSmoothing',DoS, 'SearchWindowSize', SWS, 'ComparisonWindowSize', CWS);
            setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
            L = get(gca,{'xlim','ylim'});  % Get axes limits.
            imshow(im);
            set(gca,{'xlim','ylim'},L);
            ax = gca;               % get the current axis
            ax.Clipping = 'off';    % turn clipping off
        end
    end
end


% --------------------------------------------------------------------
function stackGray_Callback(hObject, eventdata, handles)
% hObject    handle to stackGray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else
    % check if grayscale
    if size(im,3) == 3 % RGB
        f = msgbox('Input must be grayscale!');
        pause(1);
        close(f);
    else if islogical(im)
        f = msgbox('Input must be grayscale!');
        pause(1);
        close(f);   
        
        else
            
            % axes(hAxis.axesImage);
            im = cat(3, im, im, im);

            setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
            L = get(gca,{'xlim','ylim'});  % Get axes limits.
            imshow(im);
            set(gca,{'xlim','ylim'},L);
            ax = gca;               % get the current axis
            ax.Clipping = 'off';    % turn clipping off
        end
    end
end


% --------------------------------------------------------------------
function resizeIm_Callback(hObject, eventdata, handles)
% hObject    handle to resizeIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else
    
    % axes(hAxis.axesImage);
    prompt = {'Scaling factor (between 0 and 1):'};
    dlgtitle = 'Rescale image';
    dims = [1 45];
    definput = {'0.5'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    sc = str2num(answer{1});
    
    if sc < 0 | sc > 1
        sc = 1;
    end
    
    if isempty(sc)
        sc = 1;
    end
    
    im = imresize(im, sc);
    setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    L{1} = [0.5 size(im,2)];
    L{2} = [0.5 size(im,1)];
    imshow(im);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off
end


% --------------------------------------------------------------------
function otsu_Callback(hObject, eventdata, handles)
% hObject    handle to otsu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
% hAxis = findall(0,'tag','axesImage');
if isnan(im)
    f = msgbox('No image selected');
    pause(1);
    close(f);
else if islogical(im)
        f = msgbox('Image is already segmented');
        pause(1);
        close(f);
    else if ndims(im) > 2
            f = msgbox('Image must be grayscale!');
            pause(1);
            close(f);
        else
            level = graythresh(im);
            im = imbinarize(im,level);
            setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
            L = get(gca,{'xlim','ylim'});  % Get axes limits.
            L{1} = [0.5 size(im,2)];
            L{2} = [0.5 size(im,1)];
            imshow(im);
            set(gca,{'xlim','ylim'},L);
            ax = gca;               % get the current axis
            ax.Clipping = 'off';    % turn clipping off
        end
    end
end
