function emap = edgeMapFromNodeMap( m, vmap )
%emap = edgeMapFromNodeMap( m, vmap )
%   Find all the edges of the mesh m, both of whose ends are in the set
%   vmap.  vmap must be a vector of booleans of the same length as the
%   number of vertexes of m.  emap will be a similar boolean map of the
%   edges.
%
%   See also: edgeListFromNodeList

    emap = vmap( m.edgeends( :, 1 ) ) & vmap( m.edgeends( :, 2 ) );
end
