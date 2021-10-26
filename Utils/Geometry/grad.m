function gf = grad( vxs, f )
%gf = grad( vxs, f )
%   Given a matrix vxs whose three rows are the corners of a triangle, and
%   a three-element row vector f giving the value of a scalar quantity at
%   each corner, determine the gradient of f, assuming it to be parallel to
%   the plane of the triangle.
%   f may validly have K rows, in which case the calculation is
%   performed for each row and the result is a K*3 matrix.

    gf = f * gradOp(vxs);
end
