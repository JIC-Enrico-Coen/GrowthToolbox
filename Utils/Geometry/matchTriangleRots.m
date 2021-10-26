function [thv,thw] = matchTriangleRots( vxs, wxs )
%[thv,thw] = matchTriangleRots( vxs, wxs )
%   vxs and wxs are two planar triangles given as 3*2 matrices.
%   Calculate the direction angles thv and thw of unit vectors dv and dw,
%   such that when the triangles are both projected onto the respective
%   lines, their vertices lie in the same order and divide the line in the
%   same ratio; and such that this is also true for projection onto the
%   perpendiculars to the lines.  The difference between the two angles is
%   then the rotation that, followed by a non-isotropic expansion, maps
%   vxw onto wxs.

    thv = 0;
    thw = 0;
    
    % Take the vertexes relative to the first vertex.
    v2 = (vxs(2,:)-vxs(1,:))';
    v3 = (vxs(3,:)-vxs(1,:))';
    w2 = (wxs(2,:)-wxs(1,:))';
    w3 = (wxs(3,:)-wxs(1,:))';
    
    % Compute the linear transformation mapping v2 and v3 to w2 and w3.
    M = [w2 w3] * inv( [v2 v3] );
    
    % Express M in the form R*G where R is a rotation and G is symmetric.
    th = atan2( M(2,1) - M(1,2), M(1,1) + M(2,2) );
    c = cos(th);
    s = sin(th);
    A = c*M(1,1) + s*M(2,1);
    B = c*M(2,2) - s*M(1,2);
    C = c*M(2,1) - s*M(1,1);
    C1 = c*M(1,2) + s*M(2,2);
    G = [A C;C B];
    R = [c -s;s c];
    
    % Express G in the form R2*D*inv(R2) where R2 is a rotation and D is
    % diagonal.
    th2 = atan2(2*C, B-A)/2;
    c2 = cos(th2);
    s2 = sin(th2);
    R2 = [c2 -s2;s2 c2];
    D = R2*G*R2';
    
    % Verify
  % Mcheck = R*R2'*D*R2 - M  % Should be zero matrix.
    
    % This is a decomposition of the linear transformation M into:
    %   a rotation by th2
    %   followed by growth parallel to the x and y axes
    %   a rotation by th-th2.
    % vxs is therefore transformed to wxs by:
    %   translating by -vxs(1,:)
    %   applying M
    %   translating by wxs(1,:)
end

