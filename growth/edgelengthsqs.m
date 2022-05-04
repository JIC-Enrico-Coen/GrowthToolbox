function lengthsqs = edgelengthsqs(m,eis)
%lengthsqs = edgelengthsqs(m,eis)
%   Find squared lengths of edges. EIS defaults to all the edges. If given,
%   it can be a boolean map or a list of indexes.

    if nargin < 2
        eis = true(getNumberOfEdges(m),1);
    end
    if usesNewFEs(m)
        edgevecs = ...
            m.FEnodes( m.FEconnectivity.edgeends(eis,2), : ) - ...
                m.FEnodes( m.FEconnectivity.edgeends(eis,1), : );
    else
        edgevecs = ...
            m.nodes( m.edgeends(eis,2), : ) - ...
                m.nodes( m.edgeends(eis,1), : );
    end
    lengthsqs = dotproc2( edgevecs, edgevecs );
  % lengthsqs = sum( edgevecs.*edgevecs, 2 );  % Slower than the above.
end
