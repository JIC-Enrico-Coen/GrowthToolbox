function [s,smap] = randSampleNoReplace( n, k, dist )
%s = randSampleNoReplace( n, k, dist )
%   Make a random sample of K items in the range 1:N without replacement,
%   using DIST as the relative probabilities.  Negative members of DIST are
%   treated as zero.  Matlab's RANDSAMPLE procedure does not support
%   sampling without replacement from a distribution; this does.
%
%   If no more than than K values have positive probabilities, all of those
%   values are returned.
%
%   If SMAP is requested, it is a boolean vector of length N, which is true
%   for all the selected elements.
%
%   S is in general not in sorted order.  If you want a sorted list,
%   FIND(SMAP) is faster than SMAP(S) and gives the same result.
%
%   See also: randsample

    if nargin < 3
        s = randsample(n,min(k,n));
    else
        values = 1:n;
        values( dist<=0 ) = [];

        if k >= length(values)
            s = values;
        else
            d = dist(dist>0);
            s = zeros(1,k);
            si = 0;
            remaining = k;
            while si < k
                % fprintf( 1, '%s: have %d values, getting %d of %d\n', mfilename(), length(s), remaining, length(values) );
                s1 = randsample( length(values), remaining, true, d );
                s1 = unique(s1);
                s( (si+1):(si+length(s1)) ) = values(s1);
                si = si+length(s1);
                % fprintf( 1, '%s: got %d unique values, now have %d\n', mfilename(), length(s1), length(s) );
                values(s1) = [];
                d(s1) = [];
                remaining = remaining - length(s1);
            end
        end
    end
    
    if nargout > 1
        smap = false(1,n);
        smap(s) = true;
    end
end
