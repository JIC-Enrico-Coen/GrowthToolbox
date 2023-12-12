function joinMoviesWithFade( outputvideo, inputmoviefiles, varargin )
%joinMoviesWithFade( outputvideo, moviefiles, ... )
%   
%   OUTPUTVIDEO can be either a file name or an open VideoWriter object. In
%   the first case, a video will be written to the given file. In the
%   second case, the video will be appended to the VideoWriter object.
%
%   INPUTMOVIEFILES is a cell array of names of movie files to be read and
%   stitched together. Fade-in and -out will be added to each, a pause
%   on the start and end frames, and a pause on the background between the
%   movies.
%
%   The options are as for addFadeInOut, plus these:
%
%   'dir'   The directory to find the input movie files, if these are not
%           given as full path names.
%
%   'fps'   The frames per second of the resulting movie. If not given, the
%           frame rate of the first movie file is used.
%
%   'gap'   The time in seconds when the background frame is shown between
%           movies.
%
%   'startgap'   The time in seconds when the background frame is shown
%           before any of the movies
%
%   'endgap'   The time in seconds when the background frame is shown after
%           the end of all the movies.
%
%   'startcolor'    The background colour at the start of the movie.
%
%   'endcolor'    The background colour at the end of the movie.
%
%   In addition, these options are not passed through to addFadeInOut:
%
%   'includefirst'  Whether to write the first frame.
%
%   'includelast'   Whether to write the last frame.
%
%   See also: addFadeInOut

    if isempty( inputmoviefiles )
        timedFprintf( 'No movie files given.\n' );
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'dir', '', ...
            'fps', [], ...
            'fadein', 0.5, ...
            'fadeout', 0.5, ...
            'startpause', 0.5, ...
            'firstpause', 0.5, ...
            'lastpause', 1, ...
            'endpause', 0.5, ...
            'startcolor', 0.2, ...
            'endcolor', 0.2, ...
            'fadecolor', 0.2, ...
            'startgap', 0, ...
            'endgap', 0, ...
            'gap', 0.1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'dir', 'fps', 'fadein', 'fadeout', 'startpause', 'firstpause', 'lastpause', 'endpause', 'startcolor', 'endcolor', 'fadecolor', 'gap', 'startgap', 'endgap' );
    if ~ok, return; end

    numMovieFiles = length(inputmoviefiles);
    
    if ~isempty( s.dir )
        for mi = 1:numMovieFiles
            if ~isrootpath( inputmoviefiles{mi} )
                inputmoviefiles{mi} = fullfile( s.dir, inputmoviefiles{mi} );
            end
        end
        s = rmfield( s, 'dir' );
    end
    
    filesexist = false( 1, numMovieFiles );
    for mi=1:numMovieFiles
        filesexist(mi) = exist( inputmoviefiles{mi}, 'file' );
    end
    if any(~filesexist)
        fprintf( 1, '%d input files not found:\n', sum(~filesexist) );
        for mi=1:numMovieFiles
            if ~filesexist(mi)
                fprintf( '    %s\n', inputmoviefiles{mi} );
            end
        end
        return;
    end
    
    gap = s.gap;
    startgap = s.startgap;
    endgap = s.endgap;
    startcolor = s.startcolor;
    endcolor = s.endcolor;
    fadecolor = s.fadecolor;
    fps = s.fps;
    s.includefirst = false;
    s.includelast = true;
    s = rmfield( s, { 'fps', 'gap', 'startgap', 'endgap', 'startcolor', 'endcolor' } );

    try
        vin = VideoReader( inputmoviefiles{1} );
    catch e
        timedFprintf( 'Could not read video file ''%s''.\n    Reason: %s\n', inputvideofile, e.message );
        return;
    end
    if isempty( s.fps )
        frameRate = vin.FrameRate;
    else
        frameRate = fps;
    end
    frameHeight = vin.Height;
    frameWidth = vin.Width;
    firstFrame = readFrame( vin );
    startcolor3 = reshape( fitToColorDepth( reshape( startcolor, 1, [] ), size(firstFrame,3) ), 1, 1, [] );
    endcolor3 = reshape( fitToColorDepth( reshape( endcolor, 1, [] ), size(firstFrame,3) ), 1, 1, [] );
    fadecolor3 = reshape( fitToColorDepth( reshape( fadecolor, 1, [] ), size(firstFrame,3) ), 1, 1, [] );
    startFrame = repmat( startcolor3, vin.Height, vin.Width, 1 );
    endFrame = repmat( endcolor3, vin.Height, vin.Width, 1 );
    backgroundFrame = repmat( fadecolor3, vin.Height, vin.Width, 1 );
    clear( 'vin' );


    if isa( outputvideo, 'VideoWriter' )
        vout = outputvideo;
        closeOutput = false;
    else
        try
            vout = VideoWriter( outputvideo, 'MPEG-4' );
            vout.FrameRate = frameRate;
            open( vout );
        catch e
            timedFprintf( 'Could not open output video file ''%s''.\n    Reason: %s\n', outputvideo, e.message );
            return;
        end
        closeOutput = true;
    end
    
    timedFprintf( 'Writing fade-in.\n' );
    
    framesWritten = repeatFrame( vout, startFrame, startgap, true, true );
    
    for mi=1:numMovieFiles
        timedFprintf( 'Writing component movie %d of %d.\n', mi, numMovieFiles );
        if mi == 1
            s.includefirst = framesWritten==0;
        else
            s.includefirst = false;
            repeatFrame( vout, backgroundFrame, gap, false, true );
            for bi=1:numGapFrames
                writeVideo( vout, backgroundFrame );
            end
        end
        if mi==1
            s1 = s;
            s1.fadecolor = [ startcolor; fadecolor ];
            addFadeInOut( vout, inputmoviefiles{mi}, s1 );
        elseif mi==numMovieFiles
            s1 = s;
            s1.fadecolor = [ fadecolor; endcolor ];
            addFadeInOut( vout, inputmoviefiles{mi}, s1 );
        else
            addFadeInOut( vout, inputmoviefiles{mi}, s );
        end
        if mi==1
            backgroundFrame = repmat( fadecolor3, frameHeight, frameWidth, 1 );
            numGapFrames = ceil( vout.FrameRate * gap );
        end
    end
    
    timedFprintf( 'Writing fade-out.\n' );
    repeatFrame( vout, endFrame, endgap, false, true );
    
    if closeOutput
        close( vout );
    end
end