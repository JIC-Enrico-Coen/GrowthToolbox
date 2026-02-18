function J6 = rotmatTo6mat4( J )
%J6 = rotmatTo6mat4( J )
%   Convert a 3*3 rotation matrix to 6-matrix form, suitable for rotating
%   elasticity tensors in 6-matrix form.
%
%   The following two expressions should give identical results (apart from
%   rounding error), where s is a symmetric 3*3 matrix and m is a 3*3
%   rotation matrix:
%
%       make6vector( s ) * rotmatTo6mat4( m )
%       make6vector( m' * s * m )
%
%   In fact, they give identical results when m is any 3*3 matrix, although
%   the interpretation of m'*s*m as a transformation of a symmetric tensor
%   no longer applies.
%
%   NEVER USED. Does not use symmetrycount, so might be wrong.

    topleft = J .* J;
    rot2 = [ 2, 3, 1 ];
    rot3 = [ 3, 1, 2 ];
    hrotJ2 = J(:,rot2);
    hrotJ3 = J(:,rot3);
    vrotJ2 = J(rot2,:);
    vrotJ3 = J(rot3,:);
    topright = hrotJ2 .* hrotJ3 * 2;
    botleft = vrotJ2 .* vrotJ3;
    botright = ...
        J(rot2,rot2) .* J(rot3,rot3) + J(rot2,rot3) .* J(rot3,rot2);
    J6 = [
        [ topleft, topright ];
        [ botleft, botright ] ];
end

