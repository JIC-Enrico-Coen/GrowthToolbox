function [vertexes,vertexnormals,curvature] = projectBoxToSphere( diameter, numplanes, vertexPlanes )
%[vertexes,vertexnormals,curvature] = projectBoxToSphere( diameter, numplanes, vertexPlanes )
%   Convert a box-shaped mesh to a sphere.

    vertexes = [];
    vertexnormals = [];
    if nargin < 2
        numplanes = 17;
    end
    if nargin < 3
        planes = 1:numplanes;
        vertexPlanes = [ repmat( planes', numplanes^2, 1 ), ...
                         reshape( repmat( planes, numplanes, numplanes ), [], 1 ), ...
                         reshape( repmat( planes, numplanes^2, 1 ), [], 1 ) ];
        onSurface = any( vertexPlanes==1, 2 ) | any( vertexPlanes==numplanes, 2 );
        vertexPlanes = vertexPlanes( onSurface, : );
    end
    if isempty( numplanes )
        numplanes = max( vertexPlanes(:) );
    end
    
    radius = diameter/2;
    coordvals = linspace( -1, 1, numplanes )';
    
    vertexes = coordvals( vertexPlanes );
    d = sqrt(sum(vertexes.^2,2));
    vertexnormals = vertexes./d;
    vertexes = vertexnormals * radius;
    uniquecurvature = 1/radius;
    zz = zeros( 1, 1, size(vertexes,1) );
    oo = ones( size( zz ) );

    vxs_x = shiftdim( vertexes(:,1), -2 );
    vxs_y = shiftdim( vertexes(:,2), -2 );
    vxs_z = shiftdim( vertexes(:,3), -2 );
    vxs_xy = sqrt( vxs_x.^2 + vxs_y.^2 );
    
    cp = vxs_xy;
    sp = vxs_z;
    rp = [ cp zz -sp;
           zz  oo  zz;
           sp zz cp ];

    ct = vxs_x./vxs_xy;
    st = vxs_y./vxs_xy;
    ct(vxs_xy==0) = 1;
    st(vxs_xy==0) = 0;

    rt = [ ct st zz;
           -st ct zz;
           zz zz oo ];

    r = pagemtimes( rt, rp );
    curvature = pagemtimes( pagemtimes( r, diag([0 uniquecurvature uniquecurvature]) ), pagetranspose( r ) );
    

    eigcurve = curvatureEigs( curvature );
end

function e = curvatureEigs( c )
    e = zeros( size(c,3), 3 );
    for ci = 1:size(c,3)
        e(ci,:) = eig(c(:,:,ci))';
    end
end
