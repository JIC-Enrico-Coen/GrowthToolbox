function ud = setUserdataFields( h, varargin )
%ud = setUserdataFields( h, name1, value1, name2, value2, ... )
%   Set fields of the userdata of the handle h according to the arguments.
%   The new userdata is installed back into h and returned as a result.
%   Neither the userdata nor the fields need already exist.
%
%   EQUIVALENT TO addUserData.

    ud = addUserData( h, varargin{:} );

%     s = struct( varargin{:} );
%     ud = setFromStruct( get( h, 'UserData' ), s );
%     set( h, 'UserData', ud );
end