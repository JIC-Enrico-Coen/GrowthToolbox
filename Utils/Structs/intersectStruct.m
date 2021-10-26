function s = intersectStruct( s, t )
%s = intersectStruct( s, t )
%   S is a struct and T is either a struct or a list of field names.
%   All fields of S are removed that are not fields of T, or members of T,
%   respectively.

    if isstruct(t)
        t = fieldnames(t);
    end
    
    if isempty(t)
        return;
    end
    
    s = rmfield( s, setdiff( fieldnames(s), t ) );
end