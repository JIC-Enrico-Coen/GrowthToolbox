function nts = vecsToNematics( vs )
%nts = vecsToNematic( vs )
%   Convert a set of vectors into nematic tensors.
%
%   V is N*D, where D is 2 or 3. NTS will be D * D * N.
%
%   See also: vecToNematic

    v1 = permute( vs, [3 2 1] );
    v2 = permute( vs, [2 3 1] );
    nts = v1 .* v2;
    norms = reshape( sqrt(sum(vs.^2,2)), 1, 1, [] );
    nts = nts ./ norms;
    % Where norms is zero, the above computation sets nts(:,:,...) to NaN.
    % The correct value is zero.
    nts(:,:,norms==0) = 0;

%     dims = size(vs,2);
%     numvecs = size(vs,1);
%     nts = zeros( dims, dims, numvecs );
%     for vi=1:numvecs
%         nts(:,:,vi) = vecToNematic( vs(vi,:) );
%     end
end