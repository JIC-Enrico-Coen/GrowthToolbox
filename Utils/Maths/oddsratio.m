function o = oddsratio( p )
%o = oddsratio( p )
%   Calculate the odds ratio for a probability p: o = p/(1-p).
%   p can be a matrix of any size.  p=1 implies o=Inf.
%
%   SEE ALSO: oddsratioinv.

    o = p ./ (1-p);
end
