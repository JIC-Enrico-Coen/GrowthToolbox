function success = openmdir( mname )
%success = openmdir( mname )
%   Open an Explorer window for the directory containing the given Matlab
%   command.
%   If the return argument is specified, it will be 1 for success and 0 for
%   failure.  If it is not, then on failure an error message will be
%   written to the Matlab console.

    fullname = which( mname );
    if fullname
        s = opendir( fullname );
    else
        s = 0;
    end
    if nargout > 0
        success = s;
    elseif ~s
        fprintf( 1, '%s: cannot find Matlab command %s.\n', mfilename(), mname );
    end
end
