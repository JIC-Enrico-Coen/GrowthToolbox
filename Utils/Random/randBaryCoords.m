function bc = randBaryCoords( n, d )
%bc = randBaryCoords
%   Return random barycentric coordinates yielding a uniform distribution
%   over a simplex.  N is the number of coordinate sets to return,
%   defaulting to 1.
%
%   D is the number of space dimensions.  The default is 2, i.e. triangles.
%   The result has size N*(D+1).

    if nargin < 1, n = 1; end
    if nargin < 2
        d = 2;
    end
    
    bc = zeros(n,d+1);
    bc(:,1) = 1;
    for di=1:d
        k = rand(n,1).^(1/di);
        bc(:,di+1) = 1-k;
        bc(:,1:di) = bc(:,1:di) .* repmat( k, 1, di );
    end
end
