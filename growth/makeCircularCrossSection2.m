function m = makeCircularCrossSection2( m, th0, h, th, n )
%m = makeCircularCrossSection( m, rel_thick_upper, angle_upper, rel_thick_lower, angle_lower )
%   Force the mesh m to have a circular or elliptic cross-section in the XZ
%   plane, assuming the mesh is initially more or less flat in the XY
%   plane.

    % Find all of the edge vertexes.
    boundaryedgeends = m.edgeends(m.edgecells(:,2)==0,:);
    edgevxs = unique(boundaryedgeends(:));
    % Find all of the base vertexes.
    ymin = min(m.nodes(:,2));
    ymax = max(m.nodes(:,2));
    basevxs = m.nodes(:,2) <= ymin + (ymax-ymin)*0.0001;
    % Find the corner vertexes.
    xs = abs( m.nodes( edgevxs, 1 ) );
    ys = m.nodes( edgevxs, 2 );
    bvxs2 = edgevxs*2;
    zs = (m.prismnodes( bvxs2, 3 ) - m.prismnodes( bvxs2 - 1, 3 ))/2;
    boundaryshape = unique( [ ys, xs, zs ], 'rows' );
    dups = boundaryshape(1:end-1,1) >= boundaryshape(2:end,1);
    boundaryshape(dups,:) = [];
    maxradii = abs(boundaryshape(:,2));
    radii = interp1( boundaryshape(:,1), maxradii, m.nodes(:,2) );
    
    [newxs,newzs,newxshi,newzshi,newxslo,newzslo] = bulgeProfile( h, th, th0, n, radii, m.nodes(:,1) );
    m.prismnodes(:,1) = reshape( [ newxslo, newxshi ]', [], 1 );
    m.prismnodes(:,3) = reshape( [ newzslo, newzshi ]', [], 1 );
    m.nodes(:,[1 3]) = (m.prismnodes(1:2:end,[1 3]) + m.prismnodes(2:2:end,[1 3]))/2;
end

