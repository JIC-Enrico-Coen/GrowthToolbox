function r = quatToMatrix( q )
%r = quatToMatrix( q )
%   Convert a quaternion (x,y,z,w) to a rotation column matrix.
%   The quaternion must be a 4-element row vector, with the phase component
%   last.  It can also be an N*4 matrix, in which case the result is a
%   3*3*N array.
%   The quaternions are not checked for being normalised.  If the norm is
%   k, the result will be a rotation matrix multipled by k^2.

    numvecs = size(q,1);
    vectorised = numvecs >= 5;
    if vectorised
        qsq = q.^2;
        q12 = q(:,1).*q(:,2);
        q13 = q(:,1).*q(:,3);
        q14 = q(:,1).*q(:,4);
        q23 = q(:,2).*q(:,3);
        q24 = q(:,2).*q(:,4);
        q34 = q(:,3).*q(:,4);

        r12 = q12-q34;
        r21 = q12+q34;
        r13 = q13+q24;
        r31 = q13-q24;
        r23 = q23-q14;
        r32 = q23+q14;

        r = reshape( [ qsq(:,1)-qsq(:,2)-qsq(:,3)+qsq(:,4), ...
          2*[r21, r31, r12], ...
          qsq(:,2)-qsq(:,3)-qsq(:,1)+qsq(:,4), ...
          2*[r32, r13, r23], ...
          qsq(:,3)-qsq(:,1)-qsq(:,2)+qsq(:,4) ]', 3, 3, [] );
    else
        r = zeros(3,3,numvecs);
        for i=1:numvecs
            qq = q(i,:)'*q(i,:);
            r(:,:,i) = [ qq(1,1)-qq(2,2)-qq(3,3)+qq(4,4), 2*(qq(1,2) - qq(4,3)),   2*(qq(1,3) + qq(4,2)); ...
                  2*(qq(2,1) + qq(4,3)),   qq(2,2)-qq(3,3)-qq(1,1)+qq(4,4), 2*(qq(2,3) - qq(4,1)); ...
                  2*(qq(3,1) - qq(4,2)),   2*(qq(3,2) + qq(4,1)),   qq(3,3)-qq(1,1)-qq(2,2)+qq(4,4)      ];
        end
    end
end
