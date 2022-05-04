function celledgelengths = celledgelengths(m,ceis)
%celledgelengths = celledgelengths(mesh)
%   Find length of all cell edges.

    if hasNonemptySecondLayer( m )
        if nargin < 2
            ceis = true(getNumberOfCellEdges(m),1);
        end
        celledgevecs = m.secondlayer.cell3dcoords( m.secondlayer.edges(ceis,1), : ) - m.secondlayer.cell3dcoords( m.secondlayer.edges(ceis,2), : );
        celledgelengths = sqrt( sum( celledgevecs.^2, 2 ) );
    else
        celledgelengths = zeros(0,1);
    end
end
