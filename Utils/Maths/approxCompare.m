function approxsign = approxCompare( t1, t2, tol )
    if t1 < t2-tol
        approxsign = -1;
    elseif t1 > t2+tol
        approxsign = 1;
    else
        approxsign = 0;
    end
end
