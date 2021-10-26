function [tc,xi,positive] = crossings( t, x, threshold )
%[tc,signs] = crossings( t, x, threshold )
%   Given a time series of values x at times t, and a threshold value,
%   determine all of the times at which the x value crosses the threshold.
%   The threshold defaults to 0.
%
%   "Crossing" is defined as one value of x being less than the threshold
%   and a neighbouring value being greater than or equal to the threshold.
%   Thus with a threshold of zero, the sequence [-1 0 1] is defined to have
%   two crossings, and the sequence [1 0 1] to have none.
%
%   The threshold can be a pair of values [x0 x1], where x0 < x1. In this
%   case, a positive crossing will be registered when x transitions
%   from a value <= x1 to one > x1, after which a negative crossing will be
%   registered when x transitions from a value >= x0 to one < x0.
%
%   t and x can be of any shape, provided they have the same number of
%   elements. The results are always returned as column vectors, and all
%   the results have the same length.
%
%   tc is the list of crossing times. It calculated by linear interpolation
%   between the x values on either side of the crossing.
%
%   xi is the indexes of the x values just before each crossing. xi+1 would
%   be the indexes just after each crossing.
%
%   positive is true for each positive-going crossing, and false for each
%   negative-going crossing.

    if nargin < 3
        threshold = 0;
    end
    
    t = t(:);
    x = x(:);

    below = x(:) < threshold;
    crossmap = below(2:end) ~= below(1:(end-1));
    xi = find(crossmap);
    b = (threshold - x(xi)) ./ (x(xi+1) - x(xi));
    a = 1-b;
    tc = a.*t(xi) + b.*t(xi+1);
    positive = x(xi+1) > x(xi);
end
