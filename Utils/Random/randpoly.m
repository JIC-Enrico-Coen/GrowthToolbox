function pts = randpoly( distrib, n )
    px = rand(n,1) * distrib( size(distrib,1), 3 );
    i = binsearchall( distrib(:,3), px ) - 1;
    if i < 1, i = 1; end
    y0 = distrib(i,2);
    y1 = distrib(i,3);
    a = distrib(i,4);
    dxa = (-y0 + sqrt( y0.*y0 - 4*a.*(y1-px) ))/2;
    for j=1:length(a)
        if a(j)==0
            dx(j,1) = (px(j)-y1(j))/y0(j);
        else
            dx(j,1) = dxa(j)/a(j);
        end
    end
    pts(:,1) = dx + distrib(i,1);
    py = rand(n,1);
    xinterval = distrib(i+1,1) - distrib(i,1);
    intervalfraction = dx ./ xinterval;
    ylo = interp( distrib(i,5), distrib(i+1,5), intervalfraction );
    yhi = interp( distrib(i,6), distrib(i+1,6), intervalfraction );
    pts(:,2) = interp( ylo, yhi, py );
end

function x = interp( x0, x1, p )
    x = x0 + p.*(x1-x0);
end
