function ud = addUserData( h, varargin )
%ud = addUserData( h, fieldname, value, fieldname, value, ... )
%ud = addUserData( h, s )
%   Set fields of the UserData attribute of the handle h.
%   The complete UserData struct is returned.
%   The arguments can be either alternating field names and values, or a
%   struct.

    ud = get( h, 'UserData' );
    
    % If no data, nothing to do.
    if isempty( varargin )
        return;
    end
    
    % Distinguish the two ways of calling this function.
    if isstruct( varargin{1} )
        s = varargin{1};
    else
        [s,ok] = safemakestruct( mfilename(), varargin );
        if ~ok, return; end
    end
    
    % Install the data.
    if isempty(ud) || ~isstruct(ud)
        set( h, 'UserData', s );
    else
        ud = setFromStruct( ud, s );
        set( h, 'UserData', ud );
    end
end
