function [x,ok] = getIntFromString( name, xstr, min, max )
    ok = 1;
    x = str2double( xstr );
    if (x ~= x) % true if x is NaN
        fprintf( 1, 'Invalid value "%s" given for %s, integer required.\n', ...
            xstr, name );
        ok = 0;
    elseif x ~= round(x)
        fprintf( 1, 'Invalid value "%s" given for %s, integer required.\n', ...
            xstr, name );
        ok = 0;
    elseif ((nargin == 3) || ((nargin >= 4) && (min < max))) && (x < min)
        fprintf( 1, 'Invalid value %d given for %s, must be at least %d.\n', ...
            x, name, min );
        ok = 0;
    elseif (nargin >= 4) && (x > max)
        fprintf( 1, 'Invalid value %d given for %s, must be not more than %d.\n', ...
            x, name, max );
        ok = 0;
    end
    x = int32(x);
end
