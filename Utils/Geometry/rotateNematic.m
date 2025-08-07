function nt = rotateNematic( nt, rot )
% Rotate a nematic tensor by the given rotation. This is valid in any
% number of dimensions.
%
% The rotation is assumed to operate on a vector v by v*rot, v being a row
% vector.

    nt = rot * nt * rot';
end
