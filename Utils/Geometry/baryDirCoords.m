function [dbc,dbc_err,n] = baryDirCoords( vxs, n, d )
%[[dbc,dbc_err,n] = baryDirCoords( vxs, n, d )
%   Calculate the directional barycentric coordinates of a direction d
%   relative to a triangle whose vertexes are the rows of vxs, and whose
%   normal vector is n.  If n is empty it will be computed (and returned as
%   a result).  If supplied, it may be of any non-zero length.
%
%   Each of the rows of dbc has sum zero, and dbs*vxs will be a set of unit
%   vectors. These vectors will be in the direction of the vectors in d
%   projected to the plane of the triangle.
%
%   dbc_err is the angle between the supplied direction and the direction
%   of the computed dirbcs.
%
%   If the vertexes are very close to collinear or the directions are close
%   to perpendicular to the triangle, then all the results may include Inf
%   or NaN values and even if not, they may be inaccurate.

    if isempty(n)
        n = trinormal( vxs );
    end
    
    if all(n==0)
        dbc = nan(size(d));
        dbc_err = nan(size(d,1),1);
        return;
    end
    
    mvxs = mean(vxs,1);
    dbc = baryCoords( vxs, n, d+mvxs, false ) - [1/3 1/3 1/3];
    
%     norms = sqrt( sum( (dbc*vxs).^2, 2 ) );
    norms = sqrt( sum( dbc.^2, 2 ) );
    dbc = dbc./norms;
    
    dbc_err = vecangle( dbc*vxs, d );
    
    if sum(dbc) > 1e-4
        xxxx = 1;
        dbc = normaliseDirBaryCoords( dbc );
    end
end