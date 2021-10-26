function es = edgeListFromNodeList( m, vs )
%es = edgeListFromNodeList( m, vs )
%   Find all the edges of the mesh m, both of whose ends are in the set
%   vs.  vs must be a vector of vertex indexes of m.  es will be a list of
%   edge indexes.
%
%   See also: edgeMapFromNodeMap

    vmap = false( size(m.nodes,1), 1 );
    vmap(vs) = true;
    es = find( vmap( m.edgeends( :, 1 ) ) & vmap( m.edgeends( :, 2 ) ) );
end
