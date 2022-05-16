function [c,ia,ic,as,sp,aix] = uniqueRowsTol( a, tol )
%[c,ia,ic] = uniqueRowsTol( a, tol )
%   This is the same as unique( a, 'rows', 'stable' ), except that it
%   allows a tolerance for the comparision of elements of A, instead of
%   considering only exact equality. The default value of TOL is 0, in
%   which case this is identical to unique( a, 'rows', 'stable' ).
%
%[c,ia,ic,as,aix] = uniqueRowsTol( a, tol )
%   AS is the result of sortrows( A ), generalised for the tolerance.
%   SP is the corresponding permutation: AS = A(SP,:).
%   AIX is derived from A by replacing each value of A by its rank in the
%   result of sorting its column with tolerance. This has exact sorting and
%   uniqueness properties corresponding to the approximate sorting and
%   uniqueness properties of A.

    if nargin < 2
        tol = 0;
    end
    npts = size(a,1);
    ndims = size(a,2);
    aix = zeros(size(a));
    for di = 1:ndims
        [a1,p] = sort( a(:,di) );
        p1 = invperm(p);
        same1 = [ false; abs( a1(2:end)-a1(1:(end-1)) ) <= tol ];
        ix = zeros(npts,1); 
        nix = 0;
        for i=1:length(same1)
            if same1(i)
                ix(i) = ix(i-1);
            else
                nix = nix+1;
                ix(i) = nix;
            end
        end
        aix(:,di) = ix(p1);
    end
    
    % At this point, AIX is an array the same size as A.
    % AIX(I,J) is equal to the smallest K such that AIX(I,J)==AIX(K,J).
    % Thus two rows of AIX are identical whenever the corresponding rows of
    % A are approximately identical.
    % Using unique() to sort AIX gives the desired indexing maps IA and IC,
    % which can then be appliced to A to yield C.
    
    [~,ia,ic] = unique( aix, 'rows', 'stable' );
    c = a(ia,:);
    
    if nargout >= 4
        [~,sp] = sortrows( aix );
        as = a(sp,:);
    end
end
