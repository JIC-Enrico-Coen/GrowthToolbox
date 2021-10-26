function s = defaultStructArrayFromStruct( s, d, fns )
%s = defaultStructArrayFromStruct( s, d, fn )
%   Set nonexistent fields of every member of S in the cellarray FNS of
%   field names to the corresponding values of D.  FNS is optional and
%   defaults to the set of all fields of D.  If S is empty it will remain
%   empty, but acquire all the new field names.

    if nargin < 3
        fns = fieldnames(d);
    end
    newfields = setdiff( fns, fieldnames(s) );
    if isempty( newfields )
        return;
    end
    if isempty(s)
        for i=1:length(newfields)
            fn = newfields{i};
            s(1).(fn) = d.(fn);
        end
        s(1) = [];
    else
        for i = 1:length(newfields)
            fn = newfields{i};
            if ~isfield( s, fn )
                for si=1:length(s)
                    s(si).(fn) = d.(fn);
                end
            end
        end
        
        for si=1:length(s)
            for i = 1:length(newfields)
                fn = newfields{i};
                if ~isfield( s(si), fn )
                    s(si).(fn) = d.(fn);
                end
            end
        end
    end
end
