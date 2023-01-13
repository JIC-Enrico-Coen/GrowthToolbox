function saved = save_7_or_73( filename, x, verbose )
%saved = save_7_or_73( filename, x, verbose )
%   Save the variable x to a file.  Use the -v7 option, but if that fails,
%   try -v7.3.  v7 format is much faster and produces much smaller files,
%   but cannot deal with any field of x that is larger than 2GB.
%
%   If saving fails, no error is generated, and an incomplete file is
%   saved.  The only way to determine whether x was saved is therefore to
%   examine that file.  If it is larger than 10kB (larger that we have
%   observed the result of a failed save to be) we assume that it was
%   saved. Otherwise we load it and compare with x.

    saved = true;
    saved7 = true;
    try
        if verbose
            timedFprintf( 1, 'Saving to %s.\n', filename );
        end
        save( filename, '-struct', 'x', '-v7' );
        try
            fileinfo = dir( filename );
            if fileinfo.bytes > 10000
                % File was saved.
                saved7 = true;
            else
                % The file is small.  Load it and compare with what we
                % saved.
                try
                    xx = load( filename );
                    saved7 = compareStructs( x, xx, 'silent', true );
                catch
                    % The file could not be loaded.  Therefore it was not
                    % correctly saved.
                    saved7 = false;
                end
            end
        catch
            % File does not exist.
            saved7 = false;
        end
    catch e
        if verbose
            timedFprintf( 1, 'Could not save to %s: error %s (%s)\n', filename, e.message, e.identifier );
        end
        saved = false;
    end
    if ~saved7
        if verbose
            timedFprintf( 1, 'Saving in v7 format failed, trying v7.3 format.\n    This will take several minutes and may generate a file several GB in size.\n' );
        end
        try
            save( filename, '-struct', 'x', '-v7.3' );
        catch e
            if verbose
                timedFprintf( 1, 'Could not save to $s: error %s (%s)\n', filename, e.message, e.identifier );
                timedFprintf( 1, '    Data not saved.\n' );
            end
            saved = false;
        end
    end
end
