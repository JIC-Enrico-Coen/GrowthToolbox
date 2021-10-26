function [r,c,u1,resid,resid1] = fitRotation( x, u )
%[r,c,u1,resid,resid1] = fitRotation( x, u )
%   Given a set of points x and displacements of those points u, each an
%   N*3 matrix, find the rotation r about centre c that best fits the
%   displacements.  u1 is set to the residual displacements, resid is set
%   to the mean squared error of u, and resid1 to that of u1.  x, u, r, and
%   u1 are related by:
%       for all i, u1(i,:) = u(i,:) - cross(r,x(i,:)) - c
%   The calculation asumes that the displacements ant rotation are
%   infinitesimal.  Equivalently, if u is a matrix of velocities, r will be
%   the angular velocity and c the linear velocity which best fit u.
%
%   The method is as follows.  Define:
%   ubar = average of u
%   xbar = average of x
%   crosscross(a,b) for row vectors a and b = the matrix P-Q, where P is
%       dot(a,b) times the identity, and Q is a'*b.  For matrices of row
%       vectors, it sums over all the rows.  The result is a 3*3 matrix.
%   Then the desired rotation r satisfies:
%       (crosscross(u,x) - crosscross(ubar,xbar)) . r =
%               cross(x,u) - N cross(xbar,ubar)
%   and c is obtained as c = ubar - cross(r,xbar).
%   These are the values that minimise the mean squared error.

    numpts = size(x,1);
    if numpts==0
        r = [0 0 0];
        u1 = zeros(0,3);
        resid = 0;
        resid1 = 0;
        return;
    end
    
    resid = sum(sum(u.*u))/numpts;
    ubar = sum(u,1)/numpts;
    xbar = sum(x,1)/numpts;
    udev = zeros(size(u));
    xdev = zeros(size(x));
    
    for i=1:numpts
        udev(i,:) = u(i,:) - ubar;
        xdev(i,:) = x(i,:) - xbar;
    end
    xu = sum( cross(x,u,2), 1 );
    mx = crosscross( x, x );
    mxm = numpts * crosscross( xbar, xbar );
    mx  = mx - mxm;
    xum = numpts * cross( xbar, ubar );
    xu = xu - xum;
    r = xu*inv(mx);
    ru = zeros(size(x));
    for i=1:numpts
        ru(i,:) = cross(r,x(i,:));
    end
    c = ubar - cross(r,xbar);
    u1 = u - ru - ones(numpts,1)*c;
    resid1 = sum(sum(u1.*u1))/numpts;
end

function m = crosscross( a, b )
    m = zeros(size(a,2));
    for i=1:size(a,1)
        m = m + a(i,:)'*b(i,:);
    end
    v = sum( dot(a,b,2), 1 );
    m = diag([v,v,v])-m;
end

