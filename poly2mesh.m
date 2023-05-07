function [vert,tria,tnum] = poly2mesh( node_cell, edge_cell, hmax, mesh_kind, grad_limit )
% poly2mesh: generate meshes of parts defined by polygons, 
%        	 adapted from the demo of mesh2d-master
%            (Darren Engwirda, https://github.com/dengwirda/mesh2d) 
% 
% input:
%     hmax - for poly2mesh, affact maximum mesh-size
% 
%     mesh_kind - meshing algorithm
%                 value: 'delaunay' or 'delfront' 
%                 "standard" Delaunay-refinement or "Frontal-Delaunay" technique
%     
%     grad_limit - scalar gradient-limit for mesh
%
% output:
%   vert(k,1:2) = [x_coordinate, y_coordinate] of k-th node 
%   tria(m,1:3) = [node_numbering_of_3_nodes] of m-th element
%   tnum(m,1) = n; means the m-th element is belong to phase n
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020

% assemble triangulations for multi-part geometry definitions.
%---------------------------------------------- create geom.
    libpath();
    
    % node_cell and edge_cell have the same size
    num_phase = length( node_cell );
    
    % initialize edge and node
    % pre-allocated memory
    total_size = 0;
    for i = 1: num_phase
        total_size = total_size + size( node_cell{i}, 1 );
    end
    edge = zeros( total_size, 3 );
    node = zeros( total_size, 2 );
    
    accumu_size = 0;
    for i = 1: num_phase
        edge_cell{i}(:,3) = i;  % edge_cell{i}(:,3) as marker, show phase
        if i > 1
            edge_cell{i}(:,1:2) = edge_cell{i}(:,1:2) + accumu_size;
        end
        
        idx = (accumu_size + 1) : (accumu_size + size(node_cell{i}, 1));
        edge( idx, : ) = edge_cell{i};
        node( idx, : ) = node_cell{i};
        
        accumu_size = accumu_size + size( node_cell{i}, 1 );
    end

    % above code equal to:
    %     edg1(:,3) = 1;
    %     edg2(:,3) = 2;
    %     edg3(:,3) = 3;
    %     edg2(:,1:2) = edg2(:,1:2) + size(nod1,1);
    %     edg3(:,1:2) = edg3(:,1:2) + size(nod1,1) + size(nod2,1);
    %     edge = [edg1; edg2; edg3];
    %     node = [nod1; nod2; nod3];
	
    %-- the PART argument is a cell array that defines individu-
    %-- al polygonal "parts" of the overall geometry. Each elem-
    %-- ent PART{I} is a list of edge indexes, indicating which
    %-- edges make up the boundary of each region.

    part = cell( 1, num_phase );
    for i = 1: num_phase
        part{i} = find( edge(:,3) == i );
    end
        
    edge = edge( :, 1:2 );
    
%---------------------------------------------- do size-fun.
 
    % meshing algorithm
    % "standard" Delaunay-refinement or "Frontal-Delaunay" technique
    olfs.kind = mesh_kind;      % 'delaunay' or 'delfront' 
                                % default value is 'delaunay'
    
    olfs.dhdx = grad_limit;     % dhdx is scalar gradient-limit
                                % default +0.2500
    
    % LFSHFN2 routine is used to create 
    % mesh-size functions based on an estimate of the "local-feature-size" 
    % associated with a polygonal domain. 
   [vlfs,tlfs, ...
    hlfs] = lfshfn2( node, edge, part, olfs ) ;

    hlfs = min(hmax,hlfs) ;

   [slfs] = idxtri2(vlfs,tlfs) ;
   
%---------------------------------------------- do mesh-gen.
    hfun = @trihfn2;
    
   [vert,etri, ...
    tria,tnum] = refine2(node,edge,part,[],hfun , ...
                    vlfs,tlfs,slfs,hlfs);
                         
%---------------------------------------------- do mesh-opt.
    % SMOOTH2 routine provides iterative mesh "smoothing" capabilities, 
    % seeking to improve triangulation quality by adjusting the vertex positions 
    % and mesh topology.
   [vert,~, ...
    tria,tnum] = smooth2(vert,etri,tria,tnum) ;
    
%---------------------------------------------- plot mesh
%     figure;
%     hold on; axis image off;
% 
%     tvalue = unique( tnum );
%     len = length( tvalue );
%     col = 0.5: 0.45/(len-1): 0.95;
%     for i = 1: len
%         partcode = tvalue(i);
%         patch('faces',tria( tnum==partcode, 1:3 ),'vertices',vert, ...
%         'facecolor',[ col(i), col(i), col(i) ], ...
%         'edgecolor',[.15,.15,.15]);
%     end
%     
%     patch('faces',edge(:,1:2),'vertices',node, ...
%         'facecolor','none', ...
%         'edgecolor',[.1,.1,.1], ...
%         'linewidth',1.5);
%     
%     title(['MESH-OPT.: KIND=DELFRONT, |TRIA|=', ...
%         num2str(size(tria,1))]) ;
%          
%     drawnow;
%         
%     set(figure(1),'units','normalized', ...
%         'position',[.05,.50,.30,.35]) ;
    
end