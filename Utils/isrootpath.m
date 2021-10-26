function isroot = isrootpath( filename )
%isroot = isrootpath( filename )
%   Determine whether a file path is a root path or a relataive path.
%   This works for both Windows and *nix systems.
%
%   A Windows root path is assumed to begin with a letter, a colon, and a
%   backslash. A Unix rootpath is assumed to begin with a slash.
%
%   This procedure does not ask what sort of machine it is being run on.
%   Anything that looks like a root path for either OS is reported to be a
%   root path.

    if isempty(filename)
        isroot = false;
    elseif filename(1)=='/'
        isroot = true;
    else
        isroot = ~isempty( regexp( filename, '^[A-Za-z]:[\\/]', 'once' ) );
    end
end
