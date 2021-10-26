function testpoly()
    poly = [ [0 0];[2 -1];[2.5 1];[4 0.5];[3 2]; [1.5 -0.5];[1 0]];
  % poly = [ [0 0];[1 0];[3 1]];
    numpts = size(poly,1);
    distrib = polygonDistrib( poly );
    plotdistrib( distrib );
    hold on;
    plot(poly([ 1:numpts, 1 ],1),poly([ 1:numpts, 1 ],2));
    for i=1:100
        pts = randpoly( distrib, 100 );
        plot(pts(:,1),pts(:,2),'o');
        drawnow;
    end
    hold off;
end

function plotdistrib( distrib )
    numpts = 1000;
    xmin = distrib(1,1);
    xmax = distrib( size(distrib,1), 1 );
    dx = (xmax-xmin)/numpts;
    xs = xmin:dx:xmax;
    ys = [];
    for x = xmin:dx:xmax;
        ys(length(ys)+1) = calcdistrib( distrib, x );
    end
    plot(xs,ys);
end

function testdistrib( distrib )
    for i=1:size(distrib,1)-1
        y = calcdistrib( distrib, distrib(i+1,1) );
        y = distrib(i,3) + distrib(i,2)*dx + distrib(i,4)*dx*dx;
    end
end
