function v = projectTensorsToDirection( d, t )
%v = projectTensorsToDirections( direction, tensors )
%   Given a vector DIRECTION and a set of symmetric tensors T of the same
%   dimensionality (2 or 3), calculate the "value" of each tensor in that
%   direction.  If the tensors are rate-of-growth tensors, this is the rate
%   of growth in that direction.
%
%   The N tensors are expected to be supplied in the form of an N*3 matrix
%   (for two dimensions) or an N*6 matrix (for three dimensions), each row
%   being a vector representation of a symmetric matrix:
%       [a b c]       represents the matrix [a c]
%                                           [c b]
%       [a b c d e f] represents the matrix [a f e]
%                                           [f b d]
%                                           [e d c]
%
%   The result is an N*1 vector.

    d = d(:)/norm(d);
    if length(d)==2
        x = d(1);
        y = d(2);
        v = x*(x*t(:,1) + y*t(:,3)) + ...
            y*(x*t(:,3) + y*t(:,2));
    else
        x = d(1);
        y = d(2);
        z = d(3);
        v = x*(x*t(:,1) + y*t(:,6) + z*t(:,5)) + ...
            y*(x*t(:,6) + y*t(:,2) + z*t(:,4)) + ...
            z*(x*t(:,5) + y*t(:,4) + z*t(:,3));
    end
end
