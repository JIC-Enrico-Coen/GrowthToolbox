function m = setMeshVertexNormals( m )
%m = setMeshVertexNormals( m )
%   Set m.vertexNormals to hold the vertex normals. For foliate meshes
%   only. vi is either an array of vertex indexes or a boolean map of the
%   vertexes of m for which the normals are to be computed. By default, all
%   of them are computed.

    if ~isVolumetricMesh( m )
        [m.vertexnormals,m.unitcellnormals] = vertexNormals( m.nodes, m.tricellvxs );
    end
end
