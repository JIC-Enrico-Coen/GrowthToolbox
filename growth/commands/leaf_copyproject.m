function [m,ok] = leaf_copyproject( m, projectname, projectsdir, varargin )
%[m,ok] = leaf_savenewproject( m, projectname, projectsdir, ... )
%   Create a new copy of the project that M belongs to.
%   If M does not belong to a project, nothing happens.
%   If the operation succeeds, OK is true and the returned M is the initial
%   stage of the new copy.  If the GUI is running, that initial stage will
%   be loaded. Otherwise, OK is false and the M returned is the same as the
%   M given.
%
%   All stage files will be copied across, as well as the interaction
%   function, initial state, and static file, all suitably renamed
%   according to the new project name.
%
%   The folders containing files from past simulations (runs, movies, and
%   snapshots) are not copied across.
%
%   All other files and folders in the current project directory (i.e.
%   anything the user has chosen to store there) will be copied with their
%   names unchanged.
%
%   PROJECTNAME is the name of the new project folder.  This must not be a
%   full path name, just the base name of the folder itself.  If not
%   specified, and the 'ask' option is true, the user will be asked for a
%   name.
%
%   The project will be placed in the folder PROJECTSDIR, if specified.  If
%   not specified, and the 'ask' option is true, then the user will be
%   asked to specify a parent folder.  The dialog will begin at the folder
%   containing the project that M belongs to.
%
%   If the new project directory exists already, the operation will be
%   abandoned: leaf_copyproject never overwrites an existing project.
%
%   Otherwise, the requested project directory will be created and the
%   project files will be copied there.
%
%   Options:
%
%   'ask'   A boolean.  If the project name of projects directory are not
%           specified, and this option is true, the user will be asked.  If
%           either is not specified and this option is false, the procedure
%           fails.
%
%
%   Equivalent GUI operation: the "Save Project As..." menu command.
%
%   Topics: Project management.

    ok = false;

    if isempty(m), return; end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'ask', isinteractive(m) );
    ok = checkcommandargs( mfilename(), s, 'exact', 'ask' );
    if ~ok, return; end
    
    ok = false;

        
    setGlobals();
    oldprojectsdir = m.globalProps.projectdir;
    oldprojectname = m.globalProps.modelname;
    if isempty( oldprojectname ) || isempty( oldprojectsdir )
        return;
    end
    oldprojectfulldir = fullfile( oldprojectsdir, oldprojectname );
    
    if nargin < 2
        projectname = '';
    end
    
    if (nargin < 3) || isempty(projectsdir)
        projectsdir = '';
    end
    
    if ~isempty( projectsdir )
        projectsdir = fullpath( projectsdir );
    end
    
    [projectfulldir,ok] = getNewProjectDir( m, projectsdir, projectname, s.ask );
    if ~ok
        return;
    end
    [projectsdir,modeldir,modelext] = fileparts( projectfulldir );
    projectname = [modeldir modelext];
    
    % At this point we have a valid projects folder and project name.
    [ok,msg,msgid] = mkdir( projectfulldir );
    if ~ok
        fprintf( 1, 'Could not create new project folder %s.\n', projectfulldir );
        warning( msgid, msg );
        return;
    end
    
    % Load the initial state of the project
    [m1,ok] = leaf_reload( m, 'restart', 'rewrite', false );
    if ~ok
        return;
    end
    
%     % Set its project.
%     m1.globalProps.projectdir = projectsdir;
%     m1.globalProps.modelname = projectname;
    
    % If it has an interaction function, generate the new one.
    oldIFname = m.globalProps.mgen_interactionName;
    if ~isempty(oldIFname)
        newIFname = makeIFname( projectname );
        m1 = rewriteInteractionSkeleton( m1, newIFname, projectfulldir, mfilename() );
    end
    
    % Save the model and its static file.
    ok = savemodelfile( m1, fullfile( projectfulldir, projectname ), false, true );
    
    % If there is a notes file, copy it across and open it in the editor.
    oldnotesname = makeNotesName( m );
    if ~exist( oldnotesname, 'file' )
        oldnotesname = '';
    end
    if ~isempty( oldnotesname )
        newnotesname = makeNotesName( m1 );
        if ~strcmpi( oldnotesname, newnotesname )
            fprintf( 1, '%s: copying notes file %s\n    to %s\n', ...
                mfilename(), oldnotesname, newnotesname );
            [ok,msg,msgid] = copyfile( oldnotesname, newnotesname );
            if ok
                try
                    edit( newnotesname );
                catch e
                    complain( 'New notes file %s could not be edited.\n', ...
                        newnotesname );
                    warning(e.identifier, '%s', e.message);
                end
            else
                complain( 'Could not copy old notes file %s\n to %s:\n    %s (%s).\n', ...
                    oldnotesname, newnotesname, msg, msgid );
            end
        end
    end
    
%     % If there is a thumbnail file, copy it across.
%     if ~isempty( oldprojectfulldir )
%         oldthumbname = fullfile( oldprojectfulldir, 'GPT_thumbnail.png' );
%         if exist( oldthumbname, 'file' )
%             newthumbname = fullfile( projectfulldir, 'GPT_thumbnail.png' );
%             if ~strcmpi( oldthumbname, newthumbname )
%                 fprintf( 1, '%s: copying thumbnail file %s\n    to %s\n', ...
%                     mfilename(), oldthumbname, newthumbname );
%                 [ok,msg,msgid] = copyfile( oldthumbname, newthumbname );
%                 if ~ok
%                     complain( 'Could not copy thumbnail file %s\n to %s:\n    %s (%s).\n', ...
%                         oldthumbname, newthumbname, msg, msgid );
%                 end
%             end
%         end
%     end
    

    
    % Copy everything else across. Rename things as necessary, and exclude some
    % subfolders.
    excludepatterns =  { '^\.', ...
                         '^runs$', ...
                         '^movies$', ...
                         '^snapshots$', ...
                         '\~$', ...
                         '\.asv$', ...
                         'BAK\.m$', ...
                         '\.tmp$'
                       };
    oldfiles = dir( oldprojectfulldir );
    for i=1:length(oldfiles)
        n = oldfiles(i).name;
        if strcmp( s, [m.globalProps.mgen_interactionName '.m'] )
            % This is the interaction function.  It will be handled
            % separately.
            continue;
        end
        allowed = true;
        for j=1:length(excludepatterns)
            if regexpi( n, excludepatterns{j} )
                allowed = false;
                break;
            end
        end
        if ~allowed
            continue;
        end
        if beginsWithString( n, oldprojectname )
            continue;
        end
        if ~isempty(m.globalProps.mgen_interactionName) && beginsWithString( n, m.globalProps.mgen_interactionName )
            continue;
        end
        fprintf( 1, 'Copying %s from %s to %s.\n', n, oldprojectfulldir, projectfulldir );
        copyfile( fullfile( oldprojectfulldir, n ), fullfile( projectfulldir, n ) )
    end
    
    % At last we can update M.
    m = m1;
    
    % Save a snapshot.
    if ~isempty( m.pictures )
        snapshotname = 'Initial.png';
%         m = leaf_plot( m );
%         drawnow;
        m = leaf_snapshot( m, snapshotname, 'newfile', 0, 'hires', m.plotdefaults.hiresstages );
        if s.ask
            hh = guidata( m.pictures(1) );
            remakeStageMenu( hh, m.globalDynamicProps.laststagesuffix );
        end
    end
end
