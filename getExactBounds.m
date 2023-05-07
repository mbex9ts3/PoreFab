function Bs = getExactBounds( bw )
% getExactBounds: get the exact boundaries (polygonal) of binary image
% sub-function: outerboundary.m and holeboundary.m
% 
% input bw - binary image
% ouput Bs - stores column (x) and row (y) coordinates of exact polygonal 
%           boundaries. Bs is a p-by-1 cell array, where p is the number of
%           (4 connected) objects and (4 connected) holes. Each cell in the
%           cell array contains a q-by-2 matrix. Each row in the matrix 
%           contains the column and row coordinates of a boundary corner. q
%           is the number of boundary corner for the corresponding region.
%           Size of Bs{i} is (1+number_of_vertices)-by-2.
%
% Comment:
% There're huge different between function bwboundaries and getExactBounds.
% The output of bwboundaries and getExactBounds may have different length.
%
% 1. bwboundaries(BW,conn,options)
% Return row (y) and column (x) coordinates of boundary pixel locations.
% Only inner boundaries are obatined.
% Parameter conn is very important for function bwboundaries. According to 
% bwboundaries.m in Matlab, 
% if conn = 4, objects are 4 connected and holes are 8 connected; 
% if conn = 8, objects are 8 connected and holes are 4 connected.
% This is to avoid topological errors.
%
% 2. getExactBounds( bw )
% Return column (x) and row (y) coordinates of the corner of boundary
% pixels.
% However, function getExactBounds don't have connectivity parameter. Both 
% objects and holes are 4 connected, since outputs are exact boundary. 
%
% Example:
%     bw = imread('bw.tif');
%     Bs = getExactBounds( bw );
% 
%     hold on
%     imshow(bw,'InitialMagnification','fit');
%     for k = 1:length(Bs)
%        plot( Bs{k}(:,1), Bs{k}(:,2), 's-g','MarkerSize',5,'LineWidth',2 );
%     end
%     hold off
% 
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, May 2020
% www.mathworks.com/matlabcentral/fileexchange/72436-getexactbounds-get-exact-boundary
%

    % initialize
    Bs = cell(0);
    % label objects using 4-connected neighborhood
    [ Label, num_object ] = bwlabel( bw, 4 );
    objs = regionprops( Label, 'Image', 'BoundingBox' );

    % get boundary of each 4-connected object, and update Bs
    for i = 1: num_object
        % one object at a time
        % B_temp is a cell & inner boundary
        B_temp = bwboundaries( (objs(i).Image)', 8 );

        % convert back to global coordinate
        for j = 1: length(B_temp)
            B_temp{j}(:,1) = B_temp{j}(:,1) + objs(i).BoundingBox(1) -0.5;  
            B_temp{j}(:,2) = B_temp{j}(:,2) + objs(i).BoundingBox(2) -0.5;
        end

        % convert B_temp (inner boundary) to B (exact boundary)
        if length(B_temp) == 1       % no holes
            B = outerboundary( B_temp(1) );
        elseif length(B_temp) > 1    % exist holes
            B = [ outerboundary( B_temp(1) ); 
                holeboundary( B_temp(2:end) ) ];
        else
            error("boundary error")
        end

        % update Bs
        Bs = [ Bs; B ];
    end

end

function cellout = outerboundary( cellin )
% outerboundary: get exact boundary of the outer contour of objects
% sub-function of getExactBounds.m
% input - cellin is a cell (N*1), cellin{j} is clockwise polygonal boundary
%
% an example:
%     bw = [0 0 0 0 0;
%           0 0 1 1 0;
%           0 1 1 1 0;
%           0 0 0 1 0;
%           0 0 0 0 0];
%     bw = logical( bw );
%     B_in = bwboundaries( bw', 8, 'noholes' );
%     B_ex = outerboundary( B_in );
% 
%     hold on
%     imshow(bw,'InitialMagnification','fit');
%     for i = 1: length(B_ex)
%         plot( B_in{i}(:,1), B_in{i}(:,2), 'O-k','MarkerSize',5,'LineWidth',2 );
%         plot( B_ex{i}(:,1), B_ex{i}(:,2), 'v-g','MarkerSize',5,'LineWidth',2 );
%     end
%     hold off
%     legend( 'result of bwboundaries(bw'',8,''noholes'' )' ,...
%             'outerboundary( bwboundaries() )');
%
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, May 2020

cellout = cell( length(cellin), 1 );

for j = 1: length(cellin)
    if size( cellin{j}, 1 ) < 2
        error('size error')
    elseif size( cellin{j}, 1 ) == 2
        % one pixel
        % four corner
        [cx,cy] = meshgrid( cellin{j}(1,1)+[-.5 .5], cellin{j}(1,2)+[-.5 .5] );
        pnt_list = zeros( 5, 2 );
        pnt_list( 1:4, : ) = [ cx(:), cy(:) ];
        pnt_list( 3:4, : ) = flip( pnt_list(3:4,:), 1 );
        pnt_list( 5, : ) = pnt_list( 1, : );
        new_pnt_list = pnt_list;
    else
        % two or more pixels
        % Step 1: obtain mid point of 2 neighbouring vertex. Treat mid 
        % points as new vertex. If not skew line, offset by 0.5.
        % Step 2: add special vertex since step 1 will miss some corners.
        % Step 3: for the skew line, offset by sqrt(2)/2.
        
        poly = [ cellin{j}; cellin{j}(2,:) ];   % to make pnt_list be close
        len_pnt_list = ( size( cellin{j}, 1 ) - 1 )*4;
        pnt_list = zeros( len_pnt_list, 2 );    % initailize
        count = 0;
        % pnt_list = [];
        
        % step 1 & step 2
        for k = 1: length(poly)-1
            % step 1
            if poly(k,1) == poly(k+1,1)
                % vertical line
                temp_y = 0.5*( poly(k,2) + poly(k+1,2) );
                if poly(k+1,2) > poly(k,2)
                    temp_x = poly(k,1) - 0.5;
                else
                    temp_x = poly(k,1) + 0.5;
                end
                temp = [ temp_x, temp_y ];

            elseif poly(k,2) == poly(k+1,2)
                % horizontal line
                temp_x = 0.5*( poly(k,1) + poly(k+1,1) );
                if poly(k+1,1) > poly(k,1)
                    temp_y = poly(k,2) + 0.5;
                else
                    temp_y = poly(k,2) - 0.5;
                end
                temp = [ temp_x, temp_y ];
            else
                % skew line
                temp = 0.5*( poly(k,:) + poly(k+1,:) );
            end 	% end of step 1

            % step 2
            if count > 0
                p1 = pnt_list(count,:);
                p2 = temp;
                if p1(1) == p2(1)
                    % vertical line
                    % pnt_list(end,:)  temp
                    % poly(k,:)
                    if p2(2) > p1(2)
                        if poly(k,1) < p1(1)
                            temp = [
                                poly(k,:) + [-0.5 -0.5];
                                poly(k,:) + [-0.5 +0.5];
                                temp
                                ];
                        else
                            % do nothing
                        end
                    else
                        if poly(k,1) > p1(1)
                            temp = [
                                poly(k,:) + [+0.5 +0.5];
                                poly(k,:) + [+0.5 -0.5];
                                temp
                                ];
                        else
                            % do nothing
                        end
                    end
                elseif p1(2) == p2(2)
                    % horizontal line
                    if p2(1) > p1(1)
                        if poly(k,2) > p1(2)
                            temp = [
                                poly(k,:) + [-0.5 +0.5];
                                poly(k,:) + [+0.5 +0.5];
                                temp
                                ];
                        else
                            % do nothing
                        end
                    else
                        if poly(k,2) < p1(2)
                            temp = [
                                poly(k,:) + [+0.5 -0.5];
                                poly(k,:) + [-0.5 -0.5];
                                temp
                                ];
                        else
                            % do nothing
                        end
                    end
                else
                    % do nothing
                end
            end     % end of step 2
            
            % put temp into pnt_list
            if ~isempty( temp )
                len_temp = size( temp, 1 );
                pnt_list( count+(1:len_temp), : ) = temp;
                count = count + len_temp;
            end
        end   	% end of step 1 & step 2
        
        % delete redudant zeros in pnt_list
        pnt_list( count+1:end, : ) = [];

        if ~isequal( pnt_list(1,:), pnt_list(end,:) )
            error('polygon not close')
        end

        % step 3
        new_pnt_list = pnt_list;
        count = 0;
        % pnt_list remain unchanged
        % update new_pnt_list
        for k = 1: size(pnt_list,1)-1
            p1 = pnt_list(k,:);
            p2 = pnt_list(k+1,:);

            if p1(1) ~= p2(1) && p1(2) ~= p2(2)
                if p2(1) < p1(1) && p2(2) > p1(2)
                    temp = [ p2(1) p1(2) ];
                elseif p2(1) > p1(1) && p2(2) > p1(2)
                    temp = [ p1(1) p2(2) ];
                elseif p2(1) > p1(1) && p2(2) < p1(2)
                    temp = [ p2(1) p1(2) ];
                elseif p2(1) < p1(1) && p2(2) < p1(2)
                    temp = [ p1(1) p2(2) ];
                end

                new_pnt_list = [
                                new_pnt_list( 1: k+count, : );
                                temp;
                                new_pnt_list( k+count+1: end, : )
                                ];
                count = count + 1;
            else
                % do nothing
            end
        end     % end of step 3
        
        if ~isequal( new_pnt_list(1,:), new_pnt_list(end,:) )
            error('polygon not close')
        end
    end
    
    cellout{j} = new_pnt_list;
end
     
end

function cellout = holeboundary( cellin )
% holeboundary: get exact boundary of the holes
% sub-function of getExactBounds.m
% input - cellin is a cell (N*1), cellin{j} is clockwise polygonal boundary
%
% an example:
%     bw = [0 1 0 0 0;
%           1 0 1 1 0;
%           1 0 0 1 0;
%           1 0 0 1 0;
%           1 1 1 0 0];
%     bw = logical( bw );
%     B_in = bwboundaries( bw', 8 );    
%     % B_in{1} is boundary of the object
%     % B_in{2} is boundary of hole inside the object
%     B_ex = holeboundary( B_in(2) );
%     % B_ex is the exact boundary of hole inside the object
% 
%     hold on
%     imshow(bw,'InitialMagnification','fit');
%     plot( B_in{2}(:,1), B_in{2}(:,2), 'O-r','MarkerSize',5,'LineWidth',2 );
%     plot( B_ex{1}(:,1), B_ex{1}(:,2), 'v-g','MarkerSize',5,'LineWidth',2 );
%     hold off
%     legend( 'result of bwboundaries( )' ,...
%             'holeboundary( bwboundaries() )');
%
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, May 2020 

cellout = cell( length(cellin), 1 );

for j = 1: length(cellin)
    if size( cellin{j}, 1 ) < 2
        error('size error')
    elseif size( cellin{j}, 1 ) == 2
        % one pixel
        % four corner
        [cx,cy] = meshgrid( cellin{j}(1,1)+[-.5 .5], cellin{j}(1,2)+[-.5 .5] );
        pnt_list = zeros( 5, 2 );
        pnt_list( 1:4, : ) = [ cx(:), cy(:) ];
        pnt_list( 3:4, : ) = flip( pnt_list(3:4,:), 1 );
        pnt_list( 5, : ) = pnt_list( 1, : );
    else
        % two or more pixels
        poly = [ cellin{j}; cellin{j}(2,:) ];   % to make pnt_list be close
        len_pnt_list = ( size( cellin{j}, 1 ) - 1 )*4;
        pnt_list = zeros( len_pnt_list, 2 );    % initailize
        count = 0;
        
        % get exact boundary from inner boundary
        for k = 1: length(poly)-2
            % vector
            vec_1 = [ poly(k+1,1)-poly(k,1), poly(k+1,2)-poly(k,2) ];
            vec_2 = [ poly(k+2,1)-poly(k+1,1), poly(k+2,2)-poly(k+1,2) ];
            xy = [ poly( k, : ); poly( k+1, : ); poly( k+2, : ) ];
            % generate points on the corner of a pixel
            temp = getCorner( vec_1, vec_2, xy );
            
            % delete repeated vertex
            % compare last of pnt_list and first of temp
            if count>0 && isequal( pnt_list(count,:), temp(1,:) )
                temp(1,:) = [];
            end
            % put temp into pnt_list
            if ~isempty( temp )
                len_temp = size( temp, 1 );
                pnt_list( count+(1:len_temp), : ) = temp;
                count = count + len_temp;
            end
        end
        % delete redudant zeros in pnt_list
        pnt_list( count+1:end, : ) = [];
    end
    
    if ~isequal( pnt_list(1,:), pnt_list(end,:) )
        error('polygon not close')
    end
    
    cellout{j} = pnt_list;
end

end

function temp = getCorner( vec_1, vec_2, xy )
% generate points on the corner of a pixel
%
%     % vector
%     vec_1 = [ poly(k+1,1)-poly(k,1), poly(k+1,2)-poly(k,2) ];
%     vec_2 = [ poly(k+2,1)-poly(k+1,1), poly(k+2,2)-poly(k+1,2) ];
%     xy = [ poly( k, : ); poly( k+1, : ); poly( k+2, : ) ];
%     temp = getCorner( vec_1, vec_2, xy );
%

    % rotate xy, make vec_1 to [1 0] direction
    angl = angle( vec_1(1) + vec_1(2)*1i );
    Rmat = @(theta) [cos(theta) sin(theta);-sin(theta) cos(theta)];
    rot = round( Rmat( -angl ) );
    xyr = xy * rot;     % size = (n,2) * (2,2) = (n,2)

    % generate points on the corner of a pixel
    if isequal( vec_1, vec_2 )                       % case 1
        tempr = [ ( xyr(1,1) + xyr(2,1) )/2, xyr(1,2) + 0.5;
                  ( xyr(2,1) + xyr(3,1) )/2, xyr(1,2) + 0.5 ];

    elseif isequal( vec_1, -vec_2 )                  % case 2
        tempr = [ ( xyr(1,1) + xyr(2,1) )/2, xyr(1,2) + 0.5;
                  ( xyr(1,1) + xyr(2,1) )/2 + 1, xyr(1,2) + 0.5;
                  ( xyr(1,1) + xyr(2,1) )/2 + 1, xyr(1,2) - 0.5;
                  ( xyr(1,1) + xyr(2,1) )/2, xyr(1,2) - 0.5 ];

    elseif dot( vec_1, vec_2 ) == 0 && ...            % case 3
            vec_1(1)*vec_2(2) - vec_1(2)*vec_2(1) > 0 % cross product
        tempr = [ ( xyr(1,1) + xyr(2,1) )/2, xyr(1,2) + 0.5 ];

    elseif dot( vec_1, vec_2 ) == 0 && ...            % case4
            vec_1(1)*vec_2(2) - vec_1(2)*vec_2(1) < 0
        tempr = [ ( xyr(1,1) + xyr(2,1) )/2, xyr(1,2) + 0.5;
                  ( xyr(1,1) + xyr(2,1) )/2 + 1, xyr(1,2) + 0.5;
                  ( xyr(1,1) + xyr(2,1) )/2 + 1, xyr(1,2) - 0.5 ];
    else
        error('unexpected cases');
    end
    
    % rotate backward
    temp = tempr * rot';
end