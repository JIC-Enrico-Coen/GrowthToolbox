function num = getNumberOfFaces( m )
%num = getNumberOfVertexes( m )
%   For volumetric meshes, return the number of faces.
%   For foliate meshes, return 0.

    if isempty(m)
        num = 0;
    elseif usesNewFEs(m)
        num = size( m.FEconnectivity.faces, 1 );
    else
        num = 0;
    end
end
