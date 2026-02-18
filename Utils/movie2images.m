function imgs = movie2images( mov, imageTemplate )
%imgs = movie2images( movie, imageTemplate )
%   Convert a movie to a set of image frames.
%
%   MOVIE can be either the name of a movie file or a VideoWriter object.
%
%   IMAGETEMPLATE is a format string suitable for use with fprintf. This
%   should contain a single format item of the form '%0Nd' where N is a
%   positive integer. For each frame, the frame number (starting from 1)
%   will replace that string to create the file name for that frame. The
%   file extension given by IMAGETEMPLATE will determine the file format.
%
%   If the output IMGS is requested, the image data will also be returned
%   as an A*B*C*D array, where A and B are the width and height in pixels,
%   C is the number of channels, and D is the number of frames.

    imgs = [];
    wantImgs = nargout > 0;
    if isa( mov, 'VideoReader' )
        moviereader = mov;
    elseif ischar(mov) || isstring(mov)
        try
            moviereader = VideoReader( mov );
        catch e
            timedFprintf( 'Cannot read movie "%s":\n        %s\n', mov, e.message );
        end
    else
        timedFprintf( 'Wrong type for movie argument: "', class(mov) );
        return;
    end
    moviebasename = moviereader.Name;
    moviedir = moviereader.Path;
    totalFrames = moviereader.NumFrames;
    
    if nargin < 2
        [~,base,~] = fileparts( moviebasename );
        numDigits = ceil( log10( totalFrames ) );
        imageTemplate = fullfile( moviedir, [ base, '-%0', sprintf( '%d', numDigits ), 'd.png' ] );
    end
    
    numframes = 0;
    while moviereader.hasFrame()
        img = moviereader.readFrame();
        numframes = numframes+1;
        if wantImgs
            if numframes==1
                imgs = zeros( [ size(img), totalFrames ] );
            end
            imgs(:,:,:,numframes) = img; %#ok<AGROW>
        end
        imgname = sprintf( imageTemplate, numframes );
        imwrite( img, imgname );
    end
    
    numchannels = size(imgs,3);
    bitdepth = int32(moviereader.BitsPerPixel/numchannels);
    switch bitdepth
        case 8
            imgs = uint8(imgs);
        case 16
            imgs = uint16(imgs);
        otherwise
            % Ignore and hope it never happens.
            timedFprintf( 'Unexpected bit depth %d. VideoFormat %s, bits per pixel %d, num channels %d\n', ...
                bitdepth, moviereader.VideoFormat, moviereader.BitsPerPixel, numchannels );
    end
end