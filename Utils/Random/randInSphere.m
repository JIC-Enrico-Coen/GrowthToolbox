function pts = randInSphere( n, radius, dims )
%pts = randInSphere( n, radius, dims )
%   Choose n points in the given number of dimensions uniformly distributed
%   at random throughout the sphere of given radius centred at the origin.
%
%   Radius defaults to 1 and dims to 3.
%
%   The result has size n * dims.
%
%   See also: randOnSphere.

    if (nargin < 2) || isempty(radius)
        radius = 1;
    end
    if nargin < 3
        dims = 3;
    end
    
    if radius==0
        pts = zeros( n, 3 );
    elseif true
        pts = randOnSphere( n, radius, dims ) .* repmat( rand(n,1).^(1/dims), 1, dims );
        
        % This is more elegant than the above method, but takes about 15%
        % longer to generate 1000000 points:
        
        % pts = randOnSphere( n, radius, dims+2 );
        % pts(:,[dims+1,dims+2]) = [];
    end
end
