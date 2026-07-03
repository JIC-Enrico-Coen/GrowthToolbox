function y = tailLifetime( x, varargin )
%y = tailLifetime( x, distribution, ... )
%y = tailLifetime( x, cdf, invcdf )
%
%   DISTRIBUTION is the name of a probability distribution, and the
%   remaining arguments are its parameters. Alternatively, CDF is a
%   function handle for a cumulative distribution function, and INVCDF is a
%   function handle for its inverse.
%
%   Let Z the median value of the distribution conditional upon the value
%   being greater than or equal to X. Then Y is max( 0, Z-X ).
%
%   When the distribution is one of lifetimes, then tailLifetime( X, ... )
%   is the median remaining lifetime, conditional upon having survived to
%   time X.
%
%   X can be of any shape, and Y will have the same shape.
%
%   Valid values of DISTRIBUTION and subsequent parameters are those that
%   can be given to the Matlab functions CDF and ICDF. The Cauchy
%   distribution is not among these, but can be specified as the T
%   distribution ('t') with parameter 1.
%
%   This procedure relies on the CDF and ICDF functions, which are in the
%   Statistics Toolbox.
%
%   See also: CDF, ICDF.

    if length(varargin)==1
        y = nan(size(x));
    else
        if ischar( varargin{1} )
            distname = varargin{1};
            cumdistfunc = @(x) cdf( distname, x, varargin{2:end} );
            invcumdistfunc = @(x) icdf( distname, x, varargin{2:end} );
        else
            cumdistfunc = varargin{1};
            invcumdistfunc = varargin{2};
        end
        y = max( 0, invcumdistfunc( (cumdistfunc( x ) + 1)/2 ) - x );
    end
    y = cast( y, class(x) );
end
