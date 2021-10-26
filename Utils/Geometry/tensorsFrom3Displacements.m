function [G,J] = tensorsFrom3Displacements( vxs, d )
%tensorsFrom3Displacements( vxs, d )
%   vxs in an array of three row vectors, being points in 3D space.
%   d is a set of displacements of these points.
%   G is set to a pair [g1,g2] of the principal growth components of the
%   displacements, and J is a frame whose first two axes are the principal
%   directions of growth and whose third is perpendicular to the triangle.

    av = sum(vxs,1)/3;
    vxs = vxs - repmat(av,3,1);
    avd = sum(d,1)/3;
    d = d - repmat(avd,3,1);
    
    [m,t] = fitmat( vxs, vxs+d )
    
    vv = vxs'*vxs
    vd = vxs'*d
    [vv2,d2] = eig(vv);
    vv2 = vv2(:,[3 2])
    d2 = d2([3 2],[3 2])
    vv2*d2
    
    vv\vd
end
