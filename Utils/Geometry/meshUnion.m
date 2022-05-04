function g = meshUnion( gs )
%g = meshUnion( gs )
%   gs is a struct array of meshes specified by fields vxs, containing
%   the 3d positions of a set of vertexes, and polys, containing sets of
%   polygons or polyhedra.
%
%   The result is their disjoint union.
%
%   The 'polys' fields can be ragged arrays padded with zeros. Likewise the
%   'vxs' fields, which amounts to assuming that if 2d and 3d data are
%   mixed, the 2d vertexes have Z coordinate zero.

    if isempty(gs)
        g = struct( 'vxs', zeros(0,3), 'polys', [] );
        return;
    end
    
    gs = gs(:);
    g.vxs = cellToRaggedArray( reshape( { gs.vxs }, [], 1 ) );
    
    numMeshes = length(gs);
    
    nvs = zeros( numMeshes, 1 );
    for i=1:numMeshes
        nvs(i) = size( gs(i).vxs, 1 );
    end
    
    offsets = [ 0; cumsum( nvs(1:(end-1)) ) ];
    
    g.polys = cell( numMeshes, 1 );
    for i=1:length(gs)
        p = gs(i).polys;
        p(p~=0) = p(p~=0) + offsets(i);
        g.polys{i} = p;
    end
    
    g.polys = int32( cellToRaggedArray( g.polys, 0 ) );
end
