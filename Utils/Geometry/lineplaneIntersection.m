function [intersection,r] = lineplaneIntersection( p1, p2, n, c )
%[i,r] = lineplaneIntersection( p1, p2, n, c )
%   Find the intersection between the line through p1 and p2, and the plane
%   through c perpendicular to n.
%   All vectors must be row vectors.
%   r will be the value such that i = p1*(1-r) + p2*r.

    if 0
        d0 = dotproc2(n,c);
        d1 = dotproc2(n,p1);
        d2 = dotproc2(n,p2);
        d12 = d2-d1;
        r = (d0-d1)/d12;
        intersection = (1-r)*p1 + r*p2;
    else
        u = dotproc2(p1-c,n);
        v = dotproc2(p2-c,n);
        if u==v
            fprintf( 1, 'lpI:\n' );
            p1
            p2
            n
            c
        end
        r = u/(u-v);
        intersection = (1-r)*p1 + r*p2;
    end
    
    
%    fprintf( 1, 'lpi: %.3f %.3f\n', a, b );
end
