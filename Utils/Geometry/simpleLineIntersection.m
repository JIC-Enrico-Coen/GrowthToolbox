function [a,b,p,q] = simpleLineIntersection( p1, p2, q1, q2 )
%[a,b,p,q] = simpleLineIntersection( p1, p2, q1, q2 )
%   p1, p2, q1, q2 are 3D points.
%   These define two infinite lines, one through p1 and p2, one through q1
%   and q2.  This procedure calculates the nearest point on each line to
%   the other.  These points are respectively P and Q.  A and B are defined
%   by P = (1-A)*P1 + A*P2, Q = (1-B)*Q1 + B*Q2.  That is, A is the
%   proportion of the way from P1 to P2 that P lies at, and similarly for B.
%
%   There is no special handling of singular cases, such as when the two
%   points of either line segment coincide, or when the two lines are
%   parallel.  In such cases the results may contain Inf or NaN values.

    pdiff = p2-p1;
    qdiff = q2-q1;
	X = [pdiff;qdiff]*[pdiff',qdiff'];
    r = p1-q1;
    Y = -[pdiff;qdiff]*r';
    if cond(X) > 100000
        a = 0;
        p = p1;
        [q,b] = nearestPointOnLine( [q1;q2], p );
    else
        V = X\Y;
        a = V(1);
        b = -V(2);

        p = a*p2 + (1-a)*p1;
        q = b*q2 + (1-b)*q1;
    end
end
