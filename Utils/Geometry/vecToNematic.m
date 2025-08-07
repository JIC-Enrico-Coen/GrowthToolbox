function nt = vecToNematic( v )
%nt = vecToNematic( v )
%   Convert a vector, considered as having no forwards/backwards sense,
%   into a nematic tensor.
%
%   The procedure works for vectors in any number of dimensions.
%   The vector is assumed to be a row vector. The resulting matrix is
%   symmetric. Its trace will be equal to the length of the vector.
%
%   V can also be an N*D matrix of N row vectors. Each is converted to a
%   nematic tensor and the sum of the tensors is returned.

    nt = (v' * v)/norm(v);
end