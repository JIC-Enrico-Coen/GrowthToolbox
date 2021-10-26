function s = floatstring( f, precision )
%s = floatstring( f, precision )
%   Convert an array of floats to a string.  The precision defaults to 8.

    if isempty(f)
        s = '';
    else
        if nargin < 2
            precision = 8;
        end
        fmt = [ '%.', sprintf( '%d', precision ), 'g' ];
        if numel(f)==1
            s = sprintf( fmt, f );
        else
            s = [ sprintf( fmt, f(1) ), sprintf( [' ' fmt], f(2:end) ) ];
        end
    end
end