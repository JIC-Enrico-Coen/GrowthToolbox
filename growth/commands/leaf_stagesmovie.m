function [m,ok] = leaf_stagesmovie( m, varargin )
%leaf_stagesmovie( m, ... )
%   Make a movie from all the current stage files.  If there is currently a
%   movie in progress, it will first be closed.  The final stage will be
%   returned in m.
%
%   Options include all the options for leaf_movie, with the same effect,
%   as well as the following:
%
%   start: A time.  The movie will begin with the first stage file at or
%           after that time.  By default the initial state of the project.
%
%   end: A time.  The movie will end with the last stage file at or
%           before that time.  By default the last existing stage file of
%           the project.
%
%   closebefore: Whether to close any movie currently in progress before
%           beginning this one. Note that if a movie is open and has
%           already had any frames written to it, its parameters cannot be
%           changed. The default is true.
%
%   close after: Whether to close the movie at the end. The default is true.
%
%   leaf_stagesmovie never recomputes any stages.  It makes a movie only
%   from the existing stage files in the specified time range.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    handles = guidata( m.pictures(1) );
    if isfield( handles, 'fps' )
        fps = handles.fps;
    else
        fps = 15;
    end
    if isfield( handles, 'quality' )
        quality = handles.quality;
    else
        quality = 75;
    end
    s = defaultfields( s, ...
        'start', -Inf, ...
        'end', Inf, ...
        'closebefore', true, ...
        'closeafter', true, ...
        'compression', m.globalProps.codec, ...
        'fps', fps, ...
        'quality', quality, ...
        'keyframe', 5 );
    starttime = s.start;
    endtime = s.end;
    closebefore = s.closebefore;
    closeafter = s.closeafter;
    s = rmfield( s, { 'start', 'end', 'closebefore', 'closeafter' } );
    
    % Get the stages that are to be made into a movie.
    stageTimes = savedStages( m );
    stageTimes = stageTimes( (stageTimes >= starttime) & (stageTimes <= endtime) );
    if isempty( stageTimes )
        if isinf(starttime)
            if isinf(endtime)
                GFtboxAlert( m, 'No saved stages.  No movie created.' );
            else
                GFtboxAlert( m, 'No saved stages at or before %f.  No movie created.', endtime );
            end
        elseif isinf(endtime)
            GFtboxAlert( m, 'No saved stages at or after %f.  No movie created.', starttime );
        else
            GFtboxAlert( m, 'No saved stages in range %f to %f.  No movie created.', starttime, endtime );
        end
        return;
    end
    
    % Close any current movie.
    if closebefore
        [m,ok] = leaf_movie( m, 0 );
        if ~ok
            return;
        end
    end
    
    numframes = length(stageTimes);
    fprintf( 1, 'Creating %d frames from times %f to %f.\n', numframes, stageTimes(1), stageTimes(end) );
    
    % Prepare to be interrupted.
    oldrunning = setRunning( guidata(m.pictures(1)), true );
    sb = findStopButton( m );
    
    % Get the figure we are plotting into.
    theaxes = m.pictures(1);
    
    % Load the first stage file.
    [m,ok] = leaf_reload( m, stageTimes(1) );
    if ok
%         fprintf( 1, '%f %f %f\n', m.nodes(1,:) );
        m.pictures = theaxes;
        m = leaf_plot( m );
        % Process GUI events.
        setMyLegend( m );
    else
        return;
    end
    
    % Start a new movie.  This automatically saves the current mesh as the
    % first frame.
    [m,ok] = leaf_movie( m, s );
    if ~ok
        return;
    end
    
    savesnapshot( m );
    
    % Get the movie properties to use throughout.
    movieprops = m.globalProps.mov;
    
    % Load each subsequent stage file and add it to the movie.
    for i=2:numframes
        [m,ok] = leaf_reload( m, stageTimes(i) );
        if ok
%             fprintf( 1, '%f %f %f\n', m.nodes(1,:) );
            m.globalProps.mov = movieprops;
            m.pictures = theaxes;
            m = leaf_plot( m );
            setMyLegend( m );
            m = recordframe( m );
            
            savesnapshot( m );
        end
        if userinterrupt( sb ) && (i < numframes)
            fprintf( 1, 'Movie terminated with %d of %d frames, time %f - %f.\n', i, numframes, stageTimes(1), stageTimes(i) );
            break;
        end
    end
    if ishghandle( m.pictures(1) )
        setRunning( guidata(m.pictures(1)), oldrunning );
    end
    if ~oldrunning
        clearstopbutton( m );
    end
    
    % Close the movie.
    [m,ok] = leaf_movie( m, 0 );
    
    updateGUIFromMesh( m );
end

function savesnapshot( m )
    stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
    snapshotname = [ 'Stage', stagesuffix, '.png' ];
    m = leaf_snapshot( m, snapshotname, 'newfile', 0, 'includeIF', false );
end
