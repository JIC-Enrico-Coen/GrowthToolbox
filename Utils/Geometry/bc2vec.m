function v = bc2vec( bc, vxs )
%v = bc2vec( bc, vxs )
%   Convert a vector described in barycentric coordinates with respect to
%   the triangle whose vertexes are the rows of the 3*3 matrix vxs, to a
%   vector in global coordinates.

    v = bc*vxs; % - repmat( vxs(1,:), size(bc,1), 1 );
end
