function [ s_node, s_edge ] = joinNodeEdge(node1,edge1,node2,edge2)
%joinNodeEdge: join two sets of polygons

    s_node = [ node1; node2];
    s_edge = [ edge1; edge2 + size(node1,1) ];
    
end
