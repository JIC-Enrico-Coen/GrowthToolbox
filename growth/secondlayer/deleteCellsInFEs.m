function secondlayer = deleteCellsInFEs( secondlayer, goodFEmap, t )
%secondlayer = deleteCellsInFEs( secondlayer, badFEmap )
%   This deletes every second layer cell, any vertexes of which lie in any
%   of the finite elements listed in badFEs.  This is called by deleteFEs,
%   which deletes finite elements.

    if isNonemptySecondLayer( secondlayer )
        goodVxsmap = goodFEmap(secondlayer.vxFEMcell);
        numcells = length( secondlayer.cells );
        testCell = false( 1, numcells );
        for ci=1:numcells
            testCell(ci) = all( goodVxsmap( secondlayer.cells(ci).vxs ) );
        end
        secondlayer = deleteSecondLayerCells( secondlayer, find(~testCell), t );
    end
end

