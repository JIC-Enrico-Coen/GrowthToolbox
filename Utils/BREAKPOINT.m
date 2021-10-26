function BREAKPOINT( varargin )
    if nargin==0
        fprintf( 1, 'User invoked breakpoint.\n' );
    else
        fprintf( 1, varargin{:} );
    end
    dbstack
%     keyboard();
end