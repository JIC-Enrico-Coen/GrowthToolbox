function s = defaultFromStruct( s, d, fns )
%s = defaultFromStruct( s, d, fn )
%   Set nonexistent fields of S in the cellarray FN of field names to the
%   corresponding values of D.  FN is optional and defaults to the set of
%   all fields of D.

    if ~isstruct(s)
        return;
    end

    if nargin < 3
        fns = fieldnames(d);
    end
    
    if isempty(s)    
        s = emptystructarray( union( fieldnames(s), fns ) );
    else
        newfields = setdiff( fns, fieldnames(s) );
        for i=1:length(newfields)
            dv = d.(newfields{i});
            for j=1:length(s)
                s(j).(newfields{i}) = dv;
            end
        end
    end
end
