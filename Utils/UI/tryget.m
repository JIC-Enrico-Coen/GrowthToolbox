function [value,ok] = tryget( h, field )
%tryget( h, field )
%   Get attributes of a handle.  Do not crash if any of them do not exist.
%
%   If FIELD is a string, then if the field exists, VALUE will receive its
%   value and OK will be true.  Otherwise VALUE will be set to [] and OK
%   will be false.
%
%   If FIELD is a cell array of strings (including a cell array of 0 or 1
%   string), then VALUE is returned as a struct containing values for those
%   fields which exist.  OK is true if and only all of the fields exist.

    if ischar(field)
        try
            value = get( h, field );
            ok = true;
        catch e %#ok<NASGU>
            value = [];
            ok = false;
        end
    elseif iscell(field)
        ok = true;
        value = struct();
        for i=1:numel(field)
            f = field{i};
            try
                value.(f) = get( h, f );
            catch e %#ok<NASGU>
                ok = false;
            end
        end
    else
        value = [];
        ok = false;
    end
end

