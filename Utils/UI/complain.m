function complain( varargin )
    varargin{1} = [ '** ', varargin{1} ];
    fprintf( 1, varargin{:} );
    fprintf( 1, '\n' );
%     beep;
end
