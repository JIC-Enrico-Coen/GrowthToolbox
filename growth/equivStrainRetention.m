function r1 = equivStrainRetention( t0, t1, r0 )
%r1 = equivStrainRetention( t0, t1, r0 )
%   Compute the value of strain retention for a time step t1 that is
%   equivalent to having strain retention r0 (default zero) at time step
%   t0.  t1 must be less than or equal to t0.

    if nargin < 3
        r0 = 0;
    end
    r0 = min(max(r0,0),1);
    if r0==1
        r1 = 1;
    else
        S0 = avstrain( r0, t0 );
        r1 = strret( S0, t1 );
      % r0t0 = r0^t0
      % r1t1 = r1^t1
      % r1t0 = r1^t0
      % S1 = avstrain( r1, t1 )
    end

%   r1 = ((t0-t1)./(t0+t1)).^(1./t1);
end

function S = avstrain( r, t )
% Compute the residual strain multipler from the dissipation rate r and the
% time step t.
    S = t*(0.5 + 1/(r^(-t)-1));
end

function r = strret( S, t )
% Compute the dissipation rate r from the residual strain multiplier S and
% the time step t.
    if t==0
        r = exp(-1/S);
    else
        k = t/(2*S);
    	r = ((1 - k)/(1 + k))^(1/t);
    end
end
