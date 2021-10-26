function [ok,missingfields,extrafields] = checkFields( s, requiredfields, optionalfields )
%ok = checkFields( s, requiredfields, optionalfields )
%   Check that the structure s has all the required fields, and nothing
%   else except the optional fields.

    missingfields = setdiff( requiredfields, fieldnames(s) );
    extrafields = setdiff( fieldnames(s), union( requiredfields, optionalfields ) );
    ok = isempty( missingfields ) && isempty( extrafields );
end
