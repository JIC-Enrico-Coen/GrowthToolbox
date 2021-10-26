function [th,X,Y,th2] = decomposedTriangleTransform( vxs, wxs )
%[th,X,Y,th2] = decomposedTriangleTransform( vxs, wxs )
%   vxs and wxs are two planar triangles given as 3*2 matrices.
%   There is a unique linear transformation which, combined with a suitable
%   translation (which we are not interested in), maps vxs to wxs.
%   This routine calculates a description of that linear transformation in
%   the form of a rotation by angle TH, followed by growth in the x and y
%   directions of X and Y respectively, followed by rotation by angle TH2.
%   The growth tensor which maps vxs to the same shape as wxs is then
%   [X 0;0 Y]*rotMatrix(th).

    % Take the vertexes relative to the first vertex, and transform to
    % column vectors for convenience.
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
    % C1 = c*M(1,2) + s*M(2,2);  % C1 should be equal to C.
        % For best accuracy, we should choose the formula whose terms have
        % the same sign, if possible, otherwise the formula having the
        % smallest maximum absolute value of its terms.
    G = [A C;C B];
    R = [c -s;s c];
    
    % Express G in the form R2*D*inv(R2) where R2 is a rotation and D is
    % diagonal.
    th2 = atan2(2*C, B-A)/2;
    c2 = cos(th2);
    s2 = sin(th2);
    R2 = [c2 -s2;s2 c2];
    D = R2*G*R2';
    X = D(1,1);
    Y = D(2,2);
    % D(1,2) and D(2,1) should be zero.
    
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

