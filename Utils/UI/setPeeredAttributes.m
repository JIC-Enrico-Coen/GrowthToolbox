function setPeeredAttributes( item, varargin )
%setPeeredAttributes( item, name1, value1, name2, value2, ... )
%   Set the given properties of the handle ITEM and all its peers.
%   If ITEM is not peered, then it sets the attributes just of ITEM.

    if ishandle( item ) && ~isempty( varargin )
        ud = get( item, 'UserData' );
        if isfield( ud, 'peers' );
            for i=1:length(ud.peers)
                set( ud.peers(i), varargin{:} );
            end
        else
            set( item, varargin{:} );
        end
    end
end
