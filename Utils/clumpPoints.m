function [cx,cy,perm,clumpindex] = clumpPoints( x, y, tol )
%[cx,cy,perm,clumpindex] = clumpPoints( x, y, tol )
%   Given a set of 2D points X, Y, sort X (permuting Y the same way) and
%   group the X values into sets in which consecutive members differ by
%   no more than TOL.  For each such set, find the average X and the
%   average Y for the set, returning these in CX and CY.  PERM is the
%   permutation that was applied to sort X, and CLUMPINDEX is an array
%   specifying for each point in the unsorted set, which clump it belongs
%   to.

    npts = size(y,1);
    [x,perm] = sort( x );
    y = y(perm);
    far = x(2:end) - x(1:(end-1)) > tol;
    ends = find(far);
    starts = [1; ends+1];
    ends = [ ends; npts ];
    runlengths = (ends-starts+1);
    cx = zeros(length(starts),1);
    cy = zeros(length(starts),1);
    clumpindex = zeros(npts,1);
    for i=1:length(starts)
        cx(i) = sum( x(starts(i):ends(i)) )/runlengths(i);
        cy(i) = sum( y(starts(i):ends(i)) )/runlengths(i);
        clumpindex(starts(i):ends(i)) = i;
    end
    if nargout >= 4
        clumpindex(perm) = clumpindex;
    end
end
