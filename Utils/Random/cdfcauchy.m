function y = cdfcauchy( x, centre, spread )
%y = cdfcauchy( x, centre, spread )
%   Evaluate at X the CDF of the Cauchy distribution with the given CENTRE
%   and SPREAD parameters (by default 0 and 1).
%
%   X may be an array of any shape. Y will have the same shape and class
%   (double or single) as X. CENTRE and SPREAD, if supplied, can each be
%   either one value or an array the same shape as X.
%
%   The values -Inf and Inf are mapped to 0 and 1 respectively.
%
%   See also: invcdfcauchy, pdfcauchy, randcauchy.


    if (nargin < 2) || isempty(centre)
        centre = 0;
    end
    if (nargin < 3) || isempty(spread)
        spread = 1;
    end
    
    x = (x-centre)./spread;
    y = atan(x)/pi + 0.5;
    y = cast(y,class(x));
end