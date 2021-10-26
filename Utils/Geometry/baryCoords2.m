function bc2 = baryCoords2( v1, v2, v )
%bc2 = baryCoords2( v1, v2, v )
%   Set bc2 to [a,b], where a+b = 1 and v = a*v1 + b*v2.
%   v1, v2, and v must be row vectors, and the result is a 2-element row vector.
%   v can be a matrix of row vectors; the result will then be a matrix of
%   2-element row vectors.
%   v1 and v2 must be distinct.  A divide by zero error will result if not.
%   v is assumed to be collinear with v1 and v2, but no check is made and
%   no errors are produced.  The resulting values a and b will always satisfy
%   a+b = 1.  If v is not collinear with v1 and v2, the point a*v1 + b*v2
%   will be the closest point to v on the line through v1 and v2.
%   This procedure works in any number of dimensions.

    v12 = v2-v1;
    d1 = dotproc2(v1,v12);
    d2 = dotproc2(v2,v12);
    d = v*v12';
    a = (d2-d)/(d2-d1);
    b = 1-a; % (d-d1)/(d2-d1);
    bc2 = [ a, b ];
end