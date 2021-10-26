function [cellindexes,bcs,pts] = randPointsOnSurface( nodes, tricellvxs, areas, d, hintFE, hintBC, ...
    bordernodes, borderdistance, maxpts )
%[cellindexes,bcs,pts] = randPointsOnSurface( nodes, tricellvxs, areas, d, hintFE, hintBC, bordernodes, borderdistance, maxpts )
%   Choose a maximal set of points on a surface defined by a set of nodes
%   and a set of triangles, subject to the condition that the
%   distance between any two points is greater than d.  The AREAS
%   argument is a vector of the areas of the triangles.  This can be
%   calculated from the nodes and tricellvxs arguments, and if AREAS is
%   empty, it will be. But if one already has the areas available the
%   recalculation can be avoided. AREAS can more generally be a set of
%   non-negative weights defining the relative probability of choosing a
%   point in each triangle.
%
%   AREAS can also be a per-vertex quantity. This will be linearly
%   interpolated over each triangle and points chosen accordingly.
%
%   AREAS can also be an array the same size as tricellvxs, defining a
%   weight per corner. This is similarly used to interpolate the
%   probability density.
%
%   We use an approximate algorithm for this: first we generate many points
%   at random, far more than the number we estimate that we will eventually
%   select.  Then we select from these points one by one, adding a point to
%   the selected set if it is far enough from each of the previously
%   selected points.  The more points we generate, the less likely we are
%   to have a chance void in our pattern, where we could have added
%   another point but did not.  But the more points we generate, the longer
%   the algorithm takes.
%
%   If hintFE and hintBC are supplied, these points are tried before any of
%   the generated points.
%
%   The result consists of a vector of triangle indexes, the barycentric
%   coordinates of the selected points in those triangles, and the 3d
%   coordinates of the points.
%
%   This method generates a set of points that are guaranteed to be at
%   least d apart from each other, and (if the initial sample is large
%   enough) will ensure that no other point of the surface is more than a
%   distance d from the nearest member of the set.  This still allows for
%   some lumpiness: there can be voids in the pattern whose shortest
%   diameter is up to 2d.
%
%   If d is zero (the default), then points are chosen without regard to
%   their proximity. In this case, maxpts will be the exact number of
%   points generated.
%
%   maxpts defaults (somewhat arbitrarily) to 5000.

    if isempty( tricellvxs )
        cellindexes = [];
        bcs = [];
        pts = [];
        return;
    end
    
    if size(nodes,2) < 3
        nodes(end,3) = 0;
    end

    if isempty( areas )
        areas = triangleareas( nodes, tricellvxs );
    end
    if all(areas==0)
        areas(:) = 1;
    end
    if numel(areas)==1
        areas = ones( size(tricellvxs,1), 1 );
    end
    if all( size(areas) == [size(tricellvxs,1), 3])
        cornerweights = areas;
        areas = sum(cornerweights,2);
    elseif (length(areas) == size(nodes,1)) && (length(areas) ~= size(tricellvxs,1))
        cornerweights = areas(tricellvxs);
        areas = sum(cornerweights,2);
    else
        cornerweights = [];
    end
    
    if (nargin < 4) || isempty(d)
        d = 0;
    end
    
    if nargin < 9
        maxpts = 5000;
    end
    
    if maxpts <= 0
        cellindexes = [];
        bcs = [];
        pts = [];
        return;
    end
    
    if (nargin < 5) || isempty(hintFE)
        hintFE = [];
        hintBC = zeros( 0, 3 );
    end
    haveborder = (nargin >= 8) && ~isempty(bordernodes);
    if haveborder
        borderdsq = borderdistance^2;
    end
    dsq = d*d;
    EXTRA = 10;
    if d <= 0
        % maxpts is the exact number of points to place.
        numpts = maxpts;
        numallpts = maxpts;
    else
        numpts = min( max( 1, ceil( sum(areas)/dsq ) ), maxpts );
        numallpts = min( numpts*EXTRA, maxpts );
    end
  % fprintf( 1, '%s: estimated number of points %d\n', mfilename(), numpts );
    [allcells,allbcs] = randInTriangles( areas, numallpts, true );
    if ~isempty(cornerweights)
        for i=1:length(allcells)
            allbcs(i,:) = randInTriangleGradient( cornerweights(allcells(i),:), 1 );
        end
    end
    allcells = [hintFE;allcells];
    allbcs = [hintBC;allbcs];
    allpts = baryToGlobalCoords( allcells, allbcs, nodes, tricellvxs );
    cellindexes = zeros( numpts, 1 );
    bcs = zeros( numpts, 3 );
    pts = zeros( numpts, 3 );
    numchosen = 1;
    cellindexes(1) = allcells(1);
    bcs(1,:) = allbcs(1,:);
    pts(1,:) = allpts(1,:);
    for i=2:numallpts
        if (dsq < 0) || nonetooclose( allpts(i,:), pts(1:numchosen,:), dsq )
            if (~haveborder) || (dsq < 0) || nonetooclose( allpts(i,:), bordernodes, borderdsq )
                numchosen = numchosen+1;
                cellindexes(numchosen) = allcells(i);
                bcs(numchosen,:) = allbcs(i,:);
                pts(numchosen,:) = allpts(i,:);
            end
        end
    end
    if numchosen < numpts
        cellindexes = cellindexes( 1:numchosen );
        bcs = bcs( 1:numchosen, : );
        pts = pts( 1:numchosen, : );
    end
  % fprintf( 1, '%s: actual number of points %d\n', mfilename(), numchosen );
end

function ntc = nonetooclose( pt, pts, dsq )
    if dsq <= 0
        ntc = true;
    else
        dsqs = (pts(:,1)-pt(1)).^2 + (pts(:,2)-pt(2)).^2 + (pts(:,3)-pt(3)).^2;
        ntc = all( dsqs > dsq );
    end
end
