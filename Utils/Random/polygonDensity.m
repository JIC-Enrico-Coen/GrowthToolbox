function dens = polygonDensity( poly )
%dens = polygonDensity( poly )
%   Construct a density function from a convex polygon.
%   The density function is continuous and piecewise linear.  It is
%   represented as an N*4 array. dens(:,1) is the series of x values in
%   increasing order.  dens(:,2) is the density function at x.  dens(:,3)
%   and dens(4,:) are the y coordinates of the intersections of the line
%   parallel to the y-axis at x with the polygon.
    
    % 1.  Find the vertexes corresponding to minimum and maximum x.
    % 2.  Iterate through the vertices of the upper and lower halves of the
    % polygon, constructing the density function.
    
    [xmin,xmini] = min( poly(:,1) );
    if xmini==1
        [xmax,xmaxi] = max( poly(:,1) );
        poly = rotpoly( poly, xmaxi );
        xmaxi = 1;
        xmaxi2 = findinterval( poly, xmaxi );
        [xmin,xmini] = min( poly(:,1) );
        xmini2 = findinterval( poly, xmini );
        upperRange = xmini:-1:xmaxi2;
        lowerRange = [ xmini2:size(poly,1), 1 ];
    else
        poly = rotpoly( poly, xmini );
        xmini = 1;
        xmini2 = findinterval( poly, xmini );
        [xmax,xmaxi] = max( poly(:,1) );
        xmaxi2 = findinterval( poly, xmaxi );
        upperRange = [ 1, size(poly,1):-1:xmaxi2 ];
        lowerRange = xmini2:xmaxi;
    end
    upperdata = poly(upperRange,:);
    lowerdata = poly(lowerRange,:);
    x = [];
    y1 = [];
    y2 = [];
    xi = 1;
    x(xi) = xmin;
    loweri = 1;
    y1(loweri) = lowerdata(1,2);
    upperi = 1;
    y2(upperi) = upperdata(1,2);
    while (loweri < size(lowerdata,1)) && (upperi < size(upperdata,1))
        x1a = lowerdata(loweri+1,1);
        x2a = upperdata(upperi+1,1);
        xi = xi+1;
        if x1a < x2a
            x(xi) = x1a;
            y1(xi) = lowerdata(loweri+1,2);
            y2(xi) = interp( upperdata(upperi,2), upperdata(upperi+1,2), ...
                             upperdata(upperi,1), upperdata(upperi+1,1), ...
                             x1a );
            loweri = loweri+1;
        else
            x(xi) = x2a;
            y2(xi) = upperdata(upperi+1,2);
            y1(xi) = interp( lowerdata(loweri,2), lowerdata(loweri+1,2), ...
                             lowerdata(loweri,1), lowerdata(loweri+1,1), ...
                             x2a );
            upperi = upperi+1;
        end
    end
    dens = [x' (y2-y1)' y1' y2' ];
end

function poly = rotpoly( poly, i )
    poly = [ poly( i:size(poly,1), : ); poly( 1:i-1, : ) ];
end

function j = findinterval( poly, i )
    j = i+1;
    numpts = size(poly,1);
    while (j < numpts) && (poly(j,1)==poly(i,1))
        j = j + 1;
    end
    j = j - 1;
end

function y = interp( y1, y2, x1, x2, x )
%    if x2==x1
%        y = y2;
%    else
        y = y1 + (y2-y1).*(x-x1)./(x2-x1);
%    end
end

function xy = mergelists( x, y )
    xy = [];
    xi = 1;
    yi = 1;
    xyi = 1;
    while 1
        if x(xi) < y(yi)
            xy(xyi,:) = x(xi,:);
            if xi==size(x,1)
                xy = [ xy; y(yi<size(y,1),:) ];
                break;
            end
            xi = xi+1;
        else
            xy(xyi,:) = y(yi,:);
            if yi==size(y,1)
                xy = [ xy; x(xi<size(x,1),:) ];
                break;
            end
            yi = yi+1;
        end
        xyi = xyi+1;
    end
end


