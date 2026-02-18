function J3 = rotmat2To3mat( J )
%J3 = rotmat2To3mat( J )
%   Convert a 2*2 rotation matrix to 3-matrix form, suitable for rotating
%   elasticity tensors in 3-matrix form.
%
%   NEVER USED. Does not use symmetrycount, so might be wrong.

    if numel(J)==1
        c = cos(J);
        s = sin(J);
        J = [ [c -s]; [s c] ];
    end
    topleft = J .* J;
    topright = J(:,1) .* J(:,2) * 2;
    botleft = J(1,:) .* J(2,:);
    botright = ...
        J(1,1) .* J(2,2) + J(1,2) .* J(2,1);
    J3 = [
        [ topleft, topright ];
        [ botleft, botright ] ];
end

