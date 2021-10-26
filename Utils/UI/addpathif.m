function added = addpathif( d )
%added = addpathif( d )
%   As addpath(d), but returns true if and only if d exists, is a
%   directory, and was not already on the path.  If d does not exist or is
%   not a directory, nothing happens.  If d is an existing directory
%   already on the path, addpath(d) is still called, as this has the effect
%   of moving d to the beginning of the path.

    if ~exist(d,'dir')
        return;
    end
    p = path();
    dpos = findinpath( d, p );
    if dpos ~= 1
        try
            addpath( d );
            if dpos==0
                fprintf( 1, '%s: Adding %s to head of command path.\n', mfilename(), d );
            else
                fprintf( 1, '%s: Moving %s to head of command path.\n', mfilename(), d );
            end
            added = true;
        catch e
            fprintf( 1, 'Failed to add folder "%s" to command path:\n    %s\n', d, e.message );
            added = false;
        end
    else
        added = true;
        fprintf( 1, '%s: %s is at the head of the path.\n', mfilename(), d );
    end
end
