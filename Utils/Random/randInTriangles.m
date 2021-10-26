function [cells,bcs] = randInTriangles( areas, n, uniformise, d )
%[cells,bcs] = randInTriangles( areas, n, uniformise, d )
%   Generate a set of n random points in the plane, uniformly distributed
%   over the triangles (which are assumed to be disjoint).  The results are
%   returned in the form of cell indexes and barycentric coordinates.
%
%   If uniformise is true, then each cell is guaranteed to contain a number
%   of points within 1 of its expected number.
%
%   D defaults to 2, and is the dimension of the space.  3 will return
%   barycentric coordinates for tetrahedra (in which case "areas" means
%   volumes), etc.

    if nargin < 4
        d = 2;
    end
    if (n <= 0) || isempty(areas)
        cells = [];
        bcs = [];
    else
        if nargin < 3
            uniformise = false;
        end
        cells = randBins( areas, n, uniformise );
        bcs = randBaryCoords( n, d );
    end
end
