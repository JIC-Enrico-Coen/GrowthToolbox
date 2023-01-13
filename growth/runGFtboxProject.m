function runGFtboxProject( project, varargin )
%runGFtboxProject( projectdir, ... )
%   Run a GFtbox project non-interactively.  PROJECT is the project
%   directory.  If it is a bare filename, it will be looked for in the
%   user's default project directories.  Alternatively, a full path name
%   can be given.
%
%   This is followed by alternating option names and values.
%
%   Options:
%
%   'until'   The time to run the project to.  This can also be a list of
%        times, in which case a snapshot will be taken at each of the
%        specified times.
%
%   'steps'   The number of steps to run for.  'steps' and 'until' are
%        mutually exclusive: if both are given, 'steps' is ignored.  If
%        neither is given, the project will be run to its final stage, if
%        it has any, otherwise no steps will be run.
%
%   'resultsdir'   A directory to store results in.  This must already
%       exist.  It defaults to the directory current when this procedure is
%       invoked.
%
%   'saverun'  A name to save the run by.  It this is empty, the run is not
%       saved.
%
%   'figure'  Either an existing figure handle or a positive integer. This
%       is the figure that all plotting (if there is any) will be done in.
%
%   'snapshot'  Either false, true (the default) or a string. This
%       specifies whether to save a snapshot of the final state, using
%       either the default name for a snapshot or a specified name.
%
%   'movie'   This is either false (the default), true, or a string. In the
%       last two cases, a movie will be created, either automatically named
%       or given the name provided.  If a relative file name is given, it
%       will be understood relative to the directory current when this
%       procedure is called.
%
%   'beginmovie'  The time at which to begin recording a movie.  By
%       default, from the beginning of the run.
%
%   'movieoptions'  A struct containing the movie options, as would be
%       provided to leaf_movie. Movie options not specified are taken from
%       the project.
%
%   'hiresoptions'  A struct containing options for setting the resolution
%       of snapshots and movies.
%
%   'plotoptions'  A struct containing the plotting options, as would be
%       provided to leaf_plotoptions. Plotting options not specified are
%       taken from the project.
%
%   'plotting'  If true (the default) plot the mesh after every iteration.
%       Otherwise, only plot the mesh when required for a movie or
%       snapshot.
%
%   'modeloptions'  A struct containing the model options, as would be
%      set up in the interaction function.
%
%   See also: leaf_movie

    begintime = tic();
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'until', [], ...
        'steps', 0, ...
        'resultsdir', [], ...
        'saverun', [], ...
        ... % 'figure', [], ...
        'legendTemplate', '%T', ...
        'snapshot', 'foo',...
        'plotting', true,...
        'movie', false, ...
        'beginmovie', [], ...
        'endmovie', [], ...
        'movieoptions', [], ...
        'plotoptions', [], ...
        'modeloptions', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'until', ...
        'steps', ...
        'resultsdir', ...
        'saverun', ...
        'legendTemplate', ...
        'snapshot', ...
        'plotting', ...
        'movie', ...
        'beginmovie', ...
        'endmovie', ...
        'movieoptions', ...
        'plotoptions', ...
        'modeloptions' );
    if ~ok, return; end
    
    [s.movieoptions,ok] = safemakestruct( mfilename(), s.movieoptions );
    if ~ok, return; end
    [s.plotoptions,ok] = safemakestruct( mfilename(), s.plotoptions );
    if ~ok, return; end
    if ~isempty( s.modeloptions )
        [s.modeloptions,ok] = safemakestruct( mfilename(), s.modeloptions );
    end
    
    if ~ok, return; end
    
    if isempty( s.resultsdir )
    	s.resultsdir = pwd();
    end
    
    s.until = unique( [ s.until, s.beginmovie ] );
    
    logfilename = fullfile( s.resultsdir, [mfilename() '_log.txt'] );
    logfid = fopen( logfilename, 'a' );
    if logfid == -1
        timedFprintf( 1, 'Cannot append to log file %s.\n', logfilename );
        return;
    end
    timedFprintf( 1, 'Writing log file %s\n', logfilename );
    
    config = readGFtboxConfig();

    % Find the project.
    ok = false;
    if ~isempty(config.defaultprojectdir)
        alldirs = setdiff( config.projectsdir{:}, {config.defaultprojectdir} );
        alldirs = [ config.defaultprojectdir, alldirs ];
    else
        alldirs = config.projectsdir;
    end
    if isabsolutepath( project )
        [projectsdir,projectbase,ext] = fileparts( project );
        project = [projectbase,ext];
        log_runGFtboxProject( 'Attempting to load project %s from projects dir %s\n', project, projectsdir );
        [m,~] = leaf_loadmodel( [], project, projectsdir, 'interactive', false );
    else
        for i=1:length(alldirs)
            projectsdir = alldirs{i};
            log_runGFtboxProject( 'Attempting to load project %s from projects dir %s\n', project, projectsdir );
            [m,ok] = leaf_loadmodel( [], project, projectsdir, 'interactive', false );
            if ok
                break;
            end
        end
        if ~ok
            log_runGFtboxProject( 'Project ''%s'' not found.\n', project );
            endlog();
            return;
        end
    end
    m = leaf_setproperty( m, 'legendTemplate', s.legendTemplate );
    
    log_runGFtboxProject( 'Running project ''%s''.\nProjects directory ''%s''.\n', project, projectsdir );
    
    % Print all parameters.
    log_runGFtboxProject( 'Run parameters:\n' );
    printValue( 1, s );
    printValue( logfid, s );
    
    % Call the i.f. to initialise things, to ensure that the first plotted
    % image is valid and the i.f. runs without error.
    m = leaf_setproperty( m, 'IFsetsoptions', true );
    [m,ok] = leaf_dointeraction( m );
    if ~ok
        log_runGFtboxProject( 'Interaction function failed for project %s.\n', project );
        endlog();
        return;
    end
    
    % If model options were provided, install them.
    if ~isempty(s.modeloptions)
        m = leaf_setproperty( m, 'IFsetsoptions', false );
        m = setModelOptions( m, s.modeloptions );
    end
    log_runGFtboxProject( 'Project loaded and initialised. Model options:\n' );
    printModelOptions( 1, m );
    printModelOptions( logfid, m );
    
    % Delete all stage files.
    m = leaf_deletestages( m, 'stages', true );
    
    haveFigure = false;
    haveMovie = false;
    wantMovie = ~isempty(s.movie) && (ischar(s.movie) || s.movie);
    movieFromStart = wantMovie && isempty(s.beginmovie);
    if s.plotting || movieFromStart
        m = leaf_addpicture( m, 'figure', 4 );
        m = leaf_plot( m, s.plotoptions );
        haveFigure = true;
        if movieFromStart
            startmovie();
        end
    end
    
    h = guidata( m.pictures );
    setMyLegend(m);
    h.legend.Visible = 'on';
    
    % Process the 'until' and 'steps' options.
    if isempty(s.until)
        if s.steps==0
            log_runGFtboxProject( 'Recomputing all stages.\n' );
            m = leaf_recomputestages( m, 'plot', s.plotting );
        else
            log_runGFtboxProject( 'Recomputing for %d steps.\n', s.steps );
            m = leaf_iterate( m, s.steps, 'until', [], 'plot', s.plotting );
        end
    else
        for si=1:length(s.steps)
            u = s.steps(si);
            log_runGFtboxProject( 'Recomputing to time %f.\n', u );
            m = leaf_iterate( m, s.steps, 'until', u, 'plot', int32(s.plotting) );
            if u==s.beginmovie
                startmovie();
            end
            if u==s.endmovie
                endmovie();
            end
        end
%         if isempty(s.beginmovie)
%             log_runGFtboxProject( 'Recomputing to time %f.\n', s.until );
%             m = leaf_iterate( m, s.steps, 'until', s.until, 'plot', int32(s.plotting) );
%         else
%             log_runGFtboxProject( 'Recomputing to time %f.\n', s.beginmovie );
%             m = leaf_iterate( m, s.steps, 'until', s.beginmovie, 'plot', int32(s.plotting) );
%             startmovie();
%             if s.endmovie < s.until
%                 log_runGFtboxProject( 'Recomputing to time %f.\n', s.endmovie );
%                 m = leaf_iterate( m, s.steps, 'until', s.endmovie, 'plot', int32(s.plotting) );
%                 endmovie();
%                 log_runGFtboxProject( 'Recomputing to time %f.\n', s.until );
%                 m = leaf_iterate( m, s.steps, 'until', s.until, 'plot', int32(s.plotting) );
%             else
%                 log_runGFtboxProject( 'Recomputing to time %f.\n', s.until );
%                 m = leaf_iterate( m, s.steps, 'until', s.until, 'plot', int32(s.plotting) );
%             end
%         end
    end
    log_runGFtboxProject( 'Run complete.\n' );
    endmovie();
    if ~isempty( s.saverun )
        log_runGFtboxProject( 'Saving run as %s.\n', s.saverun );
        m = leaf_saverun( m, 'name', s.saverun );
    end
    
    % In case any finalisation is needed.
    [m,~] = leaf_dointeraction( m );

    if s.snapshot
        if ~haveFigure
            m = leaf_addpicture( m, 'figure', 4 );
            m = leaf_plot( m, s.plotoptions );
%             haveFigure = true;
        end
        if ischar( s.snapshot )
            snapshotname = s.snapshot;
            if snapshotname(1) ~= '/'
                snapshotname = fullfile( s.resultsdir, snapshotname );
            end
        else
            snapshotname = '';
        end
        log_runGFtboxProject( 'Saving final snapshot to %s\n', snapshotname );
        m = leaf_snapshot( m, snapshotname, 'includeIF', false );
    end
    
    if ishghandle( m.pictures(1) )
        delete( ancestor( m.pictures(1), 'figure' ) );
    end
    
    endlog();
    
    
    
    function startmovie()
        if s.movie
            if ischar( s.movie )
                s.movieoptions.filename = s.movie;
            end
            m = leaf_setproperty( m, 'autonamemovie', true );
            log_runGFtboxProject( 'Starting movie.  Movie options:\n' );
            printValue( 1, s.movieoptions );
            printValue( logfid, s.movieoptions );
            m = leaf_movie( m, s.movieoptions );
            haveMovie = true;
        end
    end

    function endmovie()
        if haveMovie
            log_runGFtboxProject( 'Closing movie.\n' );
            m = leaf_movie( m, 0 );
            haveMovie = false;
        end
    end

    function log_runGFtboxProject( varargin )
        logstring = [datestr(clock,'yyyy-mmm-dd HH:MM:SS.FFF'), ' ', sprintf( varargin{:} )];
        if ~isempty(logstring) && (logstring(end) ~= newline)
            logstring = [ logstring newline ];
        end
        timedFprintf( 1, '%s', logstring );
        timedFprintf( logfid, '%s', logstring );
    end

    function endlog()
        if logfid ~= -1
            duration = timestr( toc(begintime) );
            log_runGFtboxProject( 'End of run.\nDuration %s.\n\n====\n\n\n', duration );
            fclose( logfid );
        end
    end
end
