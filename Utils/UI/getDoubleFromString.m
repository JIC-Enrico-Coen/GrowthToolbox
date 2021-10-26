function [x,ok] = getDoubleFromString( name, xstr, minval, maxval, verbose )
%[x,ok] = getDoubleFromString( name, xstr, minval, maxval, verbose )
%   Parse the string XSTR for a floating point number.
    havemin = (nargin >= 3) && ~isempty(minval);
    havemax = (nargin >= 4) && ~isempty(maxval);
    if havemin && havemax && (minval >= maxval)
        havemin = false;
        havemax = false;
    end
    if nargin < 5
        verbose = true;
    end
    ok = true;
    if isempty(xstr)
        x = 0;
    else
        x = str2double( xstr );
    end
    if (x ~= x)
        if verbose
            fprintf( 1, 'Invalid value "%s" given for %s, real number required.\n', ...
                xstr, name );
        end
        ok = false;
    elseif havemin && (x < minval)
        if verbose
            fprintf( 1, 'Invalid value %f given for %s, must be at least %f.\n', ...
                x, name, minval );
        end
        ok = false;
    elseif havemax && (x > maxval)
        if verbose
            fprintf( 1, 'Invalid value %f given for %s, must be not more than %f.\n', ...
                x, name, max );
        end
        ok = false;
    end
end
