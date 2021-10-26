function t = triangleTransform( vxs1, vxs2, growthonly )
%t = triangleTransform( vxs1, vxs2, growthonly )
%   Find the affine transformation that maps the triangle vxs1 to the
%   triangle vxs2, both being 3*2 matrices representing three points in the
%   plane.  The transformation t is a 3*2 matrix satisfying
%   [ vxs1, [1; 1; 1] ]*t = vxs2.  It exists and is unique unless the
%   points vxs1 are collinear.
%   If growthonly is true (default false) then the translationsl and
%   rotational parts of t will be removed and t returned as a 2*2 symmetric
%   matrix.

    t = inv( [ vxs1, [1; 1; 1] ] ) * vxs2;
    
    if (nargin==3) && growthonly
        theta = atan2( t(2,1)-t(1,2), t(1,1)+t(2,2) );
        c = cos(theta);
        s = sin(theta);
        r = [c s;-s c];
        t = t([1 2],:)*r;
    end
end
