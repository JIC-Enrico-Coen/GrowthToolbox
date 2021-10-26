function ok = meshBetweenTimes( m, t1, t2, tol )
    if nargin < 4
        tol = m.globalProps.timestep * 0.01;
    end
    ok = meshAtOrAfterTime( m, t1, tol ) && meshAtOrBeforeTime( m, t2, tol );
end
