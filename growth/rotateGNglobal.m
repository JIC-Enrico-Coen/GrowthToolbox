function g = rotateGNglobal( g, R )
%g = rotateGNglobal( g, R )
%   g is a set of 36 vectors as a 3*6*6 matrix, as returned by
%   computeCellGNGlobal.  R is a 3*3 rotation matrix.  This procedure
%   rotates all the vectors in g by R.
% NEVER USED.

    for i=1:size(g,3)
        g(:,:,i) = R*g(:,:,i);
    end
end
