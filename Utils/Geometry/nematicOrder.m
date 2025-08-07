function [no,eigvals,eigvecs] = nematicOrder( nt, dims )
%[no,eigvals,eigvecs] = nematicOrder( nt )
%   Calculate the nematic order parameter of the nematic matrix nt. This is
%   always between 0 (a perfectly uniform distribution of directions) and 1
%   (concentrated in a single direction).
%
%   The other outputs are the eigenvectors and eigenvalues of nt. The
%   eigenvectors are returned as column vectors. Note that these are unit
%   vectors, but they are only unique up to multiplication by -1.
%
%[no,eigvals,eigvecs] = nematicOrder( nt, dims )
%   Only the DIMS largest eigenvalues are returned, and the order
%   parameter is computed from only them. Use this where some of the
%   eigenvalues are expected to be mathematically zero (although the code
%   does not consider how close to zero they are).
%
%   This is valid for any number of dimensions.

    
    [eigvecs,eigvals] = eig(nt);
    % If nt is a nematic tensor, its eigenvectors and eigenvalues must be
    % real, and the eigenvalues non-negative. But if the condition number
    % of nt is very large, rounding errors can result in small imaginary or
    % negative real parts in eigvals, and even non-small imaginary parts in
    % eigvecs. Therefore we trim off the imaginary and negative real parts
    % of eigvals, but do not adjust eigvecs.
    eigvals = max(0,real(diag(eigvals)));
    if (nargin < 2) || (dims >= size(nt,1))
        dims = size(nt,1);
    else
        eigvals = sort( eigvals );
        eigvals = eigvals( (end-dims+1):end );
    end
    no = (dims/sqrt(dims-1)) * std(eigvals,1)/norm(eigvals);
    % Mathematically, the order parameter cannot be outside the range 0..1,
    % but as before, rounding errors may violate this. Therefore we trim
    % the value. When nt is all zero, no as computed above will be NaN, so
    % we replace that by 0.
    if isnan(no) || (no < 0)
        no = 0;
    elseif no > 1
        no = 1;
    end
end
