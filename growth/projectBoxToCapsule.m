function [vertexes,vertexnormals,curvature] = projectBoxToCapsule( totalLength, diameter, numplanes, vertexPlanes )
%[vertexes,vertexnormals,curvature] = projectBoxToCapsule( totalLength, diameter, numplanes, vertexPlanes )
%   Convert a box-shaped mesh to a capsule shape.

    vertexes = [];
    vertexnormals = [];
    if nargin < 3
        numplanes = 17;
    end
    if nargin < 4
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
    
    
    
    
    % Decide where to position the PD edges.
    
    radius = diameter/2;
    cylinderLength = max( totalLength - 2*radius, 0 );
    totalLength = cylinderLength + 2*radius;
    capheight = min( totalLength/3, radius );
    cylhalflength = totalLength/2 - capheight;
    capcentre = cylhalflength + capheight - radius;
    
    firstYplane = vertexPlanes(:,2) == 1;
    lastYplane = vertexPlanes(:,2) == numplanes;
    
    [vv,vvn,capcurvature] = projectSquareToCap( capheight/radius, numplanes, vertexPlanes( lastYplane, [1 3] ) );
    vv = vv*radius;
    vv = vv( :, [1 3 2] );
    vvn = vvn( :, [1 3 2] );
    vv(:,2) = vv(:,2) + cylhalflength;
    capcurvature = capcurvature/radius;
    capcurvature = capcurvature( [1 3 2], [1 3 2], : );

    
    [vvneg,vvnegn,negcapcurvature] = projectSquareToCap( capheight/radius, numplanes, vertexPlanes( firstYplane, [1 3] ) );
    vvneg = vvneg*radius;
    vvneg = vvneg( :, [1 3 2] );
    vvnegn = vvnegn( :, [1 3 2] );
    vvneg(:,2) = vvneg(:,2) + cylhalflength;
    negcapcurvature = negcapcurvature/radius;
    negcapcurvature = negcapcurvature( [1 3 2], [1 3 2], : );
%     vvneg = vv;
    vvneg(:,2) = -vvneg(:,2);
%     vvnegn = vvn;
    vvnegn(:,2) = -vvnegn(:,2);
%     negcapcurvature = capcurvature;
    negcapcurvature(:,2,:) = -negcapcurvature(:,2,:);
    negcapcurvature(2,:,:) = -negcapcurvature(2,:,:);
    
    ysteps = linspace( -cylhalflength, cylhalflength, numplanes )';
    vfrac = (vertexPlanes-1)*(2/(numplanes-1)) - 1;
    
    cylvxs = abs(vfrac(:,2)) < 1;
    ycoords = vfrac(:,2) * cylhalflength;
    
    cylxz = vfrac(cylvxs,[1 3]);
    cylxz = cylxz./sqrt(sum(cylxz.^2,2));    
    
    vertexes( lastYplane, : ) = vv;
    vertexes( firstYplane, : ) = vvneg;
    vertexes( cylvxs, : ) = [ cylxz(:,1)*radius, ysteps(vertexPlanes(cylvxs,2)), cylxz(:,2)*radius ];
    
    vertexnormals( lastYplane, : ) = vvn;
    vertexnormals( firstYplane, : ) = vvnegn;
    vertexnormals( cylvxs, : ) = [ cylxz(:,1), zeros(sum(cylvxs),1), cylxz(:,2) ];
    % Establish the curvature data. The principal curvatures everywhere are
    % both 1/radius.
    % The principal axes can be arbitrary orthonormal tangents.
    uniquecurvature = 1/radius;
    cc = cylxz(:,2);
    if ~isempty(cc)
        ss = cylxz(:,1);
        zz = zeros( size(cc) );
        oo = ones( size(cc) );
        rotmat = reshape( [ cc -ss zz, ss cc zz, zz zz oo ]', 3, 3, [] );
        cylcurvature = pagemtimes( pagemtimes( rotmat, [ uniquecurvature 0 0; 0 0 0; 0 0 0 ] ), pagetranspose( rotmat ) );
    end
    

    curvature( :, :, lastYplane ) = capcurvature;
    curvature( :, :, firstYplane ) = negcapcurvature;
    curvature( :, :, cylvxs ) = cylcurvature;
    eigcap = curvatureEigs( capcurvature );
    eignegcap = curvatureEigs( negcapcurvature );
    eigcyl = curvatureEigs( cylcurvature );
end

function e = curvatureEigs( c )
    e = zeros( size(c,3), 3 );
    for ci = 1:size(c,3)
        e(ci,:) = eig(c(:,:,ci))';
    end
end
