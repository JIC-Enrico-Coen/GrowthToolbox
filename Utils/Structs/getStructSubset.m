function t = getStructSubset( s, subset )
%t = getStructSubset( s, subset )
%   s is a struct and subset is a set of paths.
%   For every path in subset that is a path of s, set that component of t
%   to its value in s.

    t = struct();
    for i=1:length(subset)
        path = subset{i};
        [v,ok] = getStructPath( s, path );
        if ok
            t = setStructPath( t, path, v );
        end
    end
end

function [t,present] = getStructPath( s, path )
%[t,present] = getStructPath( s, path )
%   S is a struct.
%   Set T to the value, if any, at the given path in S.
%   PRESENT is true if and only if the path exists in S. If it does not
%   exist, T will be empty.

    present = true;
    if isempty(path)
        t = s;
    else
        if ischar(path)
            fn = path;
            path = [];
        else
            fn = path{1};
            path = path(2:end);
        end
        if isfield( s, fn )
            t = getStructPath( s.(fn), path );
        else
            t = [];
            present = false;
        end
    end
end

function s = setStructPath( s, path, value, add )
%s = setStructPath( s, path, value )
%   S is a struct.
%   Update the given path in S to have the given value.
%   If the path does not already exist in S, and ADD is true, the path will
%   be added to S.

    if nargin < 4
        add = true;
    end
    if isempty(path)
        s = value;
        return;
    else
        if ischar(path)
            fn = path;
            path = [];
        else
            fn = path{1};
            path = path(2:end);
        end
        if isfield( s, fn )
            s.(fn) = setStructPath( s.(fn), path, value );
        elseif add
            s.(fn) = setStructPath( [], path, value );
        end
    end
end

