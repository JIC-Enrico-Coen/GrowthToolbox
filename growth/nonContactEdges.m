function edges = nonContactEdges( m, edges )
%eis = nonContactEdges( m, eis )
%   EIS is a boolean map of the edges of m.
%   Find a maximal subset of EIS such that no finite element contains more
%   than one endpoint of any of the selected edges.

    if islogical(edges)
        edges = find(edges);
    end
    usedFEs = false( 1, getNumberOfFEs(m) );
    vxFEs = invertIndexArray( m.FEsets.fevxs, getNumberOfVertexes(m), 'cell' );
    for i=1:length(edges)
        vxs = m.FEconnectivity.edgeends(edges(i),:);
        fes = [ vxFEs{vxs(1)}; vxFEs{vxs(2)} ];
        if any(usedFEs(fes))
            edges(i) = 0;
        else
            usedFEs( fes ) = true;
        end
    end
    edges = edges(edges ~= 0);
end