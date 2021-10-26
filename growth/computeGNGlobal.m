function m = computeGNGlobal( m )
%mesh = computeGNGlobal( mesh )
%   Compute the gradients of the shape functions in the global frame, at
%   every gauss point in every cell.

    numCells = size(m.tricellvxs,1);
    for ci=1:numCells
        trivxs = m.tricellvxs(ci,:);
        prismvxs = [ trivxs*2-1, trivxs*2 ];
        cellvxCoords = m.prismnodes( prismvxs, : )';
        m.celldata(ci).gnGlobal = ...
            computeCellGNGlobal( cellvxCoords, m.globalProps.gaussInfo );
    end
end
