function y = pdfcauchy( x, centre, spread )
%y = pdfcauchy( x, centre, spread )
%   Evaluate at X the probability density function of the Cauchy
%   distribution with the given CENTRE and SPREAD parameters (by default 0 and 1).
%
%   See also: cdfcauchy, invcdfcauchy, randcauchy.

    if (nargin < 2) || isempty(centre)
        centre = 0;
    end
    if (nargin < 3) || isempty(spread)
        spread = 1;
    end
    
    x = (x-centre)/spread;
    y = 1./(pi*(1 + x.^2));
end