function go = gradOp( vxs )
%go = gradOp( vxs )
%   Given a matrix vxs whose three rows are the corners of a triangle,
%   determine a 3*3 matrix go such that for any 3-element row vector f,
%   f*go is the gradient of the linear interpolation of f over the
%   triangle.

    go = gradT(vxs) * vxs;
end
