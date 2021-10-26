function names = dirnames( filename )
%names = dirnames( filename )
%   Like DIR, but return a cell array of just the names.

    dirlist = dir( filename );
    names = { dirlist(:).name };
end
