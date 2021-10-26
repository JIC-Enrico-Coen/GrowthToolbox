function cells = findCellForPoint( m, pts )
%cells = findCellForPoint( m, pts )
%   Find the cell that a given point lies in.

    if isVolumetricMesh(m) || ~hasNonemptySecondLayer(m)
        cells = [];
        return;
    end
    
    flat = all(m.nodes(:,3)==0);
    if flat
        pts = pts(:,[1 2]);
        cellvxs = m.secondlayer.cell3dcoords(:,[1 2]);
    else
        cellvxs = m.secondlayer.cell3dcoords;
    end
    dims = size(pts,2);

    numcells = length(m.secondlayer.cells);
    cellaabb = zeros( numcells, 2*dims );
    for i=1:numcells
        vxis = m.secondlayer.cells(i).vxs;
        vxs = cellvxs(vxis,:);
        cellaabb(i,:) = [ min(vxs,[],1), max(vxs,[],1) ];
    end
    
    [containments,quality] = pointsInAabb( pts, cellaabb );
    
    [starts,ends] = runends( containments(:,1) );
    cells = zeros(size(pts,1),1);
    for i=1:length(starts)
        si = starts(i);
        ei = ends(i);
        if si==ei
            cells(i) = containments(si,2);
        else
            goodcontainments = false(ends(i)-starts(i)+1,1);
            for j=si:ei
                if flat
                    goodcontainments(j-si+1) = pointInPoly( ...
                        m.nodes(containments(j,1),[1 2]), ...
                        m.secondlayer.cell3dcoords(m.secondlayer.cells(containments(j,2)).vxs,[1 2]) );
                else
                    goodcontainments(j-si+1) = pointInPoly3D( ...
                        m.nodes(containments(j,1),:), ...
                        m.secondlayer.cell3dcoords(m.secondlayer.cells(containments(j,2)).vxs,:) );
                end
            end
            k = find(goodcontainments,1);
            if isempty(k)
                [~,k] = min(quality( si:ei ));
            end
            cells(i) = containments(k+si-1,2);
        end
    end
end

