function ud = removeUserDataFields( h, varargin )
    ud = get( h, 'UserData' );
    if isstruct(ud)
        ud = safermfield( ud, varargin{:} );
        set( h, 'UserData', ud );
    end
end
