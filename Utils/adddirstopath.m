function dirs = adddirstopath( dirname, varargin )
%dirs = adddirstopath( dir, ... )
%   Add dir and all its subdirectories to the path, except for directories
%   matching any of the patterns given as subsequent arguments.

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
