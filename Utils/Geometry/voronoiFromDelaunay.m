function vv = voronoiFromDelaunay( v, t )
%vv = voronoiFromDelaunay( v, t )
%   Calculate the Voronoi vertexes from the Delaunay trangulation t of a
%   set of vertexes V.

    vv = zeros( size(t,1), 2 );
    for i=1:size(t,1)
        vv(i,:) = perpBisIntersect1( v(t(i,:),:) );
    end
end
