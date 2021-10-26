function cutpolygon = plane3DMeshIntersection( m, cuttingPoint, cuttingNormal )
%planeVolumeIntersection( vxs, tricellvxs, cuttingPoint, cuttingNormal )
% Find the intersection between a plane and a closed triangular mesh.
% m: A 3D mesh.
% cuttingPoint: 1*3 position of a point on the cutting plane.
% cuttingNormal: 1*3 vector perpendicular to the cutting plane.
%
%   NEVER USED.  MAY NOT WORK BECAUSE OF PROBLEM IN SPLITINTS APPLIED TO
%   MULTIPLE INTEGERS.

    full3d = usesNewFEs( m );
    if full3d
        vxs = m.FEnodes;
        tricellvxs = m.FEconnectivity.faces( m.FEconnectivity.faceloctype, : );
    else
        vxs = m.nodes;
        tricellvxs = m.tricellvxs;
    end
    cutpolygon = planeVolumeIntersection( vxs, tricellvxs, cuttingPoint, cuttingNormal );
    cutpolygon( all( cutpolygon==cutpolygon([2:end 1],:), 2 ), : ) = [];
    g = gridFromPolygon( cutpolygon(:,[2 3]), 10 );
end
