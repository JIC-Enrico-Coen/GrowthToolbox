function a = localDirection( vxs, v )
%a = localDirection( vxs, v )
%   VXS is a matrix of 3 row vectors.  V is a row vector.
%   A will be set to a vector such that A*VXS is as close as possible to V
%   while satisfying SUM(A) = 0.  For this to be useful, V should be
%   roughly in the plane of the three vertexes VXS.
%
%   V can be an N*3 matrix of vectors, and an N*3 matrix will be returend
%   for A.


    [v1,bc] = projectPointToPlane( vxs, v+repmat( vxs(1,:), size(v,1), 1 ) ); %#ok<ASGLU>
    a = [bc(:,1)-1,bc(:,2),bc(:,3)];
end