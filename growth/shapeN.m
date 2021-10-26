function n = shapeN( p )
%n = shapeN( p )    Calculate the shape functions for a triangular prism
%    at isoparametric coordinates p.  p can be a column vector for a single
%    point, or a matrix with one column for each point.

% N1 = (1-xi-eta)(1-zeta)/2
% N2 = xi(1-zeta)/2
% N3 = eta(1-zeta)/2
% N4 = (1-xi-eta)(1+zeta)/2
% N5 = xi(1+zeta)/2
% N6 = eta(1+zeta)/2

    xi = p(1,:);  eta = p(2,:);  zeta = p(3,:);
    z1 = (1-zeta);  z2 = (1+zeta);  xieta = (1 - xi - eta);

    n = [ xieta.*z1; ...
          xi.*z1; ...
          eta.*z1; ...
          xieta.*z2; ...
          xi.*z2; ...
          eta.*z2 ]/2;
end

           