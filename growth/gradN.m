function gn = gradN( p )
%gn = gradN( p )    Calculate the gradient of all the
%    shape functions for a triangular prism at isoparametric
%    coordinates p.
%    p is a 3x1 column vector.
%    The result gn is a 3x6 matrix, one column for each shape function.
%    If p is a 3xN matrix, gn is a 3x6xN matrix.

% N1 = (1-xi-eta)(1-zeta)/2
% N2 = xi(1-zeta)/2
% N3 = eta(1-zeta)/2
% N4 = (1-xi-eta)(1+zeta)/2
% N5 = xi(1+zeta)/2
% N6 = eta(1+zeta)/2

    xi(1,1,:) = p(1,:);
    eta(1,1,:) = p(2,:);
    zeta(1,1,:) = p(3,:);

    z1 = (1-zeta)/2;
    z2 = (1+zeta)/2;
    xieta = (1 - xi - eta)/2;
    ze = zeros(size(z1));

    gn = [ ...
            [    -z1,    z1,     ze,   -z2,   z2,    ze ]; ...
            [    -z1,    ze,     z1,   -z2,   ze,    z2 ]; ...
            [ -xieta, -xi/2, -eta/2, xieta, xi/2, eta/2 ] ...
         ];
end
