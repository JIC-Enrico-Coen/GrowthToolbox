function m = splitT4Edge3D( m, ei, vi, oldfes, newfes )
%m = splitEdge3D( m, ei )
%   Split a single edge of a linear tetrahedral volumetric mesh.
    ee = m.FEconnectivity.edgeends( ei, : );

    % Make a new vertex at the midpoint of the edge.
    pt = sum(m.FEnodes(ee,:),1)/2;
    m.FEnodes( vi, : ) = pt;
    
    fevxs = m.FEsets(1).fevxs(oldfes,:);
    newfevxs = fevxs;
    
    % Wherever ee(1) occurs in fevxs, replace it by vi;
    % Wherever ee(2) occurs in newfevxs, replace it by vi;
    fevxs( fevxs==ee(1) ) = vi;
    newfevxs( fevxs==ee(2) ) = vi;
    m.FEsets(1).fevxs( oldfes, : ) = fevxs;
    m.FEsets(1).fevxs( newfes, : ) = newfevxs;
end

