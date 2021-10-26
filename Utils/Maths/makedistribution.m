function df = makedistribution( pdf )
%df = makedistribution( pdf )
%   Convert a probability density function to a cumulative distribution
%   function.  pdf is a vector of N elements, being the probability of a
%   random variable being equal to 1:N.  df is a vector of the same length,
%   such that df(i) = sum( pdf(1:i) );
%
%   pdf is assumed to sum to 1.
%
%   OBSOLETE: use cumsum instead.

    df = cumsum(pdf);
    total = 0;
    for i=1:length(pdf)
        total = total + pdf(i);
        df(i) = total;
    end
end
