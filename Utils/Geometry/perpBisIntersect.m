function p = perpBisIntersect( v )
%p = perpBisIntersect( v )
%   v is a 3x2 array representing a triangle in the plane.
%   Set p to the intersection of the perpendicular bisectors of the sides
%   of the triangle.

    v12 = v(2,:) - v(1,:);
    v13 = v(3,:) - v(1,:);
    p = v(1,:) + (0.5 * inv( [ v12; v13 ] ) * [ sum(v12.*v12); sum(v13.*v13) ])';
end
