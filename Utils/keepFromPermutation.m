function remainingPerm = keepFromPermutation( perm, keep )
%remainingPerm = keepFromPermutation( perm, keep )
%
%   Given a permutation PERM of the integers from 1 to N, and a subset KEEP
%   of 1...N (given either as a boolean map or a list of indexes), delete
%   from PERM all the elements not at those indexes, and renumber the
%   remainder so as to use values from 1 to M, where M is the number of
%   elements remaining.
%
%   If KEEP is a list of indexes, the result is independent of the order
%   they are listed in KEEP.

    if isnumeric(keep)
        keep = sort(keep);
    end
    remainingPerm = perm(keep);
    [~,p] = sort( remainingPerm );
    remainingPerm = invperm(p);
end
