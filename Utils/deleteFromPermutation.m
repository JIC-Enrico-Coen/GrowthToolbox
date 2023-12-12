function remainingPerm = deleteFromPermutation( perm, del )
%remainingPerm = deleteFromPermutation( perm, del )
%
%   Given a permutation PERM of the integers from 1 to N, and a subset DEL
%   of 1...N (given either as a boolean map or a list of indexes), delete
%   from PERM the elements at those indexes, and renumber the remainder
%   so as to use values from 1 to M, where M is the number of elements
%   remaining.

    remainingPerm = perm;
    remainingPerm(del) = [];
    [~,p] = sort( remainingPerm );
    remainingPerm = invperm(p);
end
