function [newpts,newvxs] = remesh2D( pts )
%[newpts,newvxs] = remesh2D( pts, numnewvxs )
%   Divide a polygon in the plane into triangles, trying to ensure that
%   none of the triangles depart too far from equilateral.

%     n = 10;
%     x = linspace(0,1,n+1)';
%     x(end) = [];
%     pts = [ [ x, zeros(n,1) ]; ...
%             [ ones(n,1), x ]; ...
%             [ 1-x, ones(n,1) ]; ...
%             [ zeros(n,1), 1-x ] ];



    r1 = 0.8;
    r2 = 0.3;
    d = 0.1;
    nv = (r1+r2)/d + 1;
    a = linspace(0,pi/2,10)';
    a([1 end]) = [];
    sa = sin(a);
    ca = cos(a);
    pts = [ [ 1 0 ];
            [ ca, sa ];
            [ zeros( nv, 1 ), linspace( r1, -r2, nv )' ];
            [ ca(end:-1:1), -sa(end:-1:1)*r2 ] ]; 

    
    
    [newpts,newvxs] = mesh2d(pts);

%     figure(1);
%     plotpts( gca, newpts, '.', 'MarkerSize', 20 );
%     hold on
%     triplot(newvxs,newpts(:,1), newpts(:,2));
%     hold off
    return;
    
    
    
    

    numnewpts = 100;
    sz_pts = max(pts,[],1) - min(pts,[],1);
    if isempty(sz_pts)
        sz_pts = [1 1];
        centroid = [0 0];
    else
        centroid = sum(pts,1)/size(pts,1);
    end
    msz_pts = max(sz_pts);
    numallpts = size(pts,1) + numnewpts;
    extrapts = repmat( centroid, numnewpts, 1 ) + randn( numnewpts, 2 ).*repmat(sz_pts,numnewpts,1)/10;
    allpts = [ pts; extrapts ];
    figure(1);
    plotpts( gca, allpts, '.', 'MarkerSize', 20 );
    pause;
    while true
        d1 = repmat(allpts(:,1),1,numnewpts) - repmat(extrapts(:,1)',numallpts,1);
        d2 = repmat(allpts(:,2),1,numnewpts) - repmat(extrapts(:,2)',numallpts,1);
        d12 = sqrt(d1.^2 + d2.^2);
        d12 = d12/msz_pts;
        d12a = d12-0.3;
        d12r = d12a./(d12+0.1);
        f = [ sum(d1.*d12r,1); sum(d2.*d12r,1) ]';
        fmax = max(abs(f(:)));
        f = f/fmax;
        displ = f*msz_pts*0.01;
        extrapts = extrapts + displ;
        allpts = [ pts; extrapts ];
        tri = delaunay( allpts(:,1), allpts(:,2) );
        plotpts( gca, allpts, '.', 'MarkerSize', 20 );
        hold on
        triplot(tri,allpts(:,1), allpts(:,2));
        hold off
%         edges = unique( sort( [ tri(:,[1 2]); tri(:,[2,3]); tri(:,[3,1]) ], 2 ), 'rows' );
%         line( allpts(edges,1)', allpts(edges,2)' );
        % pause
    end
end
