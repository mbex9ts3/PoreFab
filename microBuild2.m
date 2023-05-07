function [faces, vertices, sizeInnerF, sizeInnerV] = microBuild2(params, im)

% params = [60;5;3.8;30;5;8;2.50000000000000;4;3];

% grab inputs
flowLength = params(1);
offSet = params(2);
bore = params(3)/2;
inletLength = params(4);
wallDim = params(5);
headDepth = params(6);
coverDepth = params(7);
flowDepth = params(8);
baseDepth = params(9);

% ensure long axis is verticle 
if size(im,1) < size(im,2)
    im = imrotate(im, 90);
end

% compute scaling factor for flow domain
% nb offset, inlet length and drainage cut are to the nearest pixel
sc = size(im,1)/flowLength;
offSetSC = round(offSet*sc);
inletLengthSC =  round(inletLength*sc);
pixSC = (1/size(im,1))*flowLength;
inletTrue = (inletLengthSC*pixSC);

% build cell internal geometry
horzPad = true(size(im,1), offSetSC);
imT = horzcat(horzPad, im, horzPad);
vertPad = true(inletLengthSC, size(imT,2));
poly = [1 inletLengthSC; size(imT, 2) inletLengthSC; size(imT, 2)/2 1];
bw = poly2mask(poly(:,1),poly(:,2), inletLengthSC, size(imT,2)); 
vertPad(bw == true) = false;
vertPadL = imrotate(vertPad, 180);
imT = vertcat(vertPad, imT, vertPadL);
imT = imfill(imT,'holes'); % for edge holes

% binary to double
imT = double(imT);

% image meshing parameters
tf_avoid_sharp_corner = false;
tolerance = 1.;
hmax = 500;
mesh_kind = 'delaunay';
grad_limit = +0.25;
% mesh
select_phase_2 = 1;
[vert, tria, tnum] = im2mesh(imT, select_phase_2, tf_avoid_sharp_corner, tolerance, hmax, mesh_kind, grad_limit );

% recale and position mesh: position so that the bottom left corner of the model = [0,0]
vert = vert*pixSC;
minY = min(vert(:,2));
vert(:,2) = vert(:,2) - minY;
trueWidth = abs(diff([min(vert(:,1)) max(vert(:,1))]));
minX = min(vert(:,1));
vert(:,1) = vert(:,1) - minX;
vert(:,1) = vert(:,1) + wallDim;
trueLength = max(vert(:,2));
% show result
% plotMeshes(vert, tria, tnum);
% drawnow;
% axis equal

% find edges
holeCellArray = findTriMeshHoles(tria,vert);
vertices = [vert zeros(size(vert,1),1)];
faces = tria;
% figure; trimesh(faces,vertices(:,1),vertices(:,2),vertices(:,3));
% title('Identify Holes'); xlabel('x');ylabel('y'); hold on; axis equal;
% for i = 1:length(holeCellArray)
%     hole = holeCellArray{i};
%     line(vertices(hole,1),vertices(hole,2),vertices(hole,3),'Color','r')
% end

% guide holes
angles = linspace(0, 2*pi, 360); % 360 is the total number of points
x = transpose(bore * cos(angles));
y = transpose(bore * sin(angles));

% cut pilot holes and adjust face list
lowerCent = [(min(vert(:,1))+max(vert(:,1)))/2 (inletTrue-wallDim)/2];
upperCent = [(min(vert(:,1))+max(vert(:,1)))/2 trueLength-((inletTrue-wallDim)/2)];

% lower inlet lower pilot hole
lowHole = [x+lowerCent(1) y+lowerCent(2) zeros(360, 1)];

% upper inlet lower pilot hole
upHole = [x+upperCent(1) y+upperCent(2) zeros(360, 1)];

% remove vertices inside the ports
inCU = inpolygon(vert(:,1), vert(:,2),upHole(:,1),upHole(:,2));
inCL = inpolygon(vert(:,1), vert(:,2), lowHole(:,1),lowHole(:,2));
idx = transpose(1:size(vert,1));
inUout = idx(inCU);
inLout = idx(inCL);

% remove triangles intersecting the ports
logiU = false(size(faces,1),1);
logiL = false(size(faces,1),1);
for i = 1:size(faces,1)
    tri = vertcat(vert(faces(i,1),:), vert(faces(i,2),:), vert(faces(i,3),:));
    inU = inpolygon(upHole(:,1),upHole(:,2), tri(:,1), tri(:,2));
    inL = inpolygon(lowHole(:,1),lowHole(:,2), tri(:,1), tri(:,2));
    if sum(inU) > 0
        logiU(i) = true;
    end
    if sum(inL) > 0
        logiL(i) = true;
    end
end

% delete shared triangles
borderTU = unique(faces(logiU,:));
borderTL = unique(faces(logiL,:));

% delete faces
logiB = logical(logiL + logiU);
faces(logiB,:)=[];

% locate faces that share contained vertices and delete 
f1 = faces(:,1);
f2 = faces(:,2);
f3 = faces(:,3);
delList = vertcat(inUout, inLout);
L1 = ismember(f1, delList);
L2 = ismember(f2, delList);
L3 = ismember(f3, delList);
logi = false(size(L1,1),1);
logi(sum([L1 L2 L3], 2) > 0) = true;
faces(logi,:) = [];

% delete contained vertices
lU = ismember(borderTU, inUout);
lL = ismember(borderTL, inLout);
borderTU(lU) = [];
borderTL(lL) = [];

% remesh patches
patchU = vertcat(vert(borderTU,:), upHole(1:359,1:2), upperCent(:,1:2));
faceU = delaunayn([patchU(:,1) patchU(:,2)]); 
patchL = vertcat(vert(borderTL,:), lowHole(1:359,1:2), lowerCent(:,1:2));
faceL = delaunayn([patchL(:,1) patchL(:,2)]); 

% test patches for self intersection with the global mesh (occurs if
% patchU/patchL has non-convex hull

% locate all triangles linked to borderTU
% locate faces that share contained vertices and delete 
f1 = faces(:,1);
f2 = faces(:,2);
f3 = faces(:,3);
L1 = ismember(f1, borderTU);
L2 = ismember(f2, borderTU);
L3 = ismember(f3, borderTU);
logi = false(size(L1,1),1);
logi(sum([L1 L2 L3], 2) > 0) = true;
P1 = [vertices(faces(logi,1),1) vertices(faces(logi,1),2)];
P2 = [vertices(faces(logi,2),1) vertices(faces(logi,2),2)];
P3 = [vertices(faces(logi,3),1) vertices(faces(logi,3),2)];
intU = false(size(faceU,1),1);
for i = 1:size(intU,1)
    triU = [patchU(faceU(i,1), 1) patchU(faceU(i,1), 2);...
        patchU(faceU(i,2), 1) patchU(faceU(i,2), 2);...
        patchU(faceU(i,3), 1) patchU(faceU(i,3), 2);...
        patchU(faceU(i,1), 1) patchU(faceU(i,1), 2)];
    logiTemp = false(size(P1,1),1);
    for j = 1:size(P1,1)
        faceTemp = vertcat(P1(j,:), P2(j,:), P3(j,:), P1(j,:));
       [xi,yi] = polyxpoly(triU(:,1),triU(:,2),faceTemp(:,1),faceTemp(:,2)); % edge intersection
        logi = ismember([xi yi], triU, 'rows');
        xi(logi) = []; yi(logi) = [];
        % cut shared vertices
        logiM1 = ismember(faceTemp, triU, 'rows');
        logiM2 = ismember(triU, faceTemp, 'rows');
        in1 = inpolygon(triU(:,1),triU(:,2),faceTemp(:,1),faceTemp(:,2));
        in2 = inpolygon(faceTemp(:,1),faceTemp(:,2), triU(:,1),triU(:,2));
        in1(logiM2) = [];
        in2(logiM1) = [];
        if ~isempty([xi yi]) | sum(sum(in1)) + sum(sum(in2)) > 0
            logiTemp(j) = true;
        end
    end
    if sum(logiTemp) > 0
        intU(i) = true;
    end
end
faceU(intU, :) = [];

% test lower port
% locate faces that share contained vertices and delete 
f1 = faces(:,1);
f2 = faces(:,2);
f3 = faces(:,3);
L1 = ismember(f1, borderTL);
L2 = ismember(f2, borderTL);
L3 = ismember(f3, borderTL);
logi = false(size(L1,1),1);
logi(sum([L1 L2 L3], 2) > 0) = true;
P1 = [vertices(faces(logi,1),1) vertices(faces(logi,1),2)];
P2 = [vertices(faces(logi,2),1) vertices(faces(logi,2),2)];
P3 = [vertices(faces(logi,3),1) vertices(faces(logi,3),2)];
intL = false(size(faceL,1),1);
for i = 1:size(intL,1)
    triL = [patchL(faceL(i,1), 1) patchL(faceL(i,1), 2);...
        patchL(faceL(i,2), 1) patchL(faceL(i,2), 2);...
        patchL(faceL(i,3), 1) patchL(faceL(i,3), 2);...
        patchL(faceL(i,1), 1) patchL(faceL(i,1), 2)];
    logiTemp = false(size(P1,1),1);
    for j = 1:size(P1,1)
        faceTemp = vertcat(P1(j,:), P2(j,:), P3(j,:), P1(j,:));
       [xi,yi] = polyxpoly(triL(:,1),triL(:,2),faceTemp(:,1),faceTemp(:,2)); % edge intersection
        logi = ismember([xi yi], triL, 'rows');
        xi(logi) = []; yi(logi) = [];
        % cut shared vertices
        logiM1 = ismember(faceTemp, triL, 'rows');
        logiM2 = ismember(triL, faceTemp, 'rows');
        in1 = inpolygon(triL(:,1),triL(:,2),faceTemp(:,1),faceTemp(:,2));
        in2 = inpolygon(faceTemp(:,1),faceTemp(:,2), triL(:,1),triL(:,2));
        in1(logiM2) = [];
        in2(logiM1) = [];
        if ~isempty([xi yi]) | sum(sum(in1)) + sum(sum(in2)) > 0
            logiTemp(j) = true;
        end
    end
    if sum(logiTemp) > 0
        intL(i) = true;
    end
end
faceL(intL, :) = [];

% update faces indices
UtrueIDX = vertcat(borderTU, transpose(1:359)+size(vert,1), 360 + size(vert,1));
UlocalIDX = transpose(1:size(patchU,1));
LtrueIDX = vertcat(borderTL, transpose(1:359)+360+size(vert,1), 720 + size(vert,1));
LlocalIDX = transpose(1:size(patchL,1));

% new idx U
faceUnew = zeros(size(faceU,1)*3, 1);
faceUV = reshape(faceU, size(faceU,1)*3,1);
for i = 1:size(faceU,1)*3'
    faceUnew(i) = UtrueIDX(UlocalIDX == faceUV(i));
end
faceUnew = reshape(faceUnew, size(faceU,1), 3);
    
% new idx L
faceLnew = zeros(size(faceL,1)*3, 1);
faceLV = reshape(faceL, size(faceL,1)*3,1);
for i = 1:size(faceL,1)*3'
    faceLnew(i) = LtrueIDX(LlocalIDX == faceLV(i));
end
faceLnew = reshape(faceLnew, size(faceL,1), 3);

% build new vertex list and record sizeV
sizeV = size(vert,1);
vertices = vertcat(vertices, upHole(1:359, :), [upperCent 0], lowHole(1:359, :), [lowerCent 0]);
faces = vertcat(faces, faceUnew, faceLnew);


% 3D internal mesh setup
vertices2 = [vertices(:,1:2) repmat(-flowDepth, size(vertices,1),1)];
maxTop = max(max(faces));
faces2 = faces + maxTop;
faces = flip(faces,2); % edit
facesT = vertcat(faces, faces2);
verticesT = vertcat(vertices, vertices2);

holeCellArray2 = holeCellArray;
for i = 1:size(holeCellArray,1)
    holeCellArray2{i} = holeCellArray2{i}+maxTop;
end

% checks for clockwise vertex ordering 
polyR = cell(size(holeCellArray,1),1);
for i = 1:size(holeCellArray,1)
    polyR{i} = [vertices(holeCellArray{i}, 1) vertices(holeCellArray{i}, 2)];
end
RFlag = false(size(polyR,1),1);
for i = 1:size(holeCellArray,1)
    RFlag(i) = ispolycw(polyR{i}(:,1), polyR{i}(:,2));
end


% iterate through holeCellArray and tesselate walls: flip ordering if RFlag
% == false
edgeStore = cell(size(holeCellArray, 1),1);
for i = 1:size(holeCellArray,1)
    topFace = holeCellArray{i};
    baseFace = holeCellArray2{i};
    edgeF = [nan nan nan];
    for j = 1:size(topFace, 1)-1
        edgeF1 = [topFace(j) baseFace(j) baseFace(j+1)];
        edgeF2 = [baseFace(j+1) topFace(j+1) topFace(j)];    
        edgeF = vertcat(edgeF, edgeF1, edgeF2);
    end
    edgeF(1,:) = [];
    edgeFill = [baseFace(1) topFace(1) topFace(end); topFace(end)  baseFace(end) baseFace(1)];
    edgeStore{i} = vertcat(edgeF, edgeFill); 
    % test for clockwise rotation and flipdim if ACW
    if RFlag(i) == true && i > 1
        test = edgeStore{i};
        test = flipdim(test,2);
        edgeStore{i} = test;
    end
    
end
edgeStore = cell2mat(edgeStore);
facesT = vertcat(facesT, edgeStore);

% create manifold linking the inner and outer meshes
sizeInnerV = size(verticesT, 1);
sizeInnerF = size(facesT, 1);

% % find max / min vertices for inlet and cut shared faces
% minVY = min(vertices(:,2));
% maxVY = max(vertices(:,2));
% IDX = 1:size(verticesT,1);
% IDmin = IDX(verticesT(:,2) == minVY);
% IDmax = IDX(verticesT(:,2) == maxVY);
% IDQuery = [IDmin IDmax];
% cutFlag = false(size(facesT,1),1);
% Lia = ismember(facesT,IDQuery);
% sumF = sum(Lia, 2);
% cutFlag(sumF == 3) = true;
% facesT(cutFlag,:) = [];
% 
% % locate inlets
% holeCellArray = findTriMeshHoles(facesT,verticesT);
% % for i = 1:length(holeCellArray)
% %     hole = holeCellArray{i};
% %     hold on; line(verticesT(hole,1),verticesT(hole,2),verticesT(hole,3),'Color','b')
% % end
% [maxP, I] = max([max(verticesT(holeCellArray{1}, 2)) max(verticesT(holeCellArray{2}, 2))]); 
% if I == 1
%     topHole = holeCellArray{1};
%     bottomHole = holeCellArray{2};
% else
%     topHole = holeCellArray{2};
%     bottomHole = holeCellArray{1};
% end
% 
% % form
% topHole(end) = [];
% bottomHole(end) = [];

%% build outer form of the micromodel exterior
modExt = zeros(736,3);
% cell  is constructed with the following ordering (section view):

% modExt(1:4,:) - lower drainage wall vertices 
% 2----------3
% |          |
% |          |
% 1----------4
modExt(1:4,:) = [0 0-wallDim 0-(flowDepth+baseDepth);...
    0 0-wallDim coverDepth+headDepth;...
    (wallDim*2)+trueWidth 0-wallDim coverDepth+headDepth;...
    (wallDim*2)+trueWidth 0-wallDim 0-(flowDepth+baseDepth)];

% modExt(5:8,:) - upper drainage wall vertices
% 6----------7
% |          |
% |          |
% 5----------8
modExt(5:8,:) = [0 trueLength+wallDim 0-(flowDepth+baseDepth);...
    0 trueLength+wallDim coverDepth+headDepth;...
    (wallDim*2)+trueWidth trueLength+wallDim coverDepth+headDepth;...
    (wallDim*2)+trueWidth trueLength+wallDim 0-(flowDepth+baseDepth)];

% modExt(9:10,:) - lower inlet face 
% 9----------10
% |          |
% |          |
% 2----------3
modExt(9:10,:) = [0 inletTrue coverDepth+headDepth;...
    (wallDim*2)+trueWidth inletTrue coverDepth+headDepth];

% modExt(11:12,:) - upper inlet face 
% 6----------7
% |          |
% |          |
% 11---------12
modExt(11:12,:) = [0 trueLength-inletTrue coverDepth+headDepth;...
    (wallDim*2)+trueWidth trueLength-inletTrue coverDepth+headDepth];

% modExt(13:16,:) - coverslip
% 14---------15
% |          |
% |          |
% 13---------16
modExt(13:16,:) = [0 inletTrue coverDepth;...
    0 trueLength-inletTrue coverDepth;...
    (wallDim*2)+trueWidth trueLength-inletTrue coverDepth;...
    (wallDim*2)+trueWidth inletTrue coverDepth];

% modExt(17:376,:) - lower inlet upper pilot hole
modExt(17:375,:) = [x(1:359)+lowerCent(1) y(1:359)+lowerCent(2) repmat(coverDepth+headDepth, 359, 1)];
modExt(376,:) = [lowerCent(1) lowerCent(2) (coverDepth+headDepth)];

% modExt(377:736,:) - upper inlet upper pilot hole
modExt(377:735,:) = [x(1:359)+upperCent(1) y(1:359)+upperCent(2) repmat(coverDepth+headDepth, 359, 1)];
modExt(736,:) = [upperCent(1) upperCent(2) (coverDepth+headDepth)];
% 
% hold on; scatter3(modExt(:,1), modExt(:,2), modExt(:,3), 'f', 'r');    
% ax = gca;               % get the current axis
% ax.Clipping = 'off';    % turn clipping off


% mesh each facet
baseF = [1 5 8; 8 4 1]; % test
coverF = flip([13 14 15; 15 16 13], 2);
lowInF = [13 9 10; 10 16 13];
upInF = flip([14 11 12; 12 15 14], 2);
LsideF = flip([1 13 9; 9 2 1; 5 6 11; 11 14 5; 1 5 14; 14 13 1], 2);
RsideF = [4 16 10; 10 3 4; 8 7 12; 12 15 8; 4 8 15; 15 16 4];
lowWallF =[4 2 1; 4 3 2];
upWallF = flip([5 6 8; 6 7 8]);

% inlets: use lower inlet as the template  % replace with simple mesh face
% exMod(2,:) --> exMod(9,:) --> exMod(10,:) exMod(3,:) --> exMod(17:376,:)
trueInds = [2 9 10 3 17:376];
inlet = vertcat(modExt(2,:), modExt(9,:), modExt(10,:), modExt(3,:), modExt(17:376,:));
Fv = delaunay(inlet(:,1), inlet(:,2)); 
% hold on; trimesh(Fv, inlet(:,1), inlet(:,2), 'EdgeColor', 'k', 'FaceColor', 'r');
cutInd = size(inlet,1);
cutFlag = false(size(Fv,1),1);
Lia = ismember(Fv,cutInd);
sumF = sum(Lia, 2);
cutFlag(sumF > 0) = true;
Fv(cutFlag,:) = [];

% update inds
FvDup = Fv;
for i = 1:364
    Fv(FvDup == i) = trueInds(i);
end
FvL = Fv;

% inlets: use lower inlet as the template  % replace with simple mesh face
% exMod(2,:) --> exMod(9,:) --> exMod(10,:) exMod(3,:) --> exMod(17:376,:)
trueInds = [11 6 7 12 377:736];
inlet = vertcat(modExt(2,:), modExt(9,:), modExt(10,:), modExt(3,:), modExt(17:376,:));
Fv = delaunay(inlet(:,1), inlet(:,2)); 
% hold on; trimesh(Fv, inlet(:,1), inlet(:,2), 'EdgeColor', 'k', 'FaceColor', 'r');
cutInd = size(inlet,1);
cutFlag = false(size(Fv,1),1);
Lia = ismember(Fv,cutInd);
sumF = sum(Lia, 2);
cutFlag(sumF > 0) = true;
Fv(cutFlag,:) = [];

% update inds
FvDup = Fv;
for i = 1:364
    Fv(FvDup == i) = trueInds(i);
end
FvU = Fv;

% stack face list
faceExt = vertcat(baseF, coverF, lowInF, upInF, LsideF, RsideF, lowWallF, upWallF, FvL, FvU);
% hold on; trimesh(faceExt, modExt(:,1), modExt(:,2), modExt(:,3)); axis equal;

% stack vertices and mesh upper and lower holes
vertOut = vertcat(verticesT, modExt);
faceE = faceExt + size(verticesT,1);
faceOut = vertcat(facesT, faceE);

% mesh between upper and lower pilot
topFace = size(vertOut,1)-359:size(vertOut,1)-1;
baseFace = sizeV+1:sizeV+359;
edgeF = [nan nan nan];
for j = 1:358
    edgeF1 = [topFace(j) baseFace(j) baseFace(j+1)];
    edgeF2 = [baseFace(j+1) topFace(j+1) topFace(j)];
    edgeF = vertcat(edgeF, edgeF1, edgeF2);
end
edgeF(1,:) = [];
edgeFill = [baseFace(1) topFace(1) topFace(end); topFace(end)  baseFace(end) baseFace(1)];
edgeLHF = vertcat(edgeF, edgeFill);
edgeLHF = flip(edgeLHF,2);
hold on; trimesh(edgeLHF, vertOut(:,1), vertOut(:,2), vertOut(:,3), 'facecolor', 'r', 'edgecolor', 'k'); axis equal;
set(gca,'Clipping','off')


% upper
% upper
topFaceU = size(vertOut,1)-719:size(vertOut,1)-361;
baseFaceU = sizeV+361:sizeV+720;
edgeFU = [nan nan nan];
for j = 1:358
    edgeF1U = [topFaceU(j) baseFaceU(j) baseFaceU(j+1)];
    edgeF2U = [baseFaceU(j+1) topFaceU(j+1) topFaceU(j)];
    edgeFU = vertcat(edgeFU, edgeF1U, edgeF2U);
end
edgeFU(1,:) = [];
edgeFillU = [baseFaceU(1) topFaceU(1) topFaceU(end); topFaceU(end)  baseFaceU(end)-1 baseFaceU(1)];
edgeUHF = vertcat(edgeFU, edgeFillU);
edgeUHF = flip(edgeUHF,2);
% hold on; trimesh(edgeUHF, vertOut(:,1), vertOut(:,2), vertOut(:,3), 'facecolor', 'r', 'edgecolor', 'k'); axis equal;
% set(gca,'Clipping','off')

% output mesh
faces = vertcat(faceOut, edgeUHF, edgeLHF);
vertices = vertOut;

% delete faces around the lower inlet/outlet holes
f1 = faces(:,1);
f2 = faces(:,2);
f3 = faces(:,3);
L1 = ismember(f1, [sizeV+360 sizeV+720]);
L2 = ismember(f2, [sizeV+360 sizeV+720]);
L3 = ismember(f3, [sizeV+360 sizeV+720]);
logi = false(size(L1,1),1);
logi(sum([L1 L2 L3], 2) > 0) = true;
faces(logi,:) = []; 

% test and remove duplicate faces
faces = unique(faces, 'rows');

% % visualize inner mesh
% figure;
% trimesh(faces(1:sizeInnerF,:),vertices(:,1), vertices(:,2), vertices(:,3), 'EdgeColor', [0.5 0.1 0.1], 'FaceColor', 'r', 'FaceAlpha', 0.6, 'EdgeAlpha', 0.6); axis equal;
% lighting gouraud
% grid off
% axis off
% ax = gca;               % get the current axis
% ax.Clipping = 'off';    % turn clipping off
% set(gca,'CameraViewAngleMode','Manual')
% 
% hold on; % visualize outer mesh
% trimesh(faces(sizeInnerF+1:end,:), vertices(:,1), vertices(:,2), vertices(:,3), 'EdgeColor', [0.5 0.1 0.1], 'FaceColor', 'r', 'FaceAlpha', 0.10, 'EdgeAlpha', 0); axis equal;
% lighting gouraud
% grid off
% axis off
% ax = gca;               % get the current axis
% ax.Clipping = 'off';    % turn clipping off
% set(gca,'CameraViewAngleMode','Manual')
% 
% % render wireframe
% lines = vertices(sizeInnerV+1:end,:);
% hold on; line(vertcat(lines(1:4,1), lines(1,1)), vertcat(lines(1:4,2), lines(1,2)), vertcat(lines(1:4,3), lines(1,3)), 'color', 'r');
% hold on; line(vertcat(lines(5:8,1), lines(5,1)), vertcat(lines(5:8,2), lines(5,2)), vertcat(lines(5:8,3), lines(5,3)), 'color', 'r');
% hold on; line(vertcat(lines(9:10,1), lines(9,1)), vertcat(lines(9:10,2), lines(9,2)), vertcat(lines(9:10,3), lines(9,3)), 'color', 'r');
% hold on; line(vertcat(lines(11:12,1), lines(12,1)), vertcat(lines(11:12,2), lines(12,2)), vertcat(lines(11:12,3), lines(12,3)), 'color', 'r');
% hold on; line(vertcat(lines(13:16,1), lines(13,1)), vertcat(lines(13:16,2), lines(13,2)), vertcat(lines(13:16,3), lines(13,3)), 'color', 'r');
% hold on; line(vertcat(lines(13:16,1), lines(13,1)), vertcat(lines(13:16,2), lines(13,2)), vertcat(lines(13:16,3), lines(13,3)), 'color', 'r');
% hold on; line(vertcat(lines(17:376,1), lines(17,1)), vertcat(lines(17:376,2), lines(17,2)), vertcat(lines(17:376,3), lines(17,3)), 'color', 'r');
% hold on; line(vertcat(lines(377:736,1), lines(377,1)), vertcat(lines(377:736,2), lines(377,2)), vertcat(lines(377:736,3), lines(377,3)), 'color', 'r');
% hold on; line(vertcat(lines(737:1096,1), lines(737,1)), vertcat(lines(737:1096,2), lines(737,2)), vertcat(lines(737:1096,3), lines(737,3)), 'color', 'r');
% hold on; line(vertcat(lines(1097:1456,1), lines(1097,1)), vertcat(lines(1097:1456,2), lines(1097,2)), vertcat(lines(1097:1456,3), lines(1097,3)), 'color', 'r');
% hold on; line(lines([1 5 8 4 1],1), lines([1 5 8 4 1],2), lines([1 5 8 4 1],3), 'color', 'r');
% hold on; line(lines([2 9 13],1), lines([2 9 13],2), lines([2 9 13],3), 'color', 'r');
% hold on; line(lines([3 10 16],1), lines([3 10 16],2), lines([3 10 16],3), 'color', 'r');
% hold on; line(lines([6 11 14],1), lines([6 11 14],2), lines([6 11 14],3), 'color', 'r');
% hold on; line(lines([7 12 15],1), lines([7 12 15],2), lines([7 12 15],3), 'color', 'r');
% set(gcf,'Renderer','OpenGL');
% set(gcf,'color','k');
