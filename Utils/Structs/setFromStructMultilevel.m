function s = setFromStructMultilevel( s, t, mode )
%s = setFromStructMultilevel( s, t, mode )
%   Set fields of S to the corresponding values of T, operating
%   hierarchically.  That is, if T.foo is itself a struct, and S.foo exists
%   and is also a struct, then corresponding fields of S.foo are set from
%   the fields of T.foo, instead of replacing the whole of S.foo by T.foo.
%   Other fields of S are left unchanged.
%   If mode is 'all' (the default) then all fields of T are used.  If
%   mode is 'existing', then only fields that already exist in S (and in T)
%   will be updated.

    fns = fieldnames(t);
    if isempty(s)
        s = t;
    else
        if nargin < 3
            mode = 'all';
        end
        existing = strcmp(mode,'existing');
        if existing
            fns = intersect( fns, fieldnames(s) );
        end
        for i = 1:length(fns)
            fn = fns{i};
            if isstruct( t.(fn) ) && isfield(s,fn) && isstruct( s.(fn) )
                s.(fn) = setFromStructMultilevel( s.(fn), t.(fn), mode );
            else
                s.(fn) = t.(fn);
            end
        end
    end
end
