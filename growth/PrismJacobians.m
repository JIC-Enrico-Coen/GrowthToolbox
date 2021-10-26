function j = PrismJacobians( v, p )
%j = PrismJacobians( v, p )    Calculate the Jacobian of the
%    transformation from p = (xi;eta;zeta) to (x,y,z) for a triangular
%    prism with vertices v.
%    v is 3*6, each point being a column of v.
%    p may be a 3*n array: a Jacobian will be computed for each column of
%    p, and J will be a 3*3*n array.
%    If v is 3*6*m, J will be a 3*3*nm array.

% (x,y,z) = SUM[i:1..6]( Ni vi )
%         = ((1-zeta)/2) * (v1(1-xi-eta) + v2*xi + v3*eta)
%           + ((1+zeta)/2) * (v4(1-xi-eta) + v5*xi + v6*eta)

  % numCells = size(v,3);
  % if numCells > 1
  %     p = repmat( p, 1, numCells );
  % end
  
  % global gXI gETA gZETA;
    if false
        xi = gXI;
        eta = gETA;
        zeta = gZETA;
    else
        xi = p(1,:);
        eta = p(2,:);
        zeta = p(3,:);
    end
    z1 = (1-zeta)/2;
    z2 = (1+zeta)/2;
    xieta = (1 - xi - eta)/2;
    vv = v(:,[2,5,3,6,4,5,6]) - v(:,[1,4,1,4,1,2,3]);
    j(:,3,:) = vv(:,5)*xieta + vv(:,6)*(xi/2) + vv(:,7)*(eta/2);
    j(:,2,:) = vv(:,3)*z1 + vv(:,4)*z2;
    j(:,1,:) = vv(:,1)*z1 + vv(:,2)*z2;
end
