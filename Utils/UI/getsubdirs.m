function dirs = getsubdirs( dirname, varargin )
%dirs = getsubdirs( dir, ... )
%   Return the names of the directory dirname and all its
%   subdirectories, except for directories matching any of the regexp
%   patterns given as subsequent arguments.  The result is a single string
%   in which the names of all the directories are concatenated, separated
%   by a ':' character.  This string can be passed to the path() command,
%   to add all of these directories to the MATLAB command path.

    x = genpath( dirname );
    dirlist = splitString( pathsep(), x );
    retain = true(1,length(dirlist));
    for i=1:length(dirlist)
        if isempty(dirlist{i})
            retain(i) = false;
        else
            for j=1:length(varargin)
                retain(i) = retain(i) && isempty( regexp( dirlist{i}, varargin{j} , 'once' ) );
            end
        end
    end
    dirs = joinstrings( pathsep(), { dirlist{retain} } );
end

