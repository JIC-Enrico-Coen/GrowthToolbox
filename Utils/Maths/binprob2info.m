function i = binprob2info( p )
%i = binprob2info( p )
%   Calculate the Shannon information of a binary outcome of probability P.
%   P may have any shape and I will have the same shape.

    i = -p.*log2(p) - (1-p).*log2(1-p);
    
    % When p==0, Matlab computes p*log2(p) as NaN, but the correct answer
    % here is 0.
    i(isnan(i)) = 0;
end

