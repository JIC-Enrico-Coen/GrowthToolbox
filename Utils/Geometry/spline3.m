function x = spline3( x0, x1, x2, x3, alpha )
%x = spline3( x0, x1, x2, x3, alpha )
%   Interpolate a cubic spline through the four points, which may be in
%   space of any number of dimensions.  The spline will pass through the
%   four points at alpha = -1, 0, 1, and 2 respectively.
%   If x0...x3 are row vectors and alpha is a column vector then x will be
%   a matrix of row vectors; and vice versa.

    a0 = (alpha+1)/3;
    a1 = a0 - 1/3;
    a2 = a0 - 2/3;
    a3 = a0 - 1;
    p0 = a1.*a2.*a3*(-9/2);
    p1 = a0.*a2.*a3*(27/2);
    p2 = a0.*a1.*a3*(-27/2);
    p3 = a0.*a1.*a2*(9/2);
    if size(alpha,1)==1
        x = x0*p0 + x1*p1 + x2*p2 + x3*p3;
    else
        x = p0*x0 + p1*x1 + p2*x2 + p3*x3;
    end
    if 0
        plot(x(1,:),x(2,:));
        hold on;
        plot( [x0(1),x1(1),x2(1),x3(1)], [x0(2),x1(2),x2(2),x3(2)], 'o' );
        plot( alpha, p0, '--r' );
        plot( alpha, p1, '--g' );
        plot( alpha, p2, '--b' );
        plot( alpha, p3, '--k' );
        hold off;
    end
end
