function projects = findGFtboxProjects( dirname )
%projects = findGFtboxProjects( dirname )
%   Find all the GFtbox projects contained in the given directory or any of
%   its subdirectories recursively. DIRNAME can be a relative or absolute
%   path.
%
%   The result is an N*1 cell array of the full path names of the projects.

    projects = cell(0,1);
    
    fulldirpath = fullpath( dirname );
    listing = dir( fulldirpath );
    if isempty( listing )
        return;
    end
    
    projects = cell( 20, 1 ); % Preallocated mainly just to avoid  Matlab
             % warning about changing the size of an array inside a loop.
    numprojects = 0;
    
    for li=1:length(listing)
        if listing(li).isdir && (listing(li).name(1) ~= '.')
            childdir = fullfile( fulldirpath, listing(li).name );
            if isGFtboxProjectDir( childdir )
                % Got one.
                numprojects = numprojects+1;
                projects{ numprojects, 1 } = childdir;
            else
                % Recursive search
                projects1 = findGFtboxProjects( childdir );
                numnewprojects = length( projects1 );
                projects( (numprojects+1):(numprojects+numnewprojects) ) = projects1;
                numprojects = numprojects+numnewprojects;
            end
        end
    end
    
    projects( (numprojects+1):end ) = [];
end