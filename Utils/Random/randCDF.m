function r = randCDF( cdf, varargin )
%r = randCDF( cdf, varargin )
%   Sample according to a CDF.  The arguments after the first specify the
%   shape of an array in the same way as for rand().  CDF is a vector of
%   increasing values representing a cumulative distribution function.  The
%   result is an array of indexes into CDF.  The probability of selecting
%   index N is cdf(N)/cdf(end) if N=1, otherwise (cdf(N) - cdf(n-1))/cdf(end).

    x = rand( [varargin{:}] ) * cdf(end);
    r = binsearchall( cdf, x );
end
