function bounds2 = getCtrlPnts( bounds1, tf_avoid_sharp_corner )
% get control points in bounds{i}{j}
%
% Control point is the intersecting vertex between two polygons.
% It will serve as fixed point for polygon simplification and meshing.
%
% Steps:
%   1. label a control point in bounds1{i}{j} according to bounds1{k}{l}
%   2. change starting point of bounds1{i}{j} to control point
%   3. label control points in bounds1{i}{j}, again
%   4. insert (NaN,NaN) for polygon simplify
%
% % example of control points (only illustrate the output)
%     poly1=[1 2; 1 1; 0 1; 0 0; 1 0; 1 -1; 0 -1; -1 -1;
%                             -1 0; -1 1; -1 2; -1 3; 0 3; 1 3; 1 2];
%     poly2=[2 3; 1 3; 1 2; 1 1; 1 0; 1 -1; 2 -1;2 3];
%
%     % control points would be
%     cp=[1 0;1 -1;1 1; 1 2; 1 3];
%     % plot together
%     plot( poly1(:,1),poly1(:,2),poly2(:,1),poly2(:,2) )
%     hold on
%     plot(cp(:,1),cp1(:,2),'ro')
% 
%     % label of control points for poly1 would be
%     label_ctrlpnt_poly1 = [1  1  0  0  1  1  0  0  0  0  0  0  0  1  1]';
%     % label of control points for poly2 would be
%     label_ctrlpnt_poly2 = [0  1  0  0  0  1  0  0]';
% 
%     % insert (NaN,NaN) into poly1
%     new_poly1 = [ 1 2; 1 1; NaN NaN; 1 1; 0 1; 0 0; 1 0; NaN NaN; 1 0;
%                     1 -1; NaN NaN; 1 -1; 0 -1; -1 -1; -1 0; -1 1; -1 2;
%                     -1 3; 0 3; 1 3; NaN NaN; 1 3; 1 2 ];
%     % insert (NaN,NaN) into poly2
%     new_poly2 = [ 2 3; 1 3; NaN NaN; 1 3; 1 2; 1 1; 1 0;
%                     1 -1; NaN NaN; 1 -1; 2 -1; 2 3 ];
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020
%
    
    label_equal = findEqualPoly( bounds1 );
    % if exist equal ploygon, mark label_equal{i}(j) with true
    % we will not search control points for these polygons
    
    bounds2 = bounds1;
    
    for i = 1: length(bounds1)
        for j = 1: length(bounds1{i})
            if label_equal{i}(j), continue; end
            
            % label control point
            % once find a control point, break loop
            label_ctrlpnt = false( length(bounds1{i}{j}), 1 );
            k_last_time = 1;
            l_last_time = 1;
            % label vertex in bounds1{i}{j} according to bounds1{k}{l}
            for k = 1: length(bounds1)
                if k == i, continue; end    % skip bounds1{i} itself
                
                for l = 1: length(bounds1{k})
                    if label_equal{k}(l), continue; end
                    label_ctrlpnt = updateLabel( bounds1{i}{j}, ... 
                                            bounds1{k}{l}, label_ctrlpnt );
                    
                    % if find a control point, break loop                     
                    if any( label_ctrlpnt( 2: end-1 ) ), break; end
                end
                % if find a control point, break loop  
                if any( label_ctrlpnt( 2: end-1 ) )
                    k_last_time = k;
                    l_last_time = l;
                    break;
                end
            end
            
            % if none of the vertices of bounds1{i}{j} is on bounds1{k}{l}
            if all( ~label_ctrlpnt( 2: end-1 ) ), continue; end
            
            % change starting point of bounds1{i}{j} to control point
            head_index = find( label_ctrlpnt( 2: end-1 ), 1 ) + 1;
            bounds1{i}{j} = setNewHeadPt( bounds1{i}{j}, head_index );
            
            
            % label control points, again
            label_ctrlpnt = false( length(bounds1{i}{j}), 1 );
            % label vertex in bounds1{i}{j} according to bounds1{k}{l}
            % start from k_last_time and l_last_time
            for k = k_last_time: length(bounds1)
                if k == i, continue; end    % skip bounds1{i} itself
                
                if k == k_last_time
                    l_start = l_last_time;
                else
                    l_start = 1;
                end
                    
                for l = l_start: length(bounds1{k})
                    if label_equal{k}(l), continue; end
                    label_ctrlpnt = updateLabel( bounds1{i}{j},  ... 
                                            bounds1{k}{l}, label_ctrlpnt );
                end
            end
            
            if tf_avoid_sharp_corner
                label_ctrlpnt = addExtraPnts( label_ctrlpnt );
            end
            
            bounds2{i}{j} = insertNaN( bounds1{i}{j}, label_ctrlpnt );

        end
    end

end

function label_equal = findEqualPoly( bounds )
% compare polygon in bounds, find equal polygon
% bounds{i}{j} - n+1 * 2 array
% label_equal{i}(j) - true or false
%
    label_equal = cell( 1, length(bounds) );
    for i = 1: length(bounds)
        label_equal{i} = false( 1, length(bounds{i}) );
    end
    
    for i = 1: length(bounds)-1
        for j = 1: length(bounds{i})
            for k = i+1: length(bounds)
                for l = 1: length(bounds{k})
                    
                    if isequal( bounds{i}{j}, bounds{k}{l} )
                        label_equal{i}(j) = true;
                        label_equal{k}(l) = true;
                    end
                    
                end
            end
        end
    end

end

function label_ctrlpnt = updateLabel( poly1, poly2, label_ctrlpnt )
% Find control point in poly1, according to poly2, get updated label
%
% example
%     poly1=[1 2; 1 1; 0 1; 0 0; 1 0; 1 -1; 0 -1; -1 -1;
%                         -1 0; -1 1; -1 2; -1 3; 0 3; 1 3; 1 2];
%     poly2=[2 3; 1 3; 1 2; 1 1; 1 0; 1 -1; 2 -1;2 3];
%     plot( poly1(:,1),poly1(:,2),poly2(:,1),poly2(:,2) )
%     hold on
%     plot( poly1(1,1),poly1(1,2), 'ro' )
%     xlim([-1.5 3.5]);
%     ylim([-1.5 3.5]);
%     
%     numpnts = length( poly1 );      % number of points
%     label_ctrlpnt = false( numpnts, 1 );    % control point
%     label_ctrlpnt = updateLabel( poly1, poly2, label_ctrlpnt );
%

    % pre-check using bounding box of polygon
    if ~ isBBoxIntersect( poly1, poly2 )
        return
    end 

    % find vertices of poly1 that is the same as vertex of poly2
    tf_vector = isvertex( poly1, poly2 );
    % same as "tf_vector = ismember( poly1, poly2, 'rows' );", but faster

    if all(~tf_vector)	% none of the vertices of poly1 is on poly2
        return
    else                % some of the vertices of poly1 is on poly2
        
        for i = 1: length(tf_vector)
            if tf_vector(i)
                % first or last vertex-index of a common edge
                if i == 1 || i == length(tf_vector) ...
                        || ~tf_vector(i-1) || ~tf_vector(i+1)
                    label_ctrlpnt( i ) = true;
                end
            end
        end

    end
    
end

function tf = isBBoxIntersect( poly1, poly2 )
% whether the bounding box of two polygons intersect

    xmin_p1 = min(poly1(:,1));
    xmax_p1 = max(poly1(:,1));

    xmin_p2 = min(poly2(:,1));
    xmax_p2 = max(poly2(:,1));

    tf_x = isRangeIntersect( [xmin_p1 xmax_p1], [xmin_p2 xmax_p2] );

    ymin_p1 = min(poly1(:,2));
    ymax_p1 = max(poly1(:,2));

    ymin_p2 = min(poly2(:,2));
    ymax_p2 = max(poly2(:,2));

    tf_y = isRangeIntersect( [ymin_p1 ymax_p1], [ymin_p2 ymax_p2] );

    if tf_x && tf_y
        tf = true;
    else
        tf = false;
    end
end

function tf = isRangeIntersect(range1, range2)
% whether two intervals intersect

    lower = max(range1(1), range2(1));
    upper = min(range1(2), range2(2));
    
    if lower <= upper
        tf = true;
    else
        tf = false;
    end
end

function label_ctrlpnt = addExtraPnts( label_ctrlpnt )
% add two extra control points around one original control point
% to avoid sharp corner when simplifying polygon

    idx = find( label_ctrlpnt );
    
    for m = 1: length(idx)
        label_ctrlpnt(2) = true;
        label_ctrlpnt(end-1) = true;
        
        if idx(m) ~= 1
            label_ctrlpnt( idx(m)-1 ) = true;
        end
        
        if idx(m) ~= length(label_ctrlpnt)
            label_ctrlpnt( idx(m)+1 ) = true;
        end
    end
end


function new_poly = insertNaN( poly, label_ctrlpnt )
% insert (NaN,NaN) according to label_ctrlpnt
%
% example
%     poly1=[1 2; 1 1; 0 1; 0 0; 1 0; 1 -1; 0 -1; -1 -1;
%                         -1 0; -1 1; -1 2; -1 3; 0 3; 1 3; 1 2];
%                     
%     label_ctrlpnt = false( length(poly1), 1 );
%     label_ctrlpnt( [2 5 6] ) = true;
%     new_poly1 = insertNaN( poly1, label_ctrlpnt);
%
    
    label_ctrlpnt( 1 ) = false;
    label_ctrlpnt( end ) = false;
    
    num_vert = length(label_ctrlpnt);
    idx = find( label_ctrlpnt );
    new_poly = zeros( num_vert + 2*length(idx), 2 );
    
    count = 1;  % for new_poly
    for i = 1: num_vert
        if label_ctrlpnt(i)
            new_poly( count, : ) = poly( i, : );
            new_poly( count+1, : ) = [ NaN, NaN ];
            new_poly( count+2, : ) = poly( i, : );
            count = count + 3;
        else
            new_poly( count, : ) = poly( i, : );
            count = count + 1;
        end
    end

end

function [same,sloc] = isvertex(iset,jset)
%   a (much) faster variant of ISMEMBER for edge lists.
%   [IN] = SETSET2(ISET,JSET) returns an I-by-1 array IN,
%   with IN(K) = TRUE if ISET(K,:) is present in JSET. This
%   routine is essentially an optimised ISMEMBER variant de-
%   signed for processing lists of edge indexing. ISET is an
%   I-by-2 array of "query" edges, JSET is a J-by-2 array of
%   edges to test against.
%
%   See also ISMEMBER
%   Darren Engwirda : 2017 --
%   Email           : de2363@columbia.edu
%   Last updated    : 29/01/2017
%---------------------------------------------- basic checks
    if ( ~isnumeric(iset) || ~isnumeric(jset) )
        error('setset2:incorrectInputClass' , ...
            'Incorrect input class.') ;
    end
%---------------------------------------------- basic checks
    if (ndims(iset) ~= +2 || ndims(jset) ~= +2)
        error('setset2:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end
    if (size(iset,2)~= +2 || size(jset,2)~= +2)
        error('setset2:incorrectDimensions' , ...
            'Incorrect input dimensions.');
    end
% %---------------------------------------------- set v1 <= v2
% %     iset = sort(iset,2) ;
% %     jset = sort(jset,2) ;
% don't need to sort for my purpose. mjx0799@gmail.com.

%-- this is the slow, but easy-to-undertsand version of what
%-- is happening here...
  % if (nargout == +1)
  % same = ismember(iset,jset,'rows') ;
  % else
  % [same,sloc] = ...
  %        ismember(iset,jset,'rows') ;
%-- as above, the 'ROWS' based call to ISMEMBER can be sped
%-- up by casting the edge lists (i.e. pairs of UINT32 valu-
%-- es) to DOUBLE, and performing the sorted queries on vec-
%-- tor inputs!
    if (nargout == +1)
    same       = ismember( ...
        iset*[2^31;1], jset*[2^31;1]) ;
    else
   [same,sloc] = ismember( ...
        iset*[2^31;1], jset*[2^31;1]) ;
    end
end