function h = patchReuse( h, varargin )
    if isempty(h) || ~ishghandle(h)
        h = patch( varargin{:} );
    else
        set( h, varargin{:} );
    end
end
