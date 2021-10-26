function s = step( r1, r2, n, open1, open2 )
%s = step( r1, r2, n, open1, open2 )
%   Construct a row vector of equally spaced values from r1 to r2,
%   containing n intervals.
%   If open1 is true, the first value will be omitted.
%   If open2 is true, the last value will be omitted.
%   open1 and open2 default to false.

    if nargin < 4, open1 = false; end
    if nargin < 5, open2 = false; end
    numvals = n+1;
    if open1
        firstval = 1;
        numvals = numvals-1;
    else
        firstval = 0;
    end
    if open2
        lastval = n-1;
        numvals = numvals-1;
    else
        lastval = n;
    end
    if numvals <= 0
        s = [];
    elseif numvals==1
        s = firstval;
    else
        stepsize = (r2-r1)/n;
        s = (firstval:lastval) * stepsize + r1;
    end
end
