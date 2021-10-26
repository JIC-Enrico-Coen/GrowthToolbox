function c = polyhedronCentroid( pts, sides )
%c = polyhedronCentroid( pts, sides )
%   PTS is N*D, representing a set of points in D-dimensional space, and
%   SIDES is a T*D array of indexes into PTS, representing a set of
%   simplexes defining a polyhedron.
%
%   This procedure finds the centroid of the polyhedron, as a row vector.
%   The polyhedron must be closed.  The orientation of its faces must be
%   consistent, but it does not matter whether it is left- or right-handed.
%
%   This works in any number of dimensions from 2 upwards.
%
%   This will not work for polygons in 3-dimensional space, for which see
%   polyCentroid.
%
%   For polygons in the plane, SIDES can be omitted, in which case the
%   points are assumed to be listed in order around the polygon.
%
%   See also: polyCentroid

    dims = size(pts,2);
    numpts = size(pts,1);
    if (dims==2) && (nargin<2)
        sides = [ (1:numpts)' ([2:numpts 1])' ];
    end
    ptspertri = size(sides,2);
    numtris = size(sides,1);
    
    xx = permute( reshape( pts(sides',:), ptspertri, numtris, dims ), [ 1, 3, 2 ] );
    % xx(:,:,i) contains the three vertexes of the i'th triangle as row
    % vectors.
    
    dets = zeros(1,numtris);
    for i=1:numtris
        dets(i) = det(xx(:,:,i));
    end
    % dets is a row vector of the determinants of the triples or pairs of vectors
    % xx(:,:,i).

    volK = sum(dets);
    % volK is 6 times the volume of the polyhedron, or 3 times the volume of the polygon.
    
    centroids = shiftdim( sum(xx,1), 1 )/(ptspertri+1);
    % centroids contains the centroids of all of the tetrahedra formed by
    % each triangle and the origin.
    
    c = sum( centroids .* repmat( dets, [dims 1] ), 2 )'/volK;
    % c is the centroid of the volume.
    
    % As a check, translating, scaling, or rotating the points should
    % produce the same transformation of the centroid.
end
        