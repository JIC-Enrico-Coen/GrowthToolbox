function p = proprob( p, k, m )
%p = proprob( p, pro_inh )
%   Calculate a probability resulting from promoting or inhibiting the
%   probability P by the amount PRO_INH.  A positive amount increases P,
%   and a negative amount decreases it.  This is valid when P is an
%   absolute probability.  When P is a probability per unit time, then it
%   should be simply multiplied by PRO_INH instead.
%
%   When P is 0 or 1, the result will be 0 or 1 respectively, independently
%   of PRO_INH.  When PRO_INH is 1, then the result will be P.
%
%   SEE ALSO: oddsratio, oddsratioinv.

    p = oddsratioinv( oddsratio(p) .* pro(k,m) );
end
