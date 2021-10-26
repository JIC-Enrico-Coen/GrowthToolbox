function x = sampleexp( rate, sz )
%x = sampleexp( rate, sz )
%   Obtain a random sample of the given size SZ (any number of dimensions)
%   from the exponential distribution with the given RATE.
%
%   The mean and standard deviation of this distribution are both equal to
%   1/RATE. Its median is log(2)/(2 * RATE) = 0.3466/RATE.
%
%   0 and Inf are valid values for RATE. All samples will be Inf or 0
%   respectively.
%
%   SZ defaults to 1. If SZ is a single number the result is an array of
%   size [SZ 1].
%
%   If RATE is a matrix of more than one element, then for each element of
%   RATE the required number of samples will be drawn. The result will have
%   the shape [ size(rate) sz ], except that trailing 1s in
%   size(rate) will be ignored. Thus sampleexp( rand(1,4), 5 ) will
%   return a result of size [1 4 5], but sampleexp( rand(4,1), 5 ) will
%   return a result of size [4 5].

    if nargin < 2
        sz = 1;
    elseif isempty(sz)
        sz = 0;
    end
    
    if numel(rate) ~= 1
        szr = size(rate);
        si = find( szr ~= 1, 1, 'last' );
        szr( (si+1):end ) = [];
        rep = [ ones(size(szr)), sz ];
        sz = [ szr sz ];
        rate = repmat( rate, rep );
    end
    
    if length(sz)==1
        sz = [sz 1];
    end
    
    x = -log( rand(sz) )./rate;
end
