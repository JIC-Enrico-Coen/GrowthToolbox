function a = triangleAngle( tri )
%a = triangleAngles( tri )
%   TRI is a 3*3 matrix of row vectors, the vertexes of a triangle.
%   A is set to the angle at the first vertex.
%   If you want all three angles, use triangleAngles.

    edges = tri([2 3 1],:) - tri([3 1 2],:);
    edgsqs = sum( edges.*edges, 2 );
    if edgsqs(1)==0
        a = 0;
    elseif edgsqs(2)==0
        a = pi/2;
    elseif edgsqs(3)==0
        a = pi/2;
    else
        numer = edgsqs(2) + edgsqs(3) - edgsqs(1);
        denom = prod(sqrt(edgsqs([2 3])));
        a = acos( (numer/denom)/2 );
    end
end
