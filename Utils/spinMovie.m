function spinMovie( ax, steps, moviefile, varargin )
%spinMovie( ax, steps, moviefile, ... )
%   Spins the camera for the axes object AX about the Z axis through the
%   camera's target point, for one full revolution, taking the given number
%   of steps. If the third argument is supplied, a movie is made.
%   Subsequent arguments specify optional parameters for the movie:
%
%   fps: The frames per second. Default 15.
%
%   compression: The codec to encode the movie with. Default 'MPEG-4'.
%
%   quality: the quality level of the compressor. Default 75.

    if ~isgraphics(ax) || ~strcmp( ax.Type, 'axes' )
        return;
    end
    ax.CameraViewAngleMode = 'manual'; % Prevents image changing in size as it is rotated.
    [s,ok] = safemakestruct( mfilename(), varargin );
    s = defaultfields( s, ...
        'fps', 15, ...
        'compression', 'MPEG-4', ...
        'quality', 75 );
    makemovie = nargin > 2;
    
    if makemovie
        mov = VideoWriter( moviefile, s.compression );
        set( mov, 'FrameRate', s.fps );
        try
            set( mov, 'Quality', s.quality );
        catch
            % Not all compressors support a quality setting, in which case
            % attempting to set the quality throws an error. We ignore it.
        end
        open( mov );
        frame = mygetframe( ax );
        mov = addmovieframe( mov, frame );
        framesize = size( frame.cdata );
        frameheight = framesize(1);
        framewidth = framesize(2);
        numchannels = size(frame.cdata,3);
        borderpixels = [ reshape( frame.cdata([1 end],:,:), [], numchannels );
                         reshape( frame.cdata(:,[1 end],:), [], numchannels ) ];
        minbp = min( borderpixels, [], 1 );
        maxbp = max( borderpixels, [], 1 );
        meanbp = mean( borderpixels, 1 );
        bgcolor = minbp;
    end
    
    [az,el] = view( ax );
    framestep = 360/steps; % Azimuth and elevation parameters are measured in degrees.
    tic;
    for i=1:steps
        view( [az+framestep*i,el] );
        toc;
        drawnow;
        if makemovie
            frame = mygetframe( ax );
            % For no known reason, Successive frames from different
            % viewpoints can vary in height or width by a pixel. All frames
            % added to a movie must be exactly the same size, so we force
            % each frame to be the same size as the initial frame.
            frame.cdata = trimframe( frame.cdata, [frameheight, framewidth], bgcolor );
            mov = addmovieframe( mov, frame );
        end
    end
    if makemovie
        close(mov);
    end
end
