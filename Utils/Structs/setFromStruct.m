function s = setFromStruct( s, t, fns, mode )
%s = setFromStruct( s, t, fns, mode )
%   Set fields of S in the cellarray FNS of field names to the
%   corresponding values of T.  FNS is optional and defaults to the set of
%   all fields of T.  Other fields of s are left unchanged.
%   If mode is 'all' (the default) then all specified fields are used.  If
%   mode is 'existing', then only fields that already exist in s (and in t)
%   will be updated. Fields that exist in s but not in t will not be
%   deleted from s.  If t is empty, no change is made to s (except that if
%   s is also empty, it is returned as a struct with no fields).
%
%   If fns contains a single field, it can be supplied as a string instead
%   of a cell array containing that string.

    if isempty(t)
        return;
    end
    if isempty(s)
        s = struct();
    end
    if nargin < 3
        fns = fieldnames(t);
    else
        if ischar(fns)
            fns = { fns };
        end
        fns = intersect( fns, fieldnames(t) );
    end
    existing = (nargin >= 4) && strcmp(mode,'existing');
    if existing
        fns = intersect( fns, fieldnames(s) );
    end
    for i = 1:length(fns)
        fn = fns{i};
        s.(fn) = t.(fn);
    end
end
