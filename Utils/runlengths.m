function [w,len,starts,ends] = runlengths( v, tol )
%[w,len] = runlengths( v )
%   Find all runs of consecutive equal values in v. w is the list of these
%   values, and len is the list of lengths of runs.
%
%[w,len] = runlengths( v, tol )
%   As before, but successive members will be considered "equal" if their
%   absolute difference is no more than tol. Note that if e.g. tol = 1,
%   then the series 0, 0.8, 1.6 will be considered members of a single run,
%   even though the first and last values are not within tol of each other.
%
%   w and len are returned as row vectors.
%
%   If v is a multi-dimensional matrix, it is treated as one-dimensional.

    if nargin < 2
        tol = 0;
    end
    if isempty(v)
        w = [];
        len = [];
    else
        d = find( abs( diffs(v(:)) ) > tol )';
        starts = [1, d+1];
        ends = [d, length(v)];
        len = ends-starts+1;
        w = v(starts);
    end
end