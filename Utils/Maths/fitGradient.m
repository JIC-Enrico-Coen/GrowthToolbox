function [g,c,e] = fitGradient( x, p )
%[g,c,e] = fitGradient( x, p )
%   Given a set of N points in D-dimensional space x (N*D), and a value p
%   at each point (N*1), find the vector g (1*D) that best approximates the
%   gradient of a linear scalar field.  This requires that the points not
%   lie in any linear proper subspace.

%   We are trying to approximate p by x*g' + c, where g is the gradient and
%   c is an offset.  The error e is p - (x-xmean)g - c;

    npts = length(p);
    xmean = sum(x,1)/npts;
    x1 = x - repmat(xmean,npts,1);
    xproducts = x1' * x1;
    px = p' * x1;
    g = px/xproducts;
    if nargout >= 2
        c = (sum(p) - sum(sum( x1 .* repmat(g,npts,1), 2 )))/npts - sum(g.*xmean);
        if nargout >= 3
            e = p - sum( x .* repmat(g,npts,1), 2 ) - c;
            e = sqrt( sum( e(:).^2 )/npts );
        end
    end
end
