function pts = randOnSphere( n, radius, dims )
%pts = randOnSphere( n, radius, dims )
%   Choose n points in the given number of dimensions uniformly distributed
%   at random over the surface of the sphere of given radius centred at the
%   origin.
%
%   Radius defaults to 1 and dims to 3.
%
%   The result has size n * dims.
%
%   See also: randInSphere.

    if (nargin < 2) || isempty(radius)
        radius = 1;
    end
    if nargin < 3
        dims = 3;
    end
    
    if radius==0
        pts = zeros( n, 3 );
    else
        pts = randn( n, dims );
        pts = radius * (pts ./ sqrt(sum(pts.^2,2)));
    end
end
