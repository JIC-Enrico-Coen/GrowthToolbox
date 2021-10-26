function v = getSurfaceVertexes( m )
%n = getSurfaceVertexes( m )
%   For a volumetric mesh, find all of the vertexes on its surface.
%   For a laminar mesh, find all the vertexes on its edge.
%   The result is a boolean map of the vertexes which can be used, for
%   example, to index into a morphogen, e.g.:
%
%       v = getSurfaceVertexes( m );
%       id_source(v) = 1;  % Assuming there is a morphogen 'ID_SOURCE'.

    if isVolumetricMesh( m )
        v = m.FEconnectivity.vertexloctype > 0;
    else
        v = false( getNumberOfVertexes(m), 1 );
        borderedges = m.edgecells(:,2)==0;
        v(m.edgeends(borderedges,:)) = true;
    end
end
