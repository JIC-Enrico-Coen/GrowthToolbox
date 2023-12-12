function BREAKPOINT( varargin )
    if nargin==0
        timedFprintf( 1, 'User invoked breakpoint.\n' );
    else
        timedFprintf( 1, varargin{:} );
    end
    dbstack
    xxxx = 1;
%     keyboard();
end