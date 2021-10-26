function s = datestring( c )
    if nargin < 1
        c = clock;
    end
    if nargout < 1
        fprintf( 1, '%d/%02d/%02d %02d:%02d:%02d', round(c) );
    else
        s = sprintf( '%d/%02d/%02d %02d:%02d:%02d', round(c) );
    end
end