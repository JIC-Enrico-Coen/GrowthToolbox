function g = trianglegradient( vertexes, values )
%g = gradient( vertexes, values )    vertexes is a 3*3 matrix of
%   vertex coordinates of a triangle, one vertex in each row.  values is a
%   vector of the values that a variable has at each of those vertexes.
%   The result is the gradient vector of that quantity over the triangle,
%   in the global frame.

% Let the vertexes be v1, v2, and v3, and the values x1, x2, and x3.
% Write v21 for v2-v1 and v31 for v3-v1.
% g must be a linear combination of v21 and v31: a*v21 + b*v31.
% To be the gradient vector it must satisfy:
%   g.v21 = x2-x1
%   g.v31 = x3-x1
% This is a pair of simultaneous linear equations in a and b, non-singular
% iff the three vertexes are non-collinear.

    v21 = vertexes( 2,: ) - vertexes( 1,: );
    v31 = vertexes( 3,: ) - vertexes( 1,: );
    d22 = dotproc2(v21,v21);
    d23 = dotproc2(v21,v31);
    d33 = dotproc2(v31,v31);
    x21 = values(2) - values(1);
    x31 = values(3) - values(1);
    det = d22*d33-d23*d23;
    if det==0
        ab = [0; 0];
    else
        ab = ([ [ d33, -d23 ]; [ -d23, d22 ] ] * [ x21; x31 ])/det;
    end
    g = ab(1)*v21 + ab(2)*v31;
end
