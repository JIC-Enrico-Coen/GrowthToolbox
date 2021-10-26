function y = invcdfcauchy( x, centre, spread )
%y = invcdfcauchy( x, centre, spread )
%   Evaluate at X the inverse of the CDF of the Cauchy distribution with
%   the given CENTRE and SPREAD parameters (by default 0 and 1).
%
%   The values 0 and 1 are mapped to -Inf and Inf respectively.
%
%   See also: pdfcauchy, cdfcauchy, randcauchy.

    if (nargin < 2) || isempty(centre)
        centre = 0;
    end
    if (nargin < 3) || isempty(spread)
        spread = 1;
    end
    
    z = x <= 0;
    o = x >= 1;
    
    y = centre + spread*tan(pi*(x-0.5));
    y(z) = -Inf;
    y(o) = Inf;
end