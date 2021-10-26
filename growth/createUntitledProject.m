function [m,ok] = createUntitledProject( m )
%[m,ok] = createUntitledProject( m )
%   Create the anonymous project in ~/.GFtbox/Untitled, deleting whatever
%   that directory contains, creating it if it does not exist.

    [configdir,ok] = makeGFtboxUserConfigDir();
    if ~ok
        return;
    end
    deleteUntitledProject();
    [m,ok] = leaf_savemodel( m, 'Untitled', configdir );
    if ~ok
        queryDialog( 1, 'Problem saving the mesh to disc', 'The mesh could not be saved. Try saving it to a new project.' );
    end
end

