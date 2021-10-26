function gv = triInterpolate( points, v )
%gv = triInterpolate( points, v )   v is a row vector of 3 values, the values
%of some quantity at the vertexes of a triangle.  points is a 3*N matrix of
%points in barycentric coordinates.  The result is the interpolated values
%of v at those points.

    gv = v*points;
end
