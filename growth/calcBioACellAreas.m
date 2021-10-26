function m = calcBioACellAreas( m )
    if ~hasNonemptySecondLayer( m )
        return;
    end
    numcells = length(m.secondlayer.cells);
    m.secondlayer.cellarea = zeros(numcells,1);
    for ci=1:numcells
        m.secondlayer.cellarea(ci) = polyarea3( ...
            m.secondlayer.cell3dcoords( m.secondlayer.cells(ci).vxs, : ) );
    end
    if isfield( m.secondlayer.valuedict.name2IndexMap, 'cellarea' )
        m.secondlayer.cellvalues(:,m.secondlayer.valuedict.name2IndexMap.cellarea) = m.secondlayer.cellarea;
    end
end
