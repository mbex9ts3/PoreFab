function new_bounds = simplifyBounds( bounds, tolerance )
% simplify each bounds{i}{j} using dpsimplify.m
%
% input - bounds{i}{j} is a coordinate array of a polygon with (NaN,NaN)
% output - new_bounds{i}{j} without (NaN,NaN)
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, July 2019

    % dpsimplify() is sensitive to the orientation of each polyline in 
    % bounds{i}{j}, so reorient first
    bounds = reorient( bounds );
    
    new_bounds = bounds;
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            new_bounds{i}{j} = dpsimplify( bounds{i}{j}, tolerance );
        end
    end
    
    new_bounds = mergeBounds( new_bounds );     % delete (NaN,NaN)
end

function bounds = reorient( bounds )
% bounds{i}{j} is a polygonal boundary consists of multi polylines.
% reorient() will make the starting point of each polyline in bounds{i}{j} 
% to left-bottom. If bounds{i}{j} only have one polyline, then make it to 
% counter clockwise.

    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            % polygon to cell that consists of polylines
            [x1, y1] = polysplit( bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
            if numel(x1) > 1
                for k = 1:numel(x1)
                    if x1{k}(1) < x1{k}(end) || ...
                            ( x1{k}(1) == x1{k}(end) && y1{k}(1) <= y1{k}(end) )
                        % starting point of polyline already at left-bottom
                        % so do nothing
                    elseif ( x1{k}(1) == x1{k}(end) && y1{k}(1) > y1{k}(end) ) ||...
                            x1{k}(1) > x1{k}(end)
                        % starting point not at left-bottom
                        % reverse
                        x1{k} = x1{k}(end:-1:1);
                        y1{k} = y1{k}(end:-1:1);
                    else
                        error('other cases')
                    end
                end
            else    % numel(x1) == 1
                if ispolycw(x1{1}, y1{1})
                    x1{1} = x1{1}( end:-1:1 );  % to counter clockwise
                    y1{1} = y1{1}( end:-1:1 );
                end
            end
            
            [ bounds{i}{j}(:,1), bounds{i}{j}(:,2) ] = polyjoin(x1, y1);
            
        end
    end
end

function bounds = mergeBounds( bounds )
% delete (NaN,NaN) in bounds{i}{j} using polymerge

    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            poly = [];
            [ poly(:,1), poly(:,2) ] = polymerge( ...
                                    bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
            if isnan( poly(end,1) )
                poly = poly( 1:end-1, : );  % delete last NaN
            else
                error('not ending with NaN');
            end
            bounds{i}{j} = poly;
        end
    end
end
