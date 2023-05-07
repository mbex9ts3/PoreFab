function varargout = phiEstimator2(varargin)
% PHIESTIMATOR2 MATLAB code for phiEstimator2.fig
%      PHIESTIMATOR2, by itself, creates a new PHIESTIMATOR2 or raises the existing
%      singleton*.
%
%      H = PHIESTIMATOR2 returns the handle to a new PHIESTIMATOR2 or the handle to
%      the existing singleton*.
%
%      PHIESTIMATOR2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHIESTIMATOR2.M with the given input arguments.
%
%      PHIESTIMATOR2('Property','Value',...) creates a new PHIESTIMATOR2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before phiEstimator2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to phiEstimator2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% edit the above text to modify the response to help phiEstimator2

% Last Modified by GUIDE v2.5 22-Jan-2022 11:18:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phiEstimator2_OpeningFcn, ...
                   'gui_OutputFcn',  @phiEstimator2_OutputFcn, ...
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


% --- Executes just before phiEstimator2 is made visible.
function phiEstimator2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to phiEstimator2 (see VARARGIN)

% Choose default command line output for phiEstimator2
handles.output = hObject;

% icons
polyG = imread('polygon.png');
set(handles.drawPoly,'CData', polyG);
panIm = imread('panIm.png');
set(handles.pan,'CData', panIm);
undo = imread('undo.png');
set(handles.undo,'CData', undo);
zoom = imread('zoom.png');
set(handles.zoom,'CData', zoom);
polyL = imread('polyline.png');
set(handles.polyline,'CData', polyL);
saveEd = imread('saveNew.png');
set(handles.save,'CData', saveEd);

% default draw parameters
setappdata(findobj('Tag', 'editPane2'),'drawFlag',false); 
setappdata(findobj('Tag', 'editPane2'),'color', 'r'); 
setappdata(findobj('Tag', 'editPane2'),'lineW', '1'); 

% Update handles structure
guidata(hObject, handles);
im = getappdata(findobj('Tag', 'sliceView'), 'imCurrent');
imRGB = im;
imshow(imRGB);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off
imBlank = true(size(im,1), size(im, 2));

setappdata(findobj('Tag', 'editPane2'),'im',im);
setappdata(findobj('Tag', 'editPane2'),'imBlank',imBlank); 
setappdata(findobj('Tag', 'editPane2'),'imRGB',imRGB);

setappdata(findobj('Tag', 'editPane2'),'imUndo',nan); 
setappdata(findobj('Tag', 'editPane2'),'imRGBUndo',nan);
setappdata(findobj('Tag', 'editPane2'),'imBlankUndo',nan); 

setappdata(findobj('Tag', 'editPane2'),'imRedo',nan); 
setappdata(findobj('Tag', 'editPane2'),'imRGBRedo',nan); 
setappdata(findobj('Tag', 'editPane2'),'imBlankRedo',nan);

% bespoke icon
javaFrame = get(hObject,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon('icon.png'));

% % UIWAIT makes phiEstimator2 wait for user response (see UIRESUME)
% % uiwait(handles.editPane2);


% --- Outputs from this function are returned to the command line.
function varargout = phiEstimator2_OutputFcn(hObject, eventdata, handles) 
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

im = getappdata(findobj('Tag', 'editPane2'),'im');
imRGB = getappdata(findobj('Tag', 'editPane2'),'imRGB');
imBlank = getappdata(findobj('Tag', 'editPane2'),'imBlank');
drawFlag = getappdata(findobj('Tag', 'editPane2'),'drawFlag');
cols = getappdata(findobj('Tag', 'editPane2'),'color');

% display current image: maintain zoom
L = get(gca,{'xlim','ylim'});  % Get axes limits.
imshow(imRGB);
set(gca,{'xlim','ylim'},L);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off

% save current view
setappdata(findobj('Tag', 'editPane2'),'imUndo',im); 
setappdata(findobj('Tag', 'editPane2'),'imRGBUndo',imRGB);
setappdata(findobj('Tag', 'editPane2'),'imBlankUndo',imBlank); 

% draw edits
hpoly = impoly(gca);
polyPoints = hpoly.getPosition;

BW = createMask(hpoly);

% assign edits to RGB for display
imR = imRGB(:,:,1);
imG = imRGB(:,:,2);
imB = imRGB(:,:,3);

% color vectors
if cols == 'r'
    colV = [255 0 0];
else if cols == 'g'
        colV = [0 255 0];
    else if cols == 'b'
            colV = [0 0 255];
        else if cols == 'c'
                colV = [0 255 255];
            else if cols == 'm'
                    colV = [255 0 255];
                else if cols == 'y'
                        colV = [255 255 0];
                    else if cols == 'w'
                            colV = [255 255 255];
                        else if cols == 'k'
                                colV = [0 0 0];
                            end
                        end
                    end
                end
            end
        end
    end
end
 

if drawFlag == false
    % display false edits
    imR(BW == true) = colV(1);
    imG(BW == true) = colV(2);
    imB(BW == true) = colV(3);
    imBlank(BW == true) = false;
else
    % display positive as white
    imR(BW == true) = colV(1);
    imG(BW == true) = colV(2);
    imB(BW == true) = colV(3);
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
setappdata(findobj('Tag', 'editPane2'),'im',im);
setappdata(findobj('Tag', 'editPane2'),'imBlank',imBlank);
setappdata(findobj('Tag', 'editPane2'),'imRGB',imRGB);
% setappdata(findobj('Tag', 'editPane2'),'mask',mask);


% --- Executes on button press in zoom.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save current view
im = getappdata(findobj('Tag', 'editPane2'),'imUndo'); 
imBlank = getappdata(findobj('Tag', 'editPane2'),'imBlankUndo'); 
imRGB = getappdata(findobj('Tag', 'editPane2'),'imRGBUndo'); 
if isnan(im)
    f = msgbox('No previous image exists');
    pause(1);
    close(f);
else
    imUndo = getappdata(findobj('Tag', 'editPane2'),'im');
    imRGBUndo = getappdata(findobj('Tag', 'editPane2'),'imRGB');
    imBlankUndo = getappdata(findobj('Tag', 'editPane2'),'imBlank'); 
    L = get(gca,{'xlim','ylim'});  % Get axes limits.
    imshow(imRGB);
    set(gca,{'xlim','ylim'},L);
    ax = gca;               % get the current axis
    ax.Clipping = 'off';    % turn clipping off

    setappdata(findobj('Tag', 'editPane2'),'imUndo', imUndo);
    setappdata(findobj('Tag', 'editPane2'),'imRGBUndo', imRGBUndo);
    setappdata(findobj('Tag', 'editPane2'),'imBlankUndo', imBlankUndo);
    
    setappdata(findobj('Tag', 'editPane2'),'im', im);
    setappdata(findobj('Tag', 'editPane2'),'imRGB', imRGB);
    setappdata(findobj('Tag', 'editPane2'),'imBlank', imBlank);
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


% --- Executes on button press in polyline.
function polyline_Callback(hObject, eventdata, handles)
% hObject    handle to polyline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'editPane2'),'im');
imRGB = getappdata(findobj('Tag', 'editPane2'),'imRGB');
imBlank = getappdata(findobj('Tag', 'editPane2'),'imBlank');
drawFlag = getappdata(findobj('Tag', 'editPane2'),'drawFlag');
cols = getappdata(findobj('Tag', 'editPane2'),'color');
lineW = getappdata(findobj('Tag', 'editPane2'),'lineW'); 


% display current image: maintain zoom
L = get(gca,{'xlim','ylim'});  % Get axes limits.
imshow(imRGB);
set(gca,{'xlim','ylim'},L);
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off

% save current view
setappdata(findobj('Tag', 'editPane2'),'imUndo',im); 
setappdata(findobj('Tag', 'editPane2'),'imRGBUndo',imRGB);
setappdata(findobj('Tag', 'editPane2'),'imBlankUndo',imBlank); 

% draw edits
hpoly = impoly(gca);
polyPoints = hpoly.getPosition;

BW = false(size(im,1), size(im,2));
for i = 1:size(polyPoints,1)-1
    hLine = imline(gca,[polyPoints(i,1) polyPoints(i+1,1)],[polyPoints(i,2) polyPoints(i+1,2)]);
    BWT = createMask(hLine);
    BW = BW + BWT;
end    
BW = logical(BW);

% apply dilation to polyline based upon lineW
% 1 ~ 3 pixels / 2 ~5 pixels / 4 ~7 pixels / 5 ~9 pixels / 6 ~11 pixels
% 7 ~13 pixels / 8 ~15 pixels / 9 ~17 pixels / 10 ~19 pixels / 11 ~21 pixels
% 12 ~23 pixels / 13 ~25 pixels
if lineW == '3'
    pix = 1;
else if lineW == '5'
        pix = 2;
    else if lineW == '7'
            pix = 4;
        else if lineW == '9'
                pix = 5;
            else if lineW == '11'
                    pix = 6;
                else if lineW == '13'
                        pix = 7;
                    else if lineW == '15'
                            pix = 8;
                        else if lineW == '17'
                                pix = 9;
                            else if lineW == '19'
                                    pix = 10;
                                else if lineW == '21'
                                        pix = 11;
                                    else if lineW == '23'
                                            pix = 12;
                                        else if lineW == '25'
                                                pix = 13;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
            

if str2num(lineW) > 1
    SE = strel('disk',pix, 4);
    BW = imdilate(BW,SE);
%     for i = 1:str2num(lineW)
%         BW = imdilate(BW,SE);
%     end
end

% % mask end nodes and round ends
% if str2num(lineW) > 1
%     endN = polyPoints(end,:);
%     startN = polyPoints(1,:);
%     
%     angles = linspace(0, 2*pi, 360); % 360 is the total number of points
%     x = transpose((lineW/2) * cos(angles));
%     y = transpose((lineW/2) * sin(angles));
%     
%     % lower inlet lower pilot hole
%     endPoly = [x+endN(1) y+endN(2)];
%     BWE = poly2mask(endPoly(:,1),endPoly(:,2),size(im, 1),size(im, 2));
%     BW(BWE == true) = true;
% 
%     
%     % upper inlet lower pilot hole
%     startPoly = [x+startN(1) y+startN(2)];
%     BWS = poly2mask(startPoly(:,1),startPoly(:,2),size(im, 1),size(im, 2));
%     BW(BWS == true) = true;
% 
% end


% % cut off end nodes
% % build bounding box
% startNode = polyPoints(1:2,:);
% endNode = polyPoints(end-1:end,:);
% tStart = [mean(startNode(:,1)) mean(startNode(:,2))];
% tEnd = [mean(endNode(:,1)) mean(endNode(:,2))];
% startNode = startNode - tStart;
% endNode = endNode - tEnd;
% 
% % recale to unit length
% scStart = 1/sqrt((startNode(1,1)-startNode(2,1))^2 + (startNode(1,2)-startNode(2,2))^2);
% scEnd = 1/sqrt((endNode(1,1)-endNode(2,1))^2 + (endNode(1,2)-endNode(2,2))^2);
% startNode = startNode*scStart;
% endNode = endNode*scEnd;
% 
% theta = 90; % to rotate 90 counterclockwise
% R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% % Rotate point(s)
% startR = R*transpose(startNode);
% startR = startR';
% endR = R*transpose(endNode);
% endR = endR';
% 
% % rescale based upon lineW
% startNode = startNode*lineW;
% startR = startR*lineW;
% endNode = endNode*lineW;
% endR = endR*lineW;
% startR = startR + tStart
% endR = endR + tEnd
% 
% % burn binaries
% hLine1 = imline(gca,[startR(1,1) startR(2,1)],[startR(1,2) startR(2,2)]);
% hLine2 = imline(gca,[endR(1,1) endR(2,1)],[endR(1,2) endR(2,2)]);
% BWT1 = createMask(hLine1);
% BWT2 = createMask(hLine2);
% BWT = logical(BWT1+BWT2);
% BW = logical(BW - BWT);


% assign edits to RGB for display
imR = imRGB(:,:,1);
imG = imRGB(:,:,2);
imB = imRGB(:,:,3);

% color vectors
if cols == 'r'
    colV = [255 0 0];
else if cols == 'g'
        colV = [0 255 0];
    else if cols == 'b'
            colV = [0 0 255];
        else if cols == 'c'
                colV = [0 255 255];
            else if cols == 'm'
                    colV = [255 0 255];
                else if cols == 'y'
                        colV = [255 255 0];
                    else if cols == 'w'
                            colV = [255 255 255];
                        else if cols == 'k'
                                colV = [0 0 0];
                            end
                        end
                    end
                end
            end
        end
    end
end
 

if drawFlag == false
    % display false edits
    imR(BW == true) = colV(1);
    imG(BW == true) = colV(2);
    imB(BW == true) = colV(3);
    imBlank(BW == true) = false;
else
    % display positive as white
    imR(BW == true) = colV(1);
    imG(BW == true) = colV(2);
    imB(BW == true) = colV(3);
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
setappdata(findobj('Tag', 'editPane2'),'im',im);
setappdata(findobj('Tag', 'editPane2'),'imBlank',imBlank);
setappdata(findobj('Tag', 'editPane2'),'imRGB',imRGB);
% setappdata(findobj('Tag', 'editPane2'),'mask',mask);



% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getappdata(findobj('Tag', 'editPane2'),'imBlank');
setappdata(findobj('Tag', 'sliceView'), 'imCurrent', im);
setappdata(findobj('Tag', 'sliceView'), 'editFlag', true);
% uiresume(gcf);
delete(gcf);


% --------------------------------------------------------------------
function properties_Callback(hObject, eventdata, handles)
% hObject    handle to properties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function polyWeight_Callback(hObject, eventdata, handles)
% hObject    handle to polyWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function red_Callback(hObject, eventdata, handles)
% hObject    handle to red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'r'); 



% --------------------------------------------------------------------
function green_Callback(hObject, eventdata, handles)
% hObject    handle to green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'g'); 

% --------------------------------------------------------------------
function blue_Callback(hObject, eventdata, handles)
% hObject    handle to blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'b'); 

% --------------------------------------------------------------------
function cyan_Callback(hObject, eventdata, handles)
% hObject    handle to cyan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'c'); 

% --------------------------------------------------------------------
function magenta_Callback(hObject, eventdata, handles)
% hObject    handle to magenta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'm'); 

% --------------------------------------------------------------------
function yellow_Callback(hObject, eventdata, handles)
% hObject    handle to yellow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'y'); 

% --------------------------------------------------------------------
function black_Callback(hObject, eventdata, handles)
% hObject    handle to black (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'white'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'k'); 


% --------------------------------------------------------------------
function white_Callback(hObject, eventdata, handles)
% hObject    handle to white (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'red'), 'Checked','off');
set(findobj('Tag', 'green'), 'Checked','off');
set(findobj('Tag', 'blue'), 'Checked','off');
set(findobj('Tag', 'cyan'), 'Checked','off');
set(findobj('Tag', 'magenta'), 'Checked','off');
set(findobj('Tag', 'yellow'), 'Checked','off');
set(findobj('Tag', 'black'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'color', 'w'); 


% --------------------------------------------------------------------
function width_Callback(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function one_Callback(hObject, eventdata, handles)
% hObject    handle to one (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '1'); 


% --------------------------------------------------------------------
function three_Callback(hObject, eventdata, handles)
% hObject    handle to three (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '3'); 

% --------------------------------------------------------------------
function five_Callback(hObject, eventdata, handles)
% hObject    handle to five (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '5'); 

% --------------------------------------------------------------------
function seven_Callback(hObject, eventdata, handles)
% hObject    handle to seven (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '7'); 

% --------------------------------------------------------------------
function nine_Callback(hObject, eventdata, handles)
% hObject    handle to nine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '9'); 

% --------------------------------------------------------------------
function eleven_Callback(hObject, eventdata, handles)
% hObject    handle to eleven (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '11'); 


% --------------------------------------------------------------------
function thirteen_Callback(hObject, eventdata, handles)
% hObject    handle to thirteen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '13'); 

% --------------------------------------------------------------------
function fifteen_Callback(hObject, eventdata, handles)
% hObject    handle to fifteen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '15'); 


% --------------------------------------------------------------------
function seventeen_Callback(hObject, eventdata, handles)
% hObject    handle to seventeen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '17'); 

% --------------------------------------------------------------------
function nineteen_Callback(hObject, eventdata, handles)
% hObject    handle to nineteen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '19'); 

% --------------------------------------------------------------------
function twentyOne_Callback(hObject, eventdata, handles)
% hObject    handle to twentyOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '21'); 

% --------------------------------------------------------------------
function twentyThree_Callback(hObject, eventdata, handles)
% hObject    handle to twentyThree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyFive'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '23'); 

function twentyFive_Callback(hObject, eventdata, handles)
% hObject    handle to twentyThree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on');
set(findobj('Tag', 'one'), 'Checked','off');
set(findobj('Tag', 'three'), 'Checked','off');
set(findobj('Tag', 'five'), 'Checked','off');
set(findobj('Tag', 'seven'), 'Checked','off');
set(findobj('Tag', 'nine'), 'Checked','off');
set(findobj('Tag', 'eleven'), 'Checked','off');
set(findobj('Tag', 'thirteen'), 'Checked','off');
set(findobj('Tag', 'fifteen'), 'Checked','off');
set(findobj('Tag', 'seventeen'), 'Checked','off');
set(findobj('Tag', 'nineteen'), 'Checked','off');
set(findobj('Tag', 'twentyOne'), 'Checked','off');
set(findobj('Tag', 'twentyThree'), 'Checked','off');
setappdata(findobj('Tag', 'editPane2'),'lineW', '25'); 
