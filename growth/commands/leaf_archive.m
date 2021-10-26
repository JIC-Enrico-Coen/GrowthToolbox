function m = leaf_archive( m )
%m = leaf_archive( m )
%   Create an archive of the current state of the project.
%   Archived states are kept in a subfolder ARCHIVE of the current project.
%   Each archived state is in a project folder whose name is the name of
%   the current project, with '_Ann' appended, where nn is a number 1
%   greater than the maximum number that has already been used, or 1 for
%   the first created archive.
%
%   Arguments: none.
%
%   Equivalent GUI operation: clicking the "Archive" button.
%
%   INCOMPLETE -- DO NOT USE.
%
%   Topics: HIDE, Project management.

%fprintf( 1, 'Archive function not implemented.\n' );
%beep;
%return;

    if isempty(m), return; end
    % Take a snapshot of the current state.
    m = leaf_snapshot( m, 'Final.png', 'newfile', false, 'hires', m.plotdefaults.hiresstages );
    
    % Make the archive directory.
    pdir = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
    adir = fullfile( pdir, 'ARCHIVE' );
    fprintf( 1, 'Making directory %s.\n', adir );
    quietmkdir( mfilename(), adir );
    amodelname = newArchiveDirectory( adir, m.globalProps.modelname );
    fprintf( 1, 'Archived name is %s.\n', amodelname );
    apdir = fullfile( adir, amodelname );
    quietmkdir( mfilename(), apdir );
    
    fprintf( 1, 'Archiving model to %s.\n', apdir );
    
    % Save the project into the archive folder.
    m = leaf_savemodel( m, amodelname, adir, 'copy', 1 );

    % Move movies and snapshots folders into the archive.
    mdir = fullfile( pdir, 'movies' );
    if exist( mdir, 'dir' )
        amdir = fullfile( apdir, 'movies' );
        movefile( mdir, amdir );
    end
    sdir = fullfile( pdir, 'snapshots' );
    if exist( sdir, 'dir' )
        asdir = fullfile( apdir, 'snapshots' );
        movefile( sdir, apdir );
    end
    
    % Recreate the snapshots folder and copy the Initial.png
    % snapshot into it from the archive.
    quietmkdir( mfilename(), sdir );
    if exist( sdir, 'dir' ) && exist( asdir, 'dir' )
        initialFileName = fullfile( asdir, 'Initial.png' );
        if exist( initialFileName, 'file' )
            copyfile( initialFileName, fullfile( sdir, 'Initial.png' ) );
        end
    end
end

function ok = quietmkdir( msg, dirname )
    if exist(dirname,'dir')
        ok = 1;
        return;
    end
    if exist(dirname,'file')
        fprintf( 1, '%s: Cannot make directory %s,\nbecause there is already a file there.\n', ...
            msg, dirname );
        ok = 0;
        return;
    end
    ok = 1;
    mkdir(dirname);
end
