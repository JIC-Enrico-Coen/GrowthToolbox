function c = centroids( vertexes, simplexes )
%c = centroids( vertexes, simplexes, selected )
%   VERTEXES is an N*D array of N D-dimensional vectors.
%   SIMPLEXES is a T*K array of indexes into 1:N, defining T simplexes of K
%   vertexes each.
%
%   If MODE is not supplied, then it is assumed that the per-vertex values
%   are linearly interpolataed over the simplexes. This will also happen is
%   MODE is 'mid' or 'ave' or empty. If MODE is 'min or 'max', then the
%   value over each simplex will be the minimum of maximum of the values at
%   the vertexes.
%
%   See also: polyCentroid.

    spacedims = size( vertexes, 2 );
    simplexpoints = size( simplexes, 2 );
    fevxvalues = reshape( vertexes( simplexes', : ), simplexpoints, [], spacedims );
    c = shiftdim( sum( fevxvalues, 1 ), 1 )/simplexpoints;
end
