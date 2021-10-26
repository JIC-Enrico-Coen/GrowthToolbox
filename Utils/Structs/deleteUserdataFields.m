function ud = deleteUserdataFields( h, varargin )
%ud = deleteUserdataFields( h, name1, name2, ... )
%   Delete fields of the userdata of the handle h.
%   The new userdata is installed back into h and returned as a result.

    ud = safermfield( get( h, 'UserData' ), varargin );
    set( h, 'UserData', ud );
end