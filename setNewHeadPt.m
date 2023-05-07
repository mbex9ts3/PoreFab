function new_poly = setNewHeadPt( poly, head_index )
% rearrange polygon to new head point / different start vertex
% note: number of vertices in poly is n, but the size of poly is (n+1)*2
% example: 
%     poly=[1 2; 3 4; 5 6; 7 8; 9 10; 1 2];
%     new_poly = setNewHeadPt( poly, 2 );
% Revision history:
%   mjx0799@gmail.com, May 2019

    num_vertex = size( poly, 1 ) - 1;
    len = num_vertex - head_index + 1;
    
    new_poly = zeros( size(poly) );
    new_poly( 1: len, : ) = poly( head_index: end-1, : );
    new_poly( len+1: end-1, : ) = poly( 1: head_index-1, : );
    new_poly( end, : ) = new_poly( 1, : );
    
end