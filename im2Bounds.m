function bounds = im2Bounds( im )
% convert grayscale segmented image into exact polygonal boundaries using
% getExactBounds.m
%
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020

    im = flip(im,1);	% in fem software using right-hand coordinate, 
                        % to coincide with that, must flip in row direction
                        % so the origin of coordinates is at bottom-left
                        
    intensity = unique( im );    % vector
    num_phase = size( intensity, 1 );
    bounds = cell( num_phase, 1 );
    
    for i = 1: num_phase
        bw = im == intensity(i);
        % Obtain the exact polygonal boundaries of objects and holes in 
        % binary image. Both objects and holes are 4-connected.
        bounds{i} = getExactBounds( bw );
    end
    % size of bounds {i}{j} = (1+number_of_vertices)-by-2
    
    % post-process
    bounds = bounds2CCW( bounds );       % counterclockwise ordering
    bounds = head2BottomLeft( bounds );
end

function bounds = bounds2CCW( bounds )
% Convert polygon contour to counterclockwise vertex ordering
% 
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            [ bounds{i}{j}(:,1), bounds{i}{j}(:,2) ] = poly2ccw( ...
                                    bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
        end
    end
end

function bounds = head2BottomLeft( bounds )
% rearrange each polygon in cell bounds
% make the bottom left vertex become head vertex

    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            poly = bounds{i}{j};
            % find the bottom left vertex in poly
            miny = min( poly(:,2) );
            Iy = find( poly(:,2) == miny);
            [ ~, Ix ] = min( poly(Iy,1) );
            
            if Iy( Ix ) ~= 1    % not equal to current head vertex
                head_index = Iy(Ix); 
                bounds{i}{j} = setNewHeadPt( poly, head_index );
            end
        end
    end
    
end
