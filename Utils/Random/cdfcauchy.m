function y = cdfcauchy( x, centre, spread )
%y = cdfcauchy( x, centre, spread )
%   Evaluate at X the CDF of the Cauchy distribution with the given CENTRE and
%   SPREAD parameters (by default 0 and 1).
%
%   See also: invcdfcauchy, pdfcauchy, randcauchy.


    if (nargin < 2) || isempty(centre)
        centre = 0;
    end
    if (nargin < 3) || isempty(spread)
        spread = 1;
    end
    
    x = (x-centre)/spread;
    y = atan(x)/pi + 0.5;
end