function ok = trymkdir( dirname )
%ok = trymkdir( dirname )
%   Creates a directory and returns a boolean to indicate success or failure.
%   If it fails, a warning will be printed.
%
%   See also:
%       MKDIR

    ok = true;
    if ~exist( dirname, 'dir' )
        try
            mkdir( dirname );
        catch e
            fprintf( 1, 'Cannot create folder %s:\n    %s\n', dirname, e.message );
            ok = false;
        end
    end
end
