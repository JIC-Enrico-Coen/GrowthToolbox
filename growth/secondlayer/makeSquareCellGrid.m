function m = makeSquareCellGrid( m, spacing, allowoveredge, tolerance )
%m = makeSquareCellGrid( m, spacing )
%   Create a cellular layer in the form of a regular square grid.  The mesh
%   m is assumed to be flat or nearly so.

    if nargin<3
        allowoveredge = true;
    end
    if nargin<4
        tolerance = 0.1;
    end
    xmin = min(m.nodes(:,1));
    xmax = max(m.nodes(:,1));
    xdiam = xmax-xmin;
    ymin = min(m.nodes(:,2));
    ymax = max(m.nodes(:,2));
    ydiam = ymax-ymin;
    nxcells = ceil( xdiam/spacing );
    nycells = ceil( ydiam/spacing );
    spacing = max(xdiam/nxcells,ydiam/nycells);
    nxpts = nxcells+1;
    xmargin = (nxcells*spacing - xdiam)/2;
    nypts = nycells+1;
    ymargin = (nycells*spacing - ydiam)/2;
    npts = nxpts * nypts;
    vxpos = (0:nxcells)'*spacing + xmin - xmargin;
    vypos = (0:nycells)*spacing + ymin - ymargin;
    vpos = [ repmat( vxpos, nypts, 1 ), ...
             reshape( repmat( vypos, nxpts, 1 ), [], 1 ), ...
             zeros( npts, 1 ) ];
    ci = zeros( npts, 1 );
    bc = zeros( npts, 3 );
    bcerr = zeros( npts, 1 );
    abserr = zeros( npts, 1 );
    zcoords = m.nodes(:,3);
    m.nodes(:,3) = 0;  % To fit the vertexes to the flattened mesh.
    [ ci(1), bc(1,:), bcerr(1), abserr(1) ] = findFE( m, vpos(1,:) );
    for i=2:size(vpos,1)
        [ ci(i), bc(i,:), bcerr(i), abserr(i) ] = findFE( m, vpos(i,:), 'hint', ci(i-1) );
    end
    m.nodes(:,3) = zcoords;  % Restore original z coordinates.
    a = (1:nxcells)';
    b = 0:nxpts:(npts-nxpts*2);
    topleft = reshape( repmat(a,1,nycells) + repmat(b,nxcells,1), [], 1 );
    topright = topleft+1;
    bottomleft = topleft+nxpts;
    bottomright = bottomleft+1;
    cells = [ topleft, topright, bottomright, bottomleft ];
    okpts = abs(bcerr) < 1e-8; % (abserr <= tolerance*spacing) | ;
    if allowoveredge
        okcells = any( reshape( okpts(cells), size(cells) ), 2 );
    else
        okcells = all( reshape( okpts(cells), size(cells) ), 2 );
    end
    cells = cells( okcells, : );
    okpts = false(size(okpts));
    okpts(cells(:)) = true;
    
    newToOldPt = find( okpts );
    nokpts = length(newToOldPt);
    oldToNewPt = zeros(npts,1);
    oldToNewPt(okpts) = 1:nokpts;
    cells = reshape( oldToNewPt( cells ), size(cells) );
    nokcells = size(cells,1);
%     vpos = vpos( okpts, : );
    bc = bc( okpts, : );
    ci = ci( okpts );

    m.secondlayer = deleteSecondLayerCells( m.secondlayer );
    for i=1:nokcells
        m.secondlayer.cells(i).vxs = cells(i,:);
    end
    m.secondlayer.vxFEMcell = ci;
    m.secondlayer.vxBaryCoords = bc;
    m = calcCloneVxCoords( m );
%     m.secondlayer.cell3dcoords = vpos;
    m.secondlayer.side = true( length(m.secondlayer.cells), 1 );
end
