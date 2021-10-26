function nn = meshVertexNormals( m, vxs )
%n = vertexNormals( m, vxs )
%   Calculate a normal vector at every vertex in vxs, being an average of
%   the face normals of the faces that meet at that vertex.
%
%   vxs can be a boolean map or a list of indexes. If omitted it defaults
%   to the set of all vertexes.
%
%   For foliate meshes only, at present.

    if nargin < 2
        vxs = 1:getNumberOfVertexes( m );
    elseif islogical(vxs)
        vxs = find(vxs);
    end
    nn = zeros( length(vxs), 3 );
    for i=1:length(vxs)
        nce = m.nodecelledges{i};
        faces = nce(2,:);
        normals = trinormals( m.nodes, m.tricellvxs( faces(faces > 0), : ) );
        n = sum(normals,1)/size(normals,1);
        n = n/norm(n);
        if any(isnan(n))
            n = [0 0 0];
        end
        nn(i,:) = n;
    end
end
