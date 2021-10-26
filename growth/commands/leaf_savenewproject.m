function [m,ok] = leaf_savenewproject( m, projectname, projectsdir, varargin )
%[m,ok] = leaf_savenewproject( m, projectname, projectsdir, ... )
%   Create a new copy of the current project, or if there is no current
%   project, create a new project using the given mesh as its initial
%   state.
%
%   In the case of making a new copy of the current project, the new
%   project will begin from the initial state of the current project,
%   regardless of which stage of the project the mesh M is.  All currently
%   existing stage files will be copied across, as well as the interaction
%   function, initial state, and static file, all suitably renamed
%   according to the new project name.  The folders containing files from
%   past simulations (runs, movies, and snapshots) will not be copied
%   across.  All other files and folders in the current project directory
%   (i.e. anything the user has chosen to store there) will be copied with
%   their names unchanged.
%
%   PROJECTNAME is the name of the new project folder.  This must not be a full
%   path name, just the base name of the folder itself.  It will be looked
%   for in the folder PROJECTDIR, if specified, otherwise in the parent
%   directory of m, if any, otherwise the current directory.
%
%   If MODELNAME is not specified or empty, the user will be prompted for a
%   name using the standard file dialog.
%
%   If the new project directory exists already, the operation will be
%   abandoned: leaf_savenewproject never overwrites an existing project.
%
%   Otherwise, the requested project directory will be created and the
%   project files will be saved or copied there.
%
%   OK will be true if and only if the model was saved.  The result M will
%   be the initial stage of that project, and if the GUI is present, that
%   initial stage will be loaded.
%
%   Equivalent GUI operation: the "Save Project As..." menu command.
%
%   Topics: Project management.

    ok = false;

    if isempty(m), return; end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'ask', isinteractive(m), 'strip', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
            'ask', 'strip' );
    if ~ok, return; end

    if nargin < 3
        projectname = '';
    end
    
    if nargin < 4
        projectsdir = '';
    end
    
    setGlobals();
    oldprojectsdir = m.globalProps.projectdir;
    oldprojectname = m.globalProps.modelname;
    haveOldProject = ~isempty( oldprojectsdir ) && ~isempty( oldprojectname );
    if haveOldProject
        [m,ok] = leaf_copyproject( m, projectname, projectsdir, varargin{:} );
        return;
    end
    oldprojectfulldir = fullfile( oldprojectsdir, oldprojectname );
    
    if ~isempty(projectsdir)
        projectsdir = fullpath( projectsdir );
    end
    
    
    [projectfulldir,ok] = getNewProjectDir( m, projectsdir, projectname, s.ask );
    if ~ok
        return;
    end
    [projectsdir,modeldir,modelext] = fileparts( projectfulldir );
    projectname = [modeldir modelext];
    if exist( projectfulldir, 'file' )
        if s.ask
            queryDialog( 1, 'Invalid directory', ...
                '%s already exists.', projectfulldir );
        end
        return;
    end
    
    % At this point we have a valid projects folder and project name.
    [ok,msg,msgid] = mkdir( projectfulldir );
    if ~ok
        fprintf( 1, 'Could not create new project folder %s.\n', projectfulldir );
        warning( msgid, msg );
        return;
    end
    
    % Set the name and project folder of m.
    m.globalProps.projectdir = projectsdir;
    m.globalProps.modelname = projectname;
    
    m.globalProps.allowsave = true;
    m.globalProps.readonly = false;
    m.globalDynamicProps.staticreadonly=false;
    m.globalDynamicProps.currentIter = 0;
    m.globalDynamicProps.doinit = true;

    % Save m and the static file.
    ok = savemodelfile( m, fullfile( projectfulldir, projectname ), s.strip, true );
    
    % Save a snapshot.
    if ~isempty( m.pictures )
        snapshotname = 'Initial.png';
%         m = leaf_plot( m );
%         drawnow;
        m = leaf_snapshot( m, snapshotname, 'newfile', 0, 'hires', m.plotdefaults.hiresstages );
        hh = guidata( m.pictures(1) );
        remakeStageMenu( hh, m.globalDynamicProps.laststagesuffix );
    end
end
