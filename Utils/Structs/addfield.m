function s = addfield( s, fieldname, defaultvalue )
%s = addfield( s, fieldname, defaultvalue )
%   Add a field to a given struct or struct array.
%
%   If the field is already present, s is unchanged.
%
%   If s is not a struct, it is unchanged.
%
%   If s is a nonempty struct array, the field is added to each element,
%   with the given default value.
%
%   If s is an empty struct array, the field is added.
%
%   The default value defaults to [].

    if ~isstruct(s)
        return;
    end
    
    if isfield( s, fieldname )
        return;
    end
    
    if nargin < 3
        defaultvalue = [];
    end
    
    if isempty(s)
        s(1).(fieldname) = defaultvalue;
        s(:) = [];
    else
        for i=1:length(s)
            s(i).(fieldname) = defaultvalue;
        end
    end
end
