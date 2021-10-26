function m = makeCircularCrossSection( m, rel_thickness_upper, rel_thickness_lower )
%m = makeCircularCrossSection( m, rel_thickness_upper, rel_thickness_lower )
%   Force the mesh m to have a circular or elliptic cross-section in the XZ
%   plane, assuming the mesh is initially more or less flat in the XY
%   plane.
%
%   If the semi-diameter of the mesh in the X direction at some point Y is
%   r, then the height of the upper surface of the mesh in the Z direction
%   at X=0 will be r*rel_thickness_upper, and the depth of the lower
%   surface in the -Z direction will be r*rel_thickness_lower.  If
%   rel_thickness_lower is not specified, it defaults to
%   rel_thickness_upper, giving elliptical cross-sections symmetric in the
%   plane Z=0.
%
%   If the original mesh is flat in the XY plane, the resulting mesh will
%   be flat if and only if rel_thickness_upper is equal to
%   rel_thickness_lower.

    if nargin < 3
        rel_thickness_lower = rel_thickness_upper;
    end

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
    % maxradii = sqrt( boundaryshape(:,2).^2 + boundaryshape(:,3).^2 );
    maxradii = abs(boundaryshape(:,2));
    radii = interp1( boundaryshape(:,1), maxradii, m.nodes(:,2) );
    new_z_base = sqrt( radii.^2 - m.nodes(:,1).^2 );
    new_z_upper = rel_thickness_upper * new_z_base;
    new_z_lower = rel_thickness_lower * new_z_base;
    oldsemithickness = (m.prismnodes(2:2:end,3) - m.prismnodes(1:2:end,3))/2;
    m.prismnodes(1:2:end,3) = -oldsemithickness - new_z_lower;
    m.prismnodes(2:2:end,3) = oldsemithickness + new_z_upper;
    m.nodes(:,3) = (m.prismnodes(1:2:end,3) + m.prismnodes(2:2:end,3))/2;
end
