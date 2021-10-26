function [x,d] = invdistrib( distrib, p )
    p = reshape( p, [], 1 );
    i = binsearchall( distrib(:,3), p ) - 1;
    if i < 1, i = 1; end
    y = distrib(i,2);
    y1 = distrib(i,3);
    a = distrib(i,4);
    dx = (-y + sqrt( y.*y - 4*a.*(y1-p) ))./(2*a);
    x = dx + distrib(i,1);
    d = y + 2*a.*dx;
end
