function q = retimeSR( q0, T0, T )
%q = retimeSR( q0, T0, T )
%   Solve 2(1-q)/T(1+q) = 2(1-q0)/T0(1+q0) for q.

    r = (T/T0) * (1-q0)/(1+q0);
    q = (1-r)/(1+r);
    
    p0 = equivSR( q0, T0 )
    p = equivSR( q, T )
end

    
