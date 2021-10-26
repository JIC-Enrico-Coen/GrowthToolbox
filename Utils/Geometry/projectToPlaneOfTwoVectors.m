function d1 = projectToPlaneOfTwoVectors( d, e1, e2 )
%d1 = projectToPlaneOfTwoVectors( d, e1, e2 )
%   Project the vector d perpendicularly to the plane containing the
%   vectors e1 and e2.  All vectors must be 1x3 arrays.
%
%   If e1 and e2 are parallel, then d is projected onto their common
%   direction.  If either e1 or e2 is zero, d is projected onto the other;
%   if both are zero, d1 is zero.

    e12 = cross( e1, e2 );
    deltad = e12*dot(d,e12)/sum(e12.^2);
    if any(isnan(deltad))
        e1n = norm(e1);
        e2n = norm(e2);
        if e1n > e2n
            d1 = projectPointToLine( [0 0 0; e1], d, false );
        else
            d1 = projectPointToLine( [0 0 0; e2], d, false );
        end
    else
        d1 = d - deltad;
    end
    
    % All of these should be zero, to within rounding error.
%     det_de1e2 = det([d1;e1;e2])
%     a1 = vecangle( deltad, e1 )-pi/2
%     a2 = vecangle( deltad, e2 )-pi/2
end
