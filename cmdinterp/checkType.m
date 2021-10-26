function ok = checkType( msg, type, arg )
%ok = checkType( msg, type, arg )
%   Check the type of arg and print an error message if it is not of the
%   required type.

    ok = isType(arg,type);
    if ~ok
        fprintf( 1, '%s: %s argument expected, %s found.  Command ignored.\n ', msg, type, class(arg) );
        arg
    end
end

