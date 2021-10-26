function drawVoronoi( r )
%drawVoronoi( r )
%   Draw the Voronoi and Delaunay diagrams of the set of points R, a 2*N
%   array.
    clf;
    xvoronoi(r(1,:),r(2,:));
    hold on;
    plot(r(1,1:2:size(r,2)),r(2,1:2:size(r,2)), 'o');
    tri = delaunay(r(1,:),r(2,:));
    fill( reshape( r(1,tri'), 3, [] ), reshape( r(2,tri'), 3, [] ), 'w', 'FaceColor', 'none' );
    axis equal;
    hold off;
    drawnow;
end