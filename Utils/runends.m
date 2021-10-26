function [starts,ends,uv] = runends( v )
%[starts,ends] = runends( v )
%   Find the beginning and end of every run of consecutive equal values in
%   v, as lists of indexes into v.  v may be either a row vector or a
%   column vector, and starts and ends will be row or column accordingly.
%   uv is a list of the unique values of v, and is equal to both v(starts)
%   and v(ends).
%
%   If v is empty, then starts, ends, and uv are empty.  Otherwise, the
%   first element of starts is always 1, and the last element of ends is
%   always length(v).
    
    if isempty(v)
        starts = [];
        ends = [];
        uv = [];
    else
        steps = find( v(2:end) ~= v(1:(end-1)) );
        if (size(v,1)==1)
            starts = [1 steps+1];
            ends = [steps length(v)];
        else
            starts = [1; steps(:)+1];
            ends = [steps(:); length(v)];
        end
        uv = v(starts);
    end
end
