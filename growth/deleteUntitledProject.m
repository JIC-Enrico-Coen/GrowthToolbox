function deleteUntitledProject()
%deleteUntitledProject()
%   Delete the anonymous project, if it exists.

    configdir = getGFtboxUserConfigDir();
    anonymousName = 'Untitled';
    projectdir = fullfile( configdir, anonymousName );
    if exist( projectdir, 'dir' )
        rmdir( projectdir, 's' );
    elseif exist( projectdir, 'file' )
        delete( projectdir );
    end
end

