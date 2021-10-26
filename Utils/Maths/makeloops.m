function [vs,perms] = makeloops( v1, v2 )
%perm = makeloops( v1, v2 )
%   This is like makeloop, but handles the situation where the permutation
%   relating v1 and v2 may contain multiple cycles.  The result is a cell
%   array of those cycles.  Every element of v1 occurs exactly once in one
%   of those cycles.
%
%   When v1 has the form 1:N, vs and perms will be identical.

    perms = cell(1,5);
    numloops = 0;
    vs = {};
    k = 1;
    unused = true(size(v1));
    while ~isempty(k)
        [v,perm] = makeloop(v1,v2,k);
        numloops = numloops+1;
        perms{numloops} = perm;
        vs{end+1} = v;
        unused(perm) = false;
        k = find(unused,1);
    end
    perms((numloops+1):end) = [];
end
