function [perm,F2] = alignFrames( F1, F2 )
%perm = alignFrames( F1, F2 )
%   F1 and F2 are orthonormal frames of column vectors.
%   The result is the permutation that makes F2(:,perm) most closely
%   approximate F1.  It first determines the column of F2 that F1(:,3) is
%   closest to, then decides the order of the other two.

    dots = abs( sum( F2 .* repmat( F1(:,3), 1, 3 ), 1 ) );
    [m,i] = max( dots );
    j = mod(i,3)+1;
    k = mod(j,3)+1;
    dots = abs( sum( F2(:,[j k]) .* repmat( F1(:,1), 1, 2 ), 1 ) );
    [m,n] = max( dots );
    if n==1
        perm = [ j, k, i ];
    else
        perm = [ k, j, i ];
    end
    F2 = F2(:,perm);
end
