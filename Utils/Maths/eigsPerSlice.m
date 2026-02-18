function [v,d,d2] = eigsPerSlice( A )
%[v,d,d2] = eigsPerSlice( A )
%   Like eigs(), except that A is an N x N x K array, and eigs is called
%   for each of its K slices. V will be N x N x K, containing the
%   eigenvectors. D will be N x N x K, containing the eigenvalues on its
%   diagonals. D2 will be K x N, containing the eigenvalues as its columns.
%
%[v,d] = eigsPerSlice( A )
%   As the first form, without the D2 result.
%
%d = eigsPerSlice( A )
%   This returns the eigenvalues only, as a K x N array, the same as D2 in
%   the first way of calling eigsPerSlice.
%
%See also: eigs.

    numdims = size(A,1);
    numslices = size(A,3);
    if nargout==1
        v = zeros( numdims, numslices );
        for i=1:size(A,3)
            v(:,i) = eigs( A(:,:,i) );
        end
    else
        v = zeros( numdims, numdims, numslices );
        d = zeros( numdims, numdims, numslices );
        for i=1:size(A,3)
            [v(:,:,i),d(:,:,i)] = eigs( A(:,:,i) );
        end
        if nargout >= 3
            d2 = zeros( numdims, numslices );
            for i=1:size(A,3)
                d2(:,i) = diag(d(:,:,i));
            end
        end
    end
end