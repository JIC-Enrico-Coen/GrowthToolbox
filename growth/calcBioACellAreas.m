function biolayer = calcBioACellAreas( biolayer )
    if ~isNonemptySecondLayer( biolayer )
        return;
    end
    numcells = length(biolayer.cells);
    biolayer.cellarea = zeros(numcells,1);
    for ci=1:numcells
        biolayer.cellarea(ci) = polyarea3( ...
            biolayer.cell3dcoords( biolayer.cells(ci).vxs, : ) );
    end
    if isfield( biolayer.valuedict.name2IndexMap, 'cellarea' )
        biolayer.cellvalues(:,biolayer.valuedict.name2IndexMap.cellarea) = biolayer.cellarea;
    end
end
