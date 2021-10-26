function timevor( numiters, v )
    starttime = tic;
    for i=1:numiters
        t = delaunay( v(:,1), v(:,2 ) );
        vv = voronoiFromDelaunay( v, t );
    end
    toc(starttime);
    starttime = tic;
    for i=1:numiters
        t = delaunay( v(:,1), v(:,2 ) );
        [vv,cc] = voronoin( v );
    end
    toc(starttime);
end
