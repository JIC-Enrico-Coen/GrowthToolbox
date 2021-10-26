function j = PrismJacobian( v, p )
%j = PrismJacobian( v, p )    Calculate the Jacobian of the
%    transformation from p = (xi,eta,zeta) to (x,y,z) for a triangular
%    prism with vertices v.
%    v is 3*6, each point being a column of v.

% (x,y,z) = SUM[i:1..6]( Ni vi )
%         = ((1-zeta)/2) * (v1(1-xi-eta) + v2*xi + v3*eta)
%           + ((1+zeta)/2) * (v4(1-xi-eta) + v5*xi + v6*eta)

    xi = p(1);
    eta = p(2);
    zeta = p(3);
    z1 = (1-zeta)/2;
    z2 = (1+zeta)/2;
    xieta = (1 - xi - eta)/2;
    if 0
        % This is slightly slower
        vv = v(:,[2,5,3,6,4,5,6]) - v(:,[1,4,1,4,1,2,3]);
        j = [ ...
                z1*vv(:,1) + z2*vv(:,2), ...
                z1*vv(:,3) + z2*vv(:,4), ...
                xieta*vv(:,5) + ...
                    (xi/2)*vv(:,6) + (eta/2)*vv(:,7)
            ];
    else
        % Writing out all of the elements of the following is slower than
        % using v(:,...).
        j = [ ...
                z1*(v(:,2)-v(:,1)) + z2*(v(:,5)-v(:,4)), ...
                z1*(v(:,3)-v(:,1)) + z2*(v(:,6)-v(:,4)), ...
                xieta*(v(:,4)-v(:,1)) + ...
                    (xi/2)*(v(:,5)-v(:,2)) + (eta/2)*(v(:,6)-v(:,3))
            ];
    end
    % fprintf( 1, 'PrismJacobian detJ %g\n', det(j) );
end
