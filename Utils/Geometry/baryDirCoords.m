function [dbc,dbc_err,n] = baryDirCoords( vxs, n, d )
%[[dbc,dbc_err,n] = baryDirCoords( vxs, n, d )
%   Calculate the directional barycentric coordinates of a direction d
%   relative to a triangle whose vertexes are the rows of vxs, and whose
%   normal vector is n.  If n is empty it will be computed (and returned as
%   a result).  If supplied, it may be of any non-zero length.
%
%   bc_err is the angle between the supplied direction and the direction of
%   the computed dirbcs.

    if isempty(n)
        n = trinormal( vxs );
    end
    
    mvxs = mean(vxs,1);
    dbc = baryCoords( vxs, n, d+mvxs, false ) - [1/3 1/3 1/3];
    norms = sqrt( sum( dbc.^2, 2 ) );
    dbc = dbc./norms;
    
    dbc_err = vecangle( dbc*vxs, d );
    
    if sum(dbc) > 1e-4
        xxxx = 1;
        dbc = normaliseDirBaryCoords( dbc );
    end
end