function [value,s,ok] = extractField( s, fieldname )
%function [value,s] = extractField( s, fieldname )
%   Return VALUE as the value of s.(fieldname), and remove FIELDNAME from
%   S.
%
%   If FIELDNAME does not exist in S, or S is not a struct, VELUS is empty,
%   S is 
    ok = isfield( s, fieldname );
    if ok
        value = s.(fieldname);
        s = rmfield( s, fieldname );
    else
        value = [];
    end
end
