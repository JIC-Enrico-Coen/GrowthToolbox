function [dbc,dbc_err,n] = baryDirCoords( vxs, n, d )
%[bc,n] = baryDirCoords( vxs, n, d )
%   Calculate the directional barycentric coordinates of a direction d
%   relative to a triangle whose vertexes are the rows of vxs, and whose
%   normal vector is n.  If n is empty it will be computed (and returned as
%   a result).  If supplied, it may be of any non-zero length.
%
%   bc_err is the angle between the supplied direction and the direction of
%   the computed dirbcs.  n 

    if isempty(n)
        n = trinormal( vxs );
    end
    
    m = mean(vxs,1);
    dbc = baryCoords( vxs, n, d+m, false ) - [1/3 1/3 1/3];
    norms = sqrt( sum( dbc.^2, 2 ) );
    dbc = dbc./norms;
    
    dbc_err = vecangle( dbc*vxs, d );
end