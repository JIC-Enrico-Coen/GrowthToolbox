function i = probs2info( p )
%i = probs2info( p )
%   Calculate the Shannon information for a set of probabilities P. The sum
%   of all elements of P should be 1. P may be of any shape.

    i = p.*log2(p);
    
    % When p==0, Matlab computes p*log2(p) as NaN, but the correct answer
    % here is 0.
    i(isnan(i)) = 0;
    
    i = -sum(i(:));
end