function s = getUserdataFields( h, fieldnames, mode )
%s = getUserdataFields( h, fieldnames, returnall )
%   Get the given fields of the UserData attribute of the handle h.
%   If mode is 'existing' (the default) then s will contain only those
%   fields that are present in h.  If mode is 'all', then fields not in h
%   will be returned as [].
%
%   This always returns a struct.  If a single value is required, with a
%   boolean to say whether it is present, call instead
%       [s,ok] = getUserdataField( h, fieldname );

    if nargin < 3
        mode = 'all';
    end

    s = setFromStruct( [], get( h, 'UserData' ), fieldnames, mode );
end
