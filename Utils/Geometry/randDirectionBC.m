function dbc = randDirectionBC( vxs, n )
%dbc = randDirectionBC( vxs, n )
%   Select N uniformly distributed directions parallel to the triangle whose
%   three vertexes are the rows of vxs, and express them as directional
%   barycentric coordinates with respect to those points.
%
%   If the triangle has zero area, then the components of dbc will all be NaN.

    if nargin < 2
        n = 1;
    end
    dims = size(vxs,2);
    if dims==3
        normal = trinormal( vxs );
        normal = normal/norm(normal);
    else
        vxs(:,3) = 0;
        normal = [0 0 1];
    end
    x = vxs(2,:)-vxs(1,:);
    x = x/norm(x);
    if dims==3
        y = cross(normal,x);
    else
        y = [-x(2), x(1), 0];
    end
    theta = rand(n,1)*(2*pi);
    c = cos(theta);
    s = sin(theta);
    v = c*x + s*y;
    [dbc,~] = baryDirCoords( vxs, normal, v );
end
