function J = makebasis( v1, v2 )
%J = makebasis( v1, v2 )    Set J to an orthonormal matrix whose column
%vectors j1, j2, j3 are given by:
%    j1 is parallel to v1.
%    j2 is in the plane of v1 and v2, and has a positive dot product with
%    v2.
%    [j1 j2 j3] is a right-handed basis.
% v1 and v2 must be linearly independent non-zero three-element row vectors.
% If v2 is not supplied, or if v2 is parallel to v1 or very nearly so, an
% arbitrary vector perpendicular to v1 will be chosen.
% If neither v1 nor v2 are supplied, or if only v1 is supplied but it is
% all zeros, the identity matrix is returned.

    if nargin < 1
        J = eye(3);
        return;
    end
    
    i1 = find(v1 ~= 0, 1);
    if nargin < 2
        i2 = [];
    else
        i2 = find(v2 ~= 0, 1);
    end
    
    have1 = ~isempty(i1);
    have2 = ~isempty(i2);
    
    if ~have1 && ~have2
        J = eye(3);
        return;
    end
    
    if have1
        J1 = v1/norm(v1);
        if have2
            J2 = v2 - J1*dotproc2(v2,J1);
            if all(J2==0)
                J2 = findPerp( v1 );
            end
        else
            J2 = findPerp( v1 );
        end
        J2 = J2/norm(J2);
    else
        J2 = v2/norm(v2);
        J1 = findPerp( v2 );
        J1 = J1/norm(J1);
    end
        
    J3 = crossproc2( J1, J2 );
    J = [ J1', J2', J3' ];
end

function w = findPerp( v )
    [~,i] = max(abs(v));
    j = i+1;  if j==4, j = 1; end
    w = [0,0,0];
    w(i) = v(j);
    w(j) = -v(i);
end