function lengthsqs = edgelengthsqs(m)
%lengthsqs = edgelengthsqs(mesh)    Find squared lengths of all edges.
    if usesNewFEs(m)
        edgevecs = ...
            m.FEnodes( m.FEconnectivity.edgeends(:,2), : ) - ...
                m.FEnodes( m.FEconnectivity.edgeends(:,1), : );
    else
        edgevecs = ...
            m.nodes( m.edgeends(:,2), : ) - ...
                m.nodes( m.edgeends(:,1), : );
    end
    lengthsqs = dotproc2( edgevecs, edgevecs );
  % lengthsqs = sum( edgevecs.*edgevecs, 2 );  % Slower than the above.
end
