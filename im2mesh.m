function [ vert, tria, tnum ] = im2mesh( im, select_phase, tf_avoid_sharp_corner, tolerance, hmax, mesh_kind, grad_limit )
% im2mesh: convert grayscale segmented image to triangular mesh
%
% input
%     im        % grayscale segmented image
% 
%     tf_avoid_sharp_corner   % For function getCtrlPnts
%                             % Whether to avoid sharp corner when 
%                             % simplifying polygon.
%                             % Value: true or false
%                             % If true, two extra control points
%                             % will be added around one original 
%                             % control point to avoid sharp corner 
%                             % when simplifying polygon.
%                             % Sharp corner in some cases will make 
%                             % poly2mesh not able to converge.
%                         
%     tolerance   % For funtion simplifyBounds
%                 % Tolerance for polygon simplification.
%                 % Check Douglas-Peucker algorithm.
%                 % If u don't need to simplify, try tolerance = eps.
%                 % If the value of tolerance is too large, some 
%                 % polygons will become line segment after 
%                 % simplification, and these polygons will be 
%                 % deleted by function delZeroAreaPoly.
%     
%     hmax        % For funtion poly2mesh
%                 % Maximum mesh-size
%     
%     mesh_kind   % For funtion poly2mesh
%                 % Meshing algorithm
%                 % Value: 'delaunay' or 'delfront' 
%                 % "standard" Delaunay-refinement or "Frontal-Delaunay" technique
% 
%     grad_limit  % For funtion poly2mesh
%                 % Scalar gradient-limit for mesh
%                  
%   select_phase  % A new parameter for function im2mesh.m
%                 % Parameter type: vector
%                 % If 'select_phase' is [], all the phases will be
%                 % chosen.
%                 % 'select_phase' is an index vector for sorted 
%                 % grayscales (ascending order) in an image.
%                 % For example, an image with grayscales of 40, 90,
%                 % 200, 240, 255. If u're interested in 40, 200, and
%                 % 240, then set 'select_phase' as [1 3 4]. Those 
%                 % phases corresponding to grayscales of 40, 200, 
%                 % and 240 will be chosen to perform meshing.   
%   
% output:
%   vert(k,1:2) = [x_coordinate, y_coordinate] of k-th node 
%   tria(m,1:3) = [node_numbering_of_3_nodes] of m-th element
%   tnum(m,1) = n; means the m-th element is belong to phase n
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020
% 
   
    bounds1 = im2Bounds( im );
    bounds2 = getCtrlPnts( bounds1, tf_avoid_sharp_corner );
    % plotBounds( bounds2 );
    
    bounds3 = simplifyBounds( bounds2, tolerance );
    bounds3 = delZeroAreaPoly( bounds3 );
    % plotBounds( bounds3 );

    % clear up redundant vertices
    % only control points and knick-points will remain
    bounds4 = getCtrlPnts( bounds3, false );
    bounds4 = simplifyBounds( bounds4, eps );
    
    % select phase
    if isempty(select_phase)
        % = do nothing = all phases will be chosen
    elseif ~isvector(select_phase)
        error("select_phase is not a vector")
    elseif length(select_phase) > length(bounds4)
        error("length of select_phase is larger than the number of phases")
    else
        bounds4 = bounds4( select_phase );
    end
    
    [ node_cell, edge_cell ] = genNodeEdge( bounds4 );
    [ vert, tria, tnum ] = poly2mesh( node_cell, edge_cell, hmax, mesh_kind, grad_limit );
    % plotMeshes( vert, tria, tnum );
end

