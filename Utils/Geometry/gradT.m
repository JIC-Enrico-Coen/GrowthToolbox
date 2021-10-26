function gt = gradT( vxs )
%gt = gradT( vxs )
%   Given a matrix vxs whose three rows are the corners of a triangle,
%   calculate a tensor gt such that for any three-element row vector f
%   defining a scalar value at each corner of the triangle, the gradient
%   vector of f (assumed linearly interpolated over the triangle) is
%   f * gt * vxs.
%   gt is a 3*3 symmetric matrix whose rows and columns sum to zero.

    x1 = vxs(1,:);
    x2 = vxs(2,:);
    x3 = vxs(3,:);
    x21 = x2-x1;
    x13 = x1-x3;
    x32 = x3-x2;
    x21sq = dot(x21,x21);
    x13sq = dot(x13,x13);
    x32sq = dot(x32,x32);
    x2113 = dot(x21,x13);
    x2113sq = dot(x2113,x2113);
    det = x21sq*x13sq - x2113sq;
    
    gf11 = x32sq/det;
    gf12 = dot(x13,x32)/det;
    gf13 = -gf11-gf12; % dot(x21,x32)/det;

    gf21 = gf12; % dot(x32,x13)/det % (-x13sq - x2113)/det
    gf22 = x13sq/det;
    gf23 = -gf21 - gf22; % dot(x21,x13)/det;
    
    gf31 = gf13; % (-x2113 - x21sq)/det
    gf32 = gf23;
    gf33 = -gf31 - gf32; % x21sq/det;
    
    gt = [ [ gf11, gf12, gf13 ]; ...
           [ gf21, gf22, gf23 ]; ...
           [ gf31, gf32, gf33 ] ];
end
