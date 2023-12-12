function ok = addFadeInOut( outputvideo, inputvideofile, varargin )
%addFadeInOut( inputvideofile, outputvideofile, varargin )
%   Read a video file INPUTVIDEOFILE.
%   Add to the video a fade-in and a pause on the first frame, and a pause
%   on the last frame and a fade-out.
%
%   OUTPUTVIDEO can be either a file name or an open VideoWriter object. In
%   the first case, a video will be written to the given file. In the
%   second case, the video will be appended to the VideoWriter object.
%
%   Options:
%
%   'dir'           The directory containing the input file. If omitted,
%                   the current directory. Ignored if the input file is
%                   given as a full path name.
%
%   'fadein'        The duration of the fade-in in seconds.
%
%   'fadeout'       The duration of the fade-out in seconds.
%
%   'startpause'    The duration of the initial pause in seconds.
%
%   'firstpause'    The duration of the pause on the first frame in seconds.
%
%   'lastpause'     The duration of the pause on the last frame in seconds.
%
%   'endpause'      The duration of the final pause in seconds.
%
%   'includefirst'  Whether to write the first frame.
%
%   'includelast'   Whether to write the last frame.
%
%   'fadecolor'     The colour of the background that the fade-in and
%                   fade-out merge with. This can be a single greyscale
%                   value or an RGB colour of type double with values in
%                   the range 0 to 1. It can alternatively be a 2*N array
%                   whose rows specify the initial background color and the
%                   final background color.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'dir', '', ...
            'fadein', 1, ...
            'fadeout', 1.5, ...
            'startpause', 1, ...
            'firstpause', 1, ...
            'lastpause', 1, ...
            'endpause', 1, ...
            'includefirst', true, ...
            'includelast', true, ...
            'fadecolor', 0.3 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'dir', 'fadein', 'fadeout', 'startpause', 'firstpause', 'lastpause', 'endpause', 'includefirst', 'includelast', 'fadecolor' );
    if ~ok, return; end

    ok = false;
    
    if ~isempty( s.dir ) && ~isrootpath( inputvideofile )
        inputvideofile = fullfile( s.dir, inputvideofile );
    end
    
    try
        vin = VideoReader( inputvideofile );
    catch e
        timedFprintf( 'Could not read video file ''%s''.\n    Reason: %s\n', inputvideofile, e.message );
        return;
    end
    if ~hasFrame( vin )
        timedFprintf( 'No frames in video file ''%s''.\n', inputvideofile );
        return;
    end
    
    frameRate = vin.FrameRate;
    
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
    
    firstFrame = img2double( readFrame( vin ) );
    if size(s.fadecolor, 1 )==2
        fade1color = s.fadecolor(1,:);
        fade2color = s.fadecolor(2,:);
    else
        fade1color = s.fadecolor;
        fade2color = s.fadecolor;
    end
    fadecolor1 = reshape( fitToColorDepth( reshape( fade1color, 1, [] ), size(firstFrame,3) ), 1, 1, [] );
    fadecolor2 = reshape( fitToColorDepth( reshape( fade2color, 1, [] ), size(firstFrame,3) ), 1, 1, [] );
    backgroundFrame1 = repmat( fadecolor1, vin.Height, vin.Width, 1 );
    backgroundFrame2 = repmat( fadecolor2, vin.Height, vin.Width, 1 );
    
    repeatFrame( vout, backgroundFrame1, s.startpause, s.includefirst, true );    
    fadeBetweenFrames( vout, backgroundFrame1, firstFrame, s.fadein, false, true );
    repeatFrame( vout, firstFrame, s.firstpause, false, true );
    
    while hasFrame(vin)
        frame = readFrame(vin);
        writeVideo( vout, frame );
    end
    
    repeatFrame( vout, frame, s.lastpause, false, true );
    fadeBetweenFrames( vout, frame, backgroundFrame2, s.fadeout, false, true );
    repeatFrame( vout, backgroundFrame2, s.endpause, false, s.includelast );
    
    if closeOutput
        close( vout );
    end
    
    ok = true;
end

