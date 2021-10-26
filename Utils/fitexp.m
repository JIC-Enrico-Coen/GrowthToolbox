function [a,b] = fitexp( s1, s2, k1, k2 )
%[a,b] = fitexp( s1, s2, k1, k2 )
%   Fit an exponential a*exp(b*s) such that a*exp(b*s1) = k1 and
%   a*exp(b*s2) = k2.
%
%   The arguments should all have either the same shape or be scalars.  The
%   results will be the same shape.

    b = log(k2./k1)./(s2-s1);
    a = k1 .* exp( -(b.*s1) );
end
