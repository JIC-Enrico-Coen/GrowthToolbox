function p = perpBisIntersect1( v )
%p = perpBisIntersect1( v )
%   v is a 3x2 array representing a triangle in the plane.
%   Set p to the intersection of the perpendicular bisectors of the sides
%   of the triangle.

    v12x = v(2,1)-v(1,1);
    v12y = v(2,2)-v(1,2);
    v13x = v(3,1)-v(1,1);
    v13y = v(3,2)-v(1,2);
    d = 2 * (v12x*v13y - v12y*v13x);
    v12s = (v12x*v12x + v12y*v12y) / d;
    v13s = (v13x*v13x + v13y*v13y) / d;
    if d==0
        p(1) = Inf;
        p(2) = Inf;
    else
        p(1) = v(1,1) + v12s * v13y - v13s * v12y;
        p(2) = v(1,2) - v12s * v13x + v13s * v12x;
    end

% Equivalent computation, more clearly laid out but 5 times slower.
%    v12 = v(2,:) - v(1,:);
%    v13 = v(3,:) - v(1,:);
%    v12s = sum(v12.*v12);
%    v13s = sum(v13.*v13);
%    p = v(1,:) + (0.5 * inv( [ v12; v13 ] ) * [ sum(v12.*v12); sum(v13.*v13) ])'; 
end
