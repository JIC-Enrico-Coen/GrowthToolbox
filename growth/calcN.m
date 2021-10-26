function vn = calcN( p )
%vn = calcN( p )    Calculate the value of all the
%    shape functions for a triangular prism at isoparametric
%    coordinates p.  The result is a row vector.
%    p is a 3-element column vector.  It may also be a 3*N matrix, in which
%    case the result will be a 6*N matrix.

% N1 = (1-xi-eta)(1-zeta)/2
% N2 = xi(1-zeta)/2
% N3 = eta(1-zeta)/2
% N4 = (1-xi-eta)(1+zeta)/2
% N5 = xi(1+zeta)/2
% N6 = eta(1+zeta)/2

    xi = p(1,:);  eta = p(2,:);  zeta = p(3,:);
    z1 = (1-zeta)/2;  z2 = (1+zeta)/2;  xieta = (1 - xi - eta);
    
    vn = [ xieta.*z1; xi.*z1; eta.*z1; xieta.*z2; xi.*z2; eta.*z2 ];
end
