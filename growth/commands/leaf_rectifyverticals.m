function m = leaf_rectifyverticals( m )
%m = leaf_rectifyverticals( m )
%   Force the lines joining vertexes on opposite surfaces of the mesh to be
%   perpendicular to the mid-surface.

    m = rectifyVerticals( m );
end
