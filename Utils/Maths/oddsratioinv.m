function p = oddsratioinv( o )
%p = oddsratioinv( o )
%   Calculate the probability for an odds ratio o: p = 1/(1 + 1/o).
%   o can be a matrix of any size.  o=Inf implies p=1.
%
%   SEE ALSO: oddsratio.

    p = 1./(1 + 1./o);
end
