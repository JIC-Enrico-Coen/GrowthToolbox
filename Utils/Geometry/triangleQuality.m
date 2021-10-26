function q = triangleQuality( pts )
%q = triangleQuality( pts )
%   Compute a measure of the quality of the triangular FEM element whose
%   vertexes are the rows of pts.  The measure is the ratio of twice the
%   triangle area to the square of its longest side.  Equivalently, it is
%   the ratio of the altitude to the longest side.  The maximum possible
%   value is sqrt(3)/2 = 0.866.  

    vecs = pts - pts([2,3,1],:);       % Edge vectors.
    lensq = sum( vecs.*vecs, 2 );      % Squared lengths of the edges.
    maxlensq = max(lensq);             % Find longest edge.
    c12 = cross(vecs(1,:),vecs(2,:));  % The length of this vector is twice
                                       % the area of the triangle.
    q = sqrt(c12*c12')/maxlensq;
end
