function [vn,tn] = vertexNormals( vxs, tricellvxs, recalcvxs )
%vn = vertexNormals( nodes, tricellvxs )
%   Given a triangle mesh defined by its vertex positions and the triples of
%   nodes that form the triangles, calculate a vertex normal for each vertex.
%   The procedure also returns tn, the normal vectors for each triangle.
%
%   If recalcvxs is supplied, it is either a list of vertex indexes or a
%   boolean map of the indexes, and specified which vertexes are to have
%   their normals calculated.

    if nargin < 3
        recalcvxs = true( size(vxs,1), 1 );
        recalctrinormals = true( size(vxs,1), 1 );
    elseif isnumeric( recalcvxs )
    end

    [~,tn] = triangleareas( vxs, tricellvxs );
    vn = zeros(size(vxs));
    vni = zeros(size(vxs,1),1);
    for i=1:size(tricellvxs,1)
        vn(tricellvxs(i,:),:) = vn(tricellvxs(i,:),:) + repmat(tn(i,:), 3, 1);
        vni(tricellvxs(i,:)) = vni(tricellvxs(i,:)) + 1;
    end
    vn = vn ./ repmat( vni, 1, 3 );
end
