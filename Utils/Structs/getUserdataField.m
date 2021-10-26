function [v,ok] = getUserdataField( h, fieldname, dflt )
%v = getUserdataField( h, fieldname, dflt )
%   Get a field of the UserData attribute of the handle h.
%   ok is true if and only if the field exists.  If it does not, v is
%   set to dflt, if present, otherwise [].

    if nargin < 3
        dflt = [];
    end
    ud = get( h, 'UserData' );
    ok = isfield( ud, fieldname );
    if ok
        v = ud.(fieldname);
    else
        v = dflt;
    end
end
