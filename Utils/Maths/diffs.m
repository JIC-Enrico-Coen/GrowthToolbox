function dv = diffs( v )
%dv = diffs( v )
%   Set dv to the vector of differences between consecutive members of v.
%   v must be nonempty.

    dv = v(2:end) - v(1:(end-1));
end
