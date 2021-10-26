function ok = isValidMgenName( varargin )
    if nargin==0
        ok = [];
    return;
    end
    if iscell( varargin{1} )
        names = varargin{1};
    else
        names = varargin;
    end
    if ischar(names)
        ok = isV( names );
    else
        ok = false(1,length(names));
        for i=1:length(names)
            ok(i) = isV( names{i} );
        end
    end
end

function ok = isV( onename )
    ok = ~isempty( regexp( onename, '^[a-zA-Z]\w*$' ) );
end