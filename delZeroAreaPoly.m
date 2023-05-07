function bounds = delZeroAreaPoly( bounds )
% delete polygon with zero area
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020

    mark_empty_bounds = false( length(bounds), 1 );
    
    for i = 1: length(bounds)
        mark_zero_poly = false( length(bounds{i}), 1 );
        % check bounds{i}{j}
        for j = 1: length(bounds{i})
            if polyarea( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) == 0
                mark_zero_poly(j) = true;
            end
        end      
        bounds{i}( mark_zero_poly ) = [];   % delete bounds{i}{j}
        
        % check bounds{i}
        if isempty(bounds{i})
            mark_empty_bounds(i) = true;
        end
    end
    
    bounds( mark_empty_bounds ) = [];       % delete bounds{i}
end