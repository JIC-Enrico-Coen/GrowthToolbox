function y1 = linearCorrect( x, y, xfixed, yfixed )
%y1 = linearCorrect( x, y, xfixed, yfixed )
%   x and y are vectors of the same length defining a curve.
%   xfixed and yfixed similarly define a curve.
%   We want to add a piecewise linear curve to the (x,y) curve to make it
%   pass through all the points of the (xfixed,yfixed) curve. The result is
%   the vector of corrected values of y.
%
%   The values of xfixed need not occur anywhere in x. Both sets of points
%   are interpreted as piecewise linear curves.
%
%   There is no requirement that any of the input arrays be sorted, and
%   they may be of any one-dimensional shape. The result is the same shape
%   as y.
%
%   If the range of x exceeds that of xfixed, the corresponding endpoints
%   of y are fixed at the values given at the extremes of x.
%
%   If yfixed is not provided, it is taken to be all zero.
%
%   Example: linearCorrect( 0:0.1:1, (0:0.1:1).^2, [0 1], [0 0] ) returns
%   (0:0.1:1).^2 - (0:0.1:1), i.e. the original value of y minus exactly
%   the linear function that will make both endpoints zero.

    if isempty(y)
        y1 = y;
        return;
    end
    
    if nargin < 4
        yfixed = zeros(length(xfixed));
    end
    
    [xfixed,p] = sort(xfixed);
    xfixed = xfixed(:);
    yfixed = yfixed(p);
    yfixed = yfixed(:);
    
    [min_x,min_xi] = min(x);
    [max_x,max_xi] = max(x);
    
    if xfixed(1) > min_x
        xfixed = [min_x; xfixed];
        yfixed = [y(min_xi); yfixed];
    end
    if xfixed(end) < max_x
        xfixed(end+1) = max_x;
        yfixed(end+1) = y(max_xi);
    end
    
    yuncorr = interp( x, y, xfixed );
    corrections = yfixed - yuncorr;
    ycorrections = interp( xfixed, corrections, x );
    y1 = y + reshape( ycorrections, size(y) );
end