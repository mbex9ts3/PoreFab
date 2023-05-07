function [ node_cell, edge_cell ] = genNodeEdge( bounds )
% generate boundary node cell array and edge cell array of bounds
%
% input
%   bounds{i} is boundary polygons for one phase
%
% output
%   node_cell{i} and edge_cell{i} corresponds to polygons in bounds{i}
%   node_cell{i} - x,y coordinates of vertices
%   edge_cell{i} - node numbering of two connecting vertices
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020

    node_cell = cell( 1, length(bounds) );
    edge_cell = cell( 1, length(bounds) );
    
    for i = 1: length(bounds)
        % node_mulpoly and edge_mulpoly store multiple polygons in one phase
        node_mulpoly = [];
        edge_mulpoly = [];
        
        for j = 1:length(bounds{i})
            if isequal( bounds{i}{j}(1,:), bounds{i}{j}(end,:) )
                % node_temp and edge_temp store one polygon
                node_temp = bounds{i}{j}( 1:end-1, : );
                edge_temp = zeros( length(node_temp), 2 );
                
                for k = 1:length(node_temp)
                    edge_temp(k,:) = [ k, k+1 ];
                end
                edge_temp( end, 2 ) = 1;

                [ node_mulpoly, edge_mulpoly ] = joinNodeEdge( ...
                        node_mulpoly,edge_mulpoly, node_temp,edge_temp );
            else
                error('polygon not close')
            end
        end
        node_cell{i} = node_mulpoly;
        edge_cell{i} = edge_mulpoly;
    end
end