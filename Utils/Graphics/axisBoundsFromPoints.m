function bds = axisBoundsFromPoints( pts, relmargin, absmargin )
%bds = axisBoundsFromPoints( pts, relmargin, absmargin )
%   Take a set of N points as an N*D array and place a bounding box around
%   them. The minimal bounding box will be expanded by a factor given by
%   relmargin and an absolute amount given by absmargin. These can be
%   either a single value or a 1*D array. If missing or empty they default
%   to zero.
%
%   This is useful for ensuring that a bounding box constructed to fit a
%   set of points has non-zero size along every dimension, and is therefore
%   a valid argument to axis().
%
%   The result will have size 1 * 2D, and lists the bounds in the order
%   xlo, xhi, ylo, yhi, etc.

    dims = size(pts,2);
    if (nargin < 3) || isempty( absmargin )
        absmargin = zeros( 1, dims );
    end
    if (nargin < 2) || isempty( relmargin )
        relmargin = zeros( 1, dims );
    end
    if numel(relmargin)==1
        relmargin = relmargin + zeros( 1, dims );
    end
    if numel(absmargin)==1
        absmargin = absmargin + zeros( 1, dims );
    end
    lo = min(pts, [], 1);
    hi = max(pts, [], 1);
    mid = (lo+hi)/2;
    posmargin = (hi-mid).*relmargin + absmargin;
    newlo = lo - posmargin;
    newhi = hi + posmargin;
    bds = [ newlo; newhi ];
    bds = reshape( bds, 1, [] );
end