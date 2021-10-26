function [p0,a0,p1,a1] = lineSphereIntersection( p01, q, d )
%[p0,a0,p1,a1] = lineCircleIntersection( p01, q, d )
%   Calculate the points on the line through p01 (a 2*D array) which are at
%   a distance r from the point q (a 1*D vector).  p0 and p1 are the two
%   points, and a0 and a1 are their barycentric coordinates relative to p01.
%   If there is only one point, p1 and a1 will be empty.  If there are no
%   such points, all of the output arguments will be empty.
%
%   When there are two points, a0(2) < a1(2).
%
%   This works in any number of dimensions.

    a = norm( q-p01(2,:) );
    b = norm( q-p01(1,:) );
    c = norm( p01(1,:)-p01(2,:) );
    
    if c==0
        % The two points p01 coincide.
        if a==d
            % They are at distance d from q. One intersection.
            p0 = p01(1,:);
            a0 = [1 0];
            p1 = [];
            a1 = [];
        else
            % They are not at distance d from q. No intersections.
            p0 = [];
            a0 = [];
            p1 = [];
            a1 = [];
        end
        
        return;
    end
    
    asq = a*a;
    bsq = b*b;
    csq = c*c;
    eB = (asq-bsq)/csq;
    eC = (asq+bsq-2*d*d)/(2*csq) - 1/4;
    disc = eB^2 - 4*eC;
    if disc < 0
        % No solutions.
        p0 = [];
        a0 = [];
        p1 = [];
        a1 = [];
    elseif disc==0
        % One solution.
        eta = -eB/2;
        a0 = [0.5-eta,0.5+eta];
        p0 = a0*p01;
        p1 = [];
        a1 = [];
    else
        % Two solutions.
        sdisc = sqrt(disc);
        eta = (-eB-sdisc)/2;
        a0 = [0.5-eta,0.5+eta];
        p0 = a0*p01;
        eta = (-eB+sdisc)/2;
        a1 = [0.5-eta,0.5+eta];
        p1 = a1*p01;
    end
end
