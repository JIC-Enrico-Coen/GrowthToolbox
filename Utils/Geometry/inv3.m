function q = inv3( p )
%q = inv3( p )
%   Compute the inverse of a 3*3 matrix.
%   If the matrix is singular, return the zero matrix and give a warning.

    a = p(1,1);  b = p(1,2);  c = p(1,3);
    d = p(2,1);  e = p(2,2);  f = p(2,3);
    g = p(3,1);  h = p(3,2);  j = p(3,3);
    a1 = e*j-f*h;  b1 = f*g-d*j;  c1 = d*h-e*g;
    d1 = c*h-b*j;  e1 = a*j-c*g;  f1 = b*g-a*h;
    g1 = b*f-e*c;  h1 = c*d-a*f;  j1 = a*e-b*d;
    det = a*a1 + b*b1 + c*c1;
    det2 = d*d1 + e*e1 + f*f1;
    det3 = g*g1 + h*h1 + j*j1;
    if det==0
        det
        det2
        det3
        p
    end
    q = [ [ a1 d1 g1 ];
          [ b1 e1 h1 ];
          [ c1 f1 j1 ] ] / det;
end
