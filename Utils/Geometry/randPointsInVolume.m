function [cellindexes,bcs,pts] = randPointsInVolume( nodes, tetravxs, volumes, d, hintFE, hintBC )
%[cellindexes,bcs,pts] = randPointsInVolume( nodes, tetravxs, volumes, d, hintFE, hintBC )
%   Choose a maximal set of points in a volume defined by a set of nodes
%   and a set of tetrahedra, subject to the condition that the
%   distance between any two points is greater than d.  The VOLUMES
%   argument is a vector of the volumes of the tetrahedra.  This can be
%   calculated from the nodes and tetravxs arguments, but in the
%   circumstances where we call this, we already have the volumes to hand.
%
%   We use an approximate algorithm for this: first we generate many points
%   at random, far more than the number we estimate that we will eventually
%   select.  Then we select from these points one by one, adding a point to
%   the selected set if it is far enough from each of the previously
%   selected points.  The more points we generate, the less likely we are
%   to have a chance void in our pattern, where we should have added
%   another
%   point but did not.  But the more points we generate, the longer the
%   algorithm takes.
%
%   If hintFE and hintBC are supplied, these points are used before any of
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

    if isempty( tetravxs )
        cellindexes = [];
        bcs = [];
        pts = [];
        return;
    end

    vxsPerSimplex = size(tetravxs,2);
    if (nargin < 5) || isempty(hintFE)
        hintFE = [];
        hintBC = zeros( 0, vxsPerSimplex );
    end
    dsq = d*d;
    EXTRA = 10;
    numpts = max( 1, ceil( sum(volumes)/dsq ) );
    numallpts = numpts*EXTRA;
    if numallpts > 5000
        numallpts = 5000;
    end
  % fprintf( 1, '%s: estimated number of points %d\n', mfilename(), numpts );
    [allcells,allbcs] = randInTriangles( volumes, numallpts, true, 3 );
    allcells = [hintFE;allcells];
    allbcs = [hintBC;allbcs];
    allpts = baryToGlobalCoords( allcells, allbcs, nodes, tetravxs );
    cellindexes = zeros( numpts, 1 );
    bcs = zeros( numpts, vxsPerSimplex );
    pts = zeros( numpts, 3 );
    numchosen = 1;
    cellindexes(1) = allcells(1);
    bcs(1,:) = allbcs(1,:);
    pts(1,:) = allpts(1,:);
    for i=2:numallpts
        if nonetooclose( allpts(i,:), pts(1:numchosen,:), dsq )
            numchosen = numchosen+1;
            cellindexes(numchosen) = allcells(i);
            bcs(numchosen,:) = allbcs(i,:);
            pts(numchosen,:) = allpts(i,:);
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
    dsqs = (pts(:,1)-pt(1)).^2 + (pts(:,2)-pt(2)).^2 + (pts(:,3)-pt(3)).^2;
    ntc = all( dsqs > dsq );
end
