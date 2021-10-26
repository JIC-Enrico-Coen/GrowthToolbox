function [X,Yleft,Yright,A] = polygonArea2( vxs )
%a = polygonArea2( d, vxs )
%   Compute a representation of the area of a polygon in the XY plane cut
%   off by a line parallel to the Y axis.  The polygon vertexes are in the
%   N*2 array vxs.

    numvxs = size(vxs,1);
    xx = vxs(:,1)';
    yy = vxs(:,2)';
    
    [X,XI,XJ] = unique(xx);
    % X = xx(XI); xx = X(XJ);
    Yleft = zeros( size(X) );
    Yright = zeros( size(X) );
    for i=1:(numvxs-1)
        addedge( XJ(i), yy(i), XJ(i+1), yy(i+1) );
    end
    addedge( XJ(end), yy(end), XJ(1), yy(1) );

    stripareas = (X(2:end) - X(1:(end-1))).*(Yleft(2:end) + Yright(1:(end-1)))/2;
    A = [ 0 cumsum( stripareas ) ];
    if A(end) < 0
        A = -A;
        Yleft = -Yleft;
        Yright = -Yright;
    end

    
function addedge( i1, y1, i2, y2 )
    if i1==i2
        return;
    end
    neg = i2 < i1;
    if neg
        temp = i1;  i1 = i2;  i2 = temp;
        temp = y1;  y1 = y2;  y2 = temp;
    else
        y1 = -y1;
        y2 = -y2;
    end
    x1 = X(i1);
    x2 = X(i2);
  % fprintf( 1, 'addedge( %f, %f, %f, %f )\n', x1, y1, x2, y2 );
    a = (y2-y1)/(x2-x1);
    b = y1 - x1*a;
    dy = a*X(i1:i2) + b;
    Yleft((i1+1):i2) = Yleft((i1+1):i2) + dy(2:end);
    Yright(i1:(i2-1)) = Yright(i1:(i2-1)) + dy(1:(end-1));
end

end
