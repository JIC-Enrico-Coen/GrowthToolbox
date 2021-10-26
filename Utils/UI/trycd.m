function olddir = trycd( newdir, silent )
%olddir = trycd( newdir )
%   Like CD, but prints a warning if it fails instead of raising an
%   exception.  If it fails, olddir will be set to the empty string.
%   If silent is true (default is false) no warning will be given.
%
%   If trycd fails, olddir will be empty and the current directory will not
%   be changed.
%
%   See also:
%       CD

    if nargin < 2
        silent = false;
    end
    try
        olddir = cd( newdir );
    catch e
        if ~silent
            fprintf( 1, '%s\n', e.message );
        end
        olddir = '';
    end
end
