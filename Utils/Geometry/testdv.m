function testdv( v )

    t = delaunay( v(:,1), v(:,2) );
    e = edgemap( t );
    vvp = voronoiFromDelaunay( v, t );
    t = [ t, t(:,1) ];
    [vv,cc] = voronoin( v );
    [ vvp, vv(2:size(vv,1),:) ]
    return;
    vv0 = vv(2:size(vv,1),:);
    el = edgelengths( e, vv0 );
    vv00 = vv0 + rand(size(vv0))*0.01;
    el0 = edgelengths( e, vv00 );
    el0-el
    if 1
        figure;
        hold on;
        axis equal
        for i=1:length(el)
            fprintf( 1, '%.3f\n', el(i) );
            plot( vv0( e(i,:), 1 ), vv0( e(i,:), 2 ), '-' );
            pause
        end
        hold off;
    end
    if 0
        figure;
        hold on;
        minvals = min([vv(2:size(vv,1),:);v],[],1);
        maxvals = max([vv(2:size(vv,1),:);v],[],1);
        axis( [minvals(1) maxvals(1) minvals(2) maxvals(2)] );
        axis equal;
        for i=1:size(t,1)
            plot( vv(i+1,1), vv(i+1,2), 'ro' );
            plot( v(t(i,:),1), v(t(i,:),2), 'b-' );
            p = perpBisIntersect1( v(t(i,:),:) );
            plot( p(1), p(2), 'g.' );
            pause;
        end
        voronoi( v(:,1), v(:,2) );
        hold off;
    end
    
    figure;
    hold on;
    axis equal;
    plot( vv(2:size(vv,1),1), vv(2:size(vv,1),2), 'ro' );
    plot( v(:,1), v(:,2), 'bo' );
        for i=1:size(t,1)
            plot( v(t(i,:),1), v(t(i,:),2), 'b-' );
        end
    voronoi( v(:,1), v(:,2) );
    
    hold off;
end

function e = edgemap( t )
    nt = size(t,1);
    emap = zeros( nt );
    for i=1:nt-1
        for j=i+1:nt
            if length(unique( [ t(i,:) t(j,:) ] ) )==4
                emap(i,j) = 1;
            end
        end
    end
    [ei,ej] = find(emap);
    e = [ei,ej];
end

function el = edgelengths( e, vv )
    el = zeros(size(e,1),1);
    for i=1:size(e,1)
        el(i) = norm(vv(e(i,1),:) - vv(e(i,2),:));
    end
end
