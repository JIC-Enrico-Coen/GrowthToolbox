function [vertexes,vertexnormals,curvature] = projectSquareToCap( capFraction, numplanes, vertexPlanes2 )
%[vertexes,vertexnormals,curvature] = projectSquareToCap( capFraction, numplanes, vertexPlanes2 )
%   Convert a square grid of vertexes to a spherical cap.

    if nargin < 2
        numplanes = 17;
    end
    if nargin < 3
        planes = 1:numplanes;
        vertexPlanes2 = [ repmat( planes', numplanes, 1 ), reshape( repmat( planes, numplanes, 1 ), [], 1 ) ];
    end
    theta = acos( 1 - capFraction );
    vp = (vertexPlanes2-1) * (2/(numplanes-1)) - 1; % Ranges from -1 to 1.
    vertexAngle = theta * max(abs(vp),[],2);
    vertexes = [ (vp./sqrt(sum(vp.^2,2))) .* sin(vertexAngle), cos(vertexAngle) - cos(theta) ];
    vertexes(isnan(vertexes)) = 0;
    vertexnormals = vertexes + [0 0 cos(theta)];

    uniquecurvature = 1;
    zz = zeros( 1, 1, size(vertexPlanes2,1) );
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
%         corner_x = shiftdim( reducedvxs(corners,1), -2 );
%         corner_y = shiftdim( reducedvxs(corners,2), -2 );
%         corner_z = shiftdim( reducedvxs(corners,3), -2 );
%         corner_xy = sqrt( corner_x.^2 + corner_y.^2 );
%         
%         zz = zeros( size( corner_x ) );
%         oo = ones( size( corner_x ) );
% 
%         cp = corner_xy;
%         sp = corner_z;
%         rp = [ cp zz -sp;
%                zz  oo  zz;
%                sp zz cp ];
%         
%         ct = corner_x./corner_xy;
%         st = corner_y./corner_xy;
%         ct(corner_xy==0) = 1;
%         st(corner_xy==0) = 0;
%         
%         rt = [ ct st zz;
%                -st ct zz;
%                zz zz oo ];
%         
%         r = pagemtimes( rt, rp );
%         curvatures(:,:,corners) = pagemtimes( pagemtimes( r, diag([0 uniquecurvature uniquecurvature]) ), pagetranspose( r ) );
end
