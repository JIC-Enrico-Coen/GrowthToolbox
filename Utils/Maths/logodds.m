function o = logodds( p )
%o = logodds( p )
%   Calculate the log-odds of a probability, i.e. log( p/(1-p) ).
%   p can be a matrix of any shape.  logodds(0) is -Inf, and logodds(1) is
%   Inf.
%
%   SEE ALSO: logoddsinv.

    o = log( p ./ (1-p) );
end
