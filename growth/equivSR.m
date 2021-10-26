function p = equivSR( q, T )
%p = equivSR( q, T )
%   Find the continuous strain retention that is equivalent to a discrete
%   strain retention of q with time step T.

    p = (2/T)*(1-q)/(1+q);
end
