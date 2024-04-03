function GFtboxAlert( m, format, varargin )
    if isstruct(m)
        interactive = isinteractive( m );
    else
        interactive = m;
    end
    interactive = interactive && ~oncluster();
    if interactive
        queryDialog( 1, 'GFtbox', format, varargin{:} );
    end
    fprintf( 1, [format, '\n'], varargin{:} );
end
