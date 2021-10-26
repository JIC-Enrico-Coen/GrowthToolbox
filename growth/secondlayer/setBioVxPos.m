function m = setBioVxPos( m, vis, vxpos, hint )
%m = setBioVxPos( m, vis, vxpos )
    if isempty(vis)
        return;
    end
    if nargin < 4
        hint = [];
    end
    m.secondlayer.cell3dcoords(vis,:) = vxpos;
    
    nv = length(vis);
    fes = zeros( nv, 1 );
    bcs = zeros( nv, 3 );
    for i=1:length(vis)
        [ fes(i), bcs(i,:), bcerr, abserr ] = findFE( m, vxpos(i,:), 'hint', hint );
    end
    m.secondlayer.vxFEMcell( vis ) = fes;
    m.secondlayer.vxBaryCoords( vis, : ) = bcs;
end
