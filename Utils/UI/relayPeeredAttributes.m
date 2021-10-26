function relayPeeredAttributes( item, varargin )
%relayPeeredAttributes( item, name1, name2, ... )
%   Copy the specified attributes of ITEM to all of its peers.

    if ishandle( item ) && ~isempty( varargin )
        nargs = nargin-1;
        attribargs = cell(1,nargs*2);
        for i=1:nargs
            v = varargin{i};
            j = i+i;
            attribargs{ j-1 } = v;
            attribargs{ j } = get( item, v );
        end
        setPeeredAttributes( item, attribargs{:} );
    end
end
