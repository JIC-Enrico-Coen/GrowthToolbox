function dbc = vec2bc( v, vxs, n )
%bc = vec2bc( v, vxs )
%   Convert a vector to barycentric coordinates with respect to the
%   triangle whose vertexes are the rows of the 3*3 matrix vxs.  n, if
%   supplied and nonempty, is a normal vector to the triangle.
%   v can be an M*D array of M points, and all the points will be
%   converted.  vxs can only specify a single triangle.
%   The sum of the barycentric coordinates will be zero.
%
%   The result should satisfy v = bc*vxs up to rounding error.

    if nargin < 3
        n = [];
    end
    npts = size(v,1);
    bc = baryCoords( vxs, n, v + repmat( vxs(1,:), npts, 1 ) );
    dbc = bc - repmat( [1,0,0], npts, 1 );
    norms = sqrt( sum( dbc.^2, 2 ) );
    dbc = dbc./norms;
end
