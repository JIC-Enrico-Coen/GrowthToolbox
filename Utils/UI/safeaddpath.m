function safeaddpath( p )
%safeaddpath( p )
%   Like addpath( p ), in the case where p is a single directory name, but
%   ignores any elements of p that do not exist or are not directories.

    if ~exist(p,'dir')
        return;
    end
    addpath( p );
end
