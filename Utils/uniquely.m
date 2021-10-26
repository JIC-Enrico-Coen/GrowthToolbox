function [c,ia] = uniquely( a )
% [c,ia,ic] = uniquely( a )
%   UNIQUELY is like UNIQUE, but returns only those elements of A that
%   occur exactly once in A.  IA is such that C = A(IA), and is the index
%   of the first place in A that each element of C occurs.
%
%   A can be of any shape.  C and IA are always returned as column vectors.
%
%   The other options of UNIQUE are not supported.
%
%   See also: unique.

    [c,ia,ic] = unique( a(:) );
    
    remaining = true(numel(a),1);
    remaining(ia) = false;
    % REMAINING is a map of those elements of A that were not selected.
    % These elements occur more than once in A, and therefore must be
    % removed from C.
    
    [c,ic1] = setdiff(c,a(remaining));
    ia = ia(ic1);
end
    